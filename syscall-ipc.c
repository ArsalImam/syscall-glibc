#include <linux/kernel.h>
#include <linux/syscalls.h>


struct list_head    queue;
struct mutex        lock;

wait_queue_head_t   wq_sender, 
                    wq_receiver;


// create_queue system call creates a msg queue in kernel space if it's already not created, 
// otherwise return the one that has already been created.
SYSCALL_DEFINE0 (create_queue)
{
    printk("create queue invoked\n");

    //returning zero as the queue is already created in a previous call
    if (queue) {
        return 0;
    }


    INIT_LIST_HEAD(&queue)
    
    return 0;
}

// delete_queue system call cleans up the msg queue from the kernel space.
SYSCALL_DEFINE0 (delete_queue)
{
    printk("delete queue invoked\n");
    return 0;
}

// msg_send sends a message to a process. The arguments are message, size of message, msg-queue.
// This is a blocking call. It should be unblocked when the server process acknowledges the message.
// The blocking should be implemented by placing the sender process in the wait queue, 
// and unblocking should be implemented by placing the sender in the ready queue.
SYSCALL_DEFINE2 (msg_send,
                 // message data received from userspace
                 const char __user *, message,
                 // size of the message data from userspace
                 size_t __user *, size
                )
{
    printk("message send invoked\n");
    return 0;
}

// msg_receive receives a message from the client. It’s a blocking call, waiting for the client to send something.
// It should be unblocked when the client sends the message. Arguments are buffer to message, 
// reference argument to get the size of message received, msg queue. 
// The blocking should be implemented by placing the sender process process in the wait queue, 
// and unblocking should be implemented by placing the sender in the ready queue.
SYSCALL_DEFINE2 (msg_receive,
                 // pointer of the buffer to push message in userspace
                 const char __user *, message,
                 // the size of message received
                 size_t __user *, size
                )
{
    printk("message receive invoked\n");

    return 0;
}