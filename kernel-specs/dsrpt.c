#include <linux/kernel.h>
#include <linux/syscalls.h>
#include <linux/msg.h>
#include <linux/wait.h>
#include <linux/sched.h>
#include <linux/slab.h>
#include <linux/mutex.h>

struct message
{
    char *data;
    size_t *size;
    struct list_head node;
};

static bool     isinit = false;
static struct   list_head queue;
static struct   mutex mtxlock;

static wait_queue_head_t wq_sender, wq_receiver;


SYSCALL_DEFINE0(hello) {
    pr_info("Disrupt SysCalls are available\n");
    return 0;
}

// create_queue system call creates a msg queue in kernel space if it's already not created,
// otherwise return the one that has already been created.
SYSCALL_DEFINE0(create_queue)
{
    printk("create queue invoked\n");

    // returning zero as the queue is already created in a previous call
    if (isinit)
    {
        return 0;
    }

    // initializing the main message queue and other required components
    INIT_LIST_HEAD(&queue);
    mutex_init(&mtxlock);

    init_waitqueue_head(&wq_sender);
    init_waitqueue_head(&wq_receiver);

    isinit = true;
    return 0;
}

// delete_queue system call cleans up the msg queue from the kernel space.
SYSCALL_DEFINE0(delete_queue)
{
    printk("delete queue invoked\n");

    // checking if queue exists
    if (!isinit)
    {
        return ENODATA;
    }

    // clearing list of queues by iterating over it
    struct message *data, *temp_data;

    list_for_each_entry_safe(data, temp_data, &queue, node)
    {
        list_del(&data->node);
        kfree(data->data);
        kfree(data);
    }

    isinit = false;
    return 0;
}

// msg_send sends a message to a process. The arguments are message, size of message, msg-queue.
// This is a blocking call. It should be unblocked when the server process acknowledges the message.
// The blocking should be implemented by placing the sender process in the wait queue,
// and unblocking should be implemented by placing the sender in the ready queue.
SYSCALL_DEFINE2(msg_send,
                // message data received from userspace
                char __user *, usrmsg,
                // size of the message data from userspace
                size_t __user, size)
{

    // check queue exists
    if (!isinit)
    {
        return ENODATA;
    }

    // convert the message coming from userspace to kernel
    struct message *message = kmalloc(sizeof(struct message), GFP_KERNEL);
    if (!message)
    {
        return ENOMEM;
    }

    message->data = kmalloc(size, GFP_KERNEL);
    if (!message->data)
    {
        kfree(message);
        return ENOMEM;
    }
    
    if (copy_from_user(message->data, usrmsg, size))
    {
        kfree(message->data);
        kfree(message);
        return ENOMEM;
    }
    
    message->size = &size;
    
    INIT_LIST_HEAD(&message->node);
    
    // appends message to the queue
    mutex_lock(&mtxlock);
    list_add_tail(&message->node, &queue);
    mutex_unlock(&mtxlock);
    
    // altered: Need to unblock the receiver call from here,
    wake_up(&wq_receiver);

    // The blocking should be implemented by placing the sender process in the wait queue
    wait_event_interruptible(wq_sender, true);
    
    return 0;
}

// When msg_receive is unblocked, the server process should acknowledge the message by using msg_ack.
SYSCALL_DEFINE0(msg_ack)
{

    // here, we only need to unblock the sender message
    wake_up(&wq_sender);
    return 0;
}
// msg_receive receives a message from the client. It’s a blocking call, waiting for the client to send something.
// It should be unblocked when the client sends the message. Arguments are buffer to message,
// reference argument to get the size of message received, msg queue.
// The blocking should be implemented by placing the sender process process in the wait queue,
// and unblocking should be implemented by placing the sender in the ready queue.
SYSCALL_DEFINE2(msg_receive,
                // pointer of the buffer to push message in userspace
                char __user *, buffer,
                // the size of message received
                size_t __user *, size)
{
    // check queue exists and it contains message to send
    if (isinit == false || list_empty(&queue))
    {
        return ENODATA;
    }

    // block the receiver as the message is already received
    wait_event_interruptible(wq_receiver, true);
        
    // fetch the message from queue
    struct message *message;
    int success_code = 0;
        
    mutex_lock(&mtxlock);
    message = list_first_entry(&queue, struct message, node);
    mutex_unlock(&mtxlock);
        
    // convert message to user space from kernel
    // convert size of message to user space from kernel
    copy_to_user(buffer, message->data, sizeof message->data);
    put_user(sizeof message->data, size);

    // delete the message
    mutex_lock(&mtxlock);
    list_del(&message->node);
    kfree(message->data);
    kfree(message);
    mutex_unlock(&mtxlock);
        
    // unblock the sender process to send other message
    wake_up(&wq_sender);
        
    return success_code;
}