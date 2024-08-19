// dsrpt-syscall.h
#ifndef DSRPT_SYSCALL_H
#define DSRPT_SYSCALL_H

// create_queue system call creates a msg queue in kernel space if it's already not created,
// otherwise return the one that has already been created.
int dsrpt_crtque();
// delete_queue system call cleans up the msg queue from the kernel space.
int dsrpt_dltque();
// msg_send sends a message to a process. The arguments are message, size of message, msg-queue.
// This is a blocking call. It should be unblocked when the server process acknowledges the message.
// The blocking should be implemented by placing the sender process in the wait queue,
// and unblocking should be implemented by placing the sender in the ready queue.
int dsrpt_sndmsg(char *message, size_t size);
// When msg_receive is unblocked, the server process should acknowledge the message by using msg_ack.
int dsrpt_msgrcve(char* buffer, size_t* size);
// msg_receive receives a message from the client. It’s a blocking call, waiting for the client to send something.
// It should be unblocked when the client sends the message. Arguments are buffer to message,
// reference argument to get the size of message received, msg queue.
// The blocking should be implemented by placing the sender process process in the wait queue,
// and unblocking should be implemented by placing the sender in the ready queue.
int dsrpt_ackmsg();
// testing call to check syscalls are installed correctly!
int dsrpt_helwrld();

#endif // DSRPT_SYSCALL_H
