#include <unistd.h>
#include <sys/syscall.h>
#include <linux/kernel.h>

int dsrpt_crtque()
{
    return syscall(SYS_create_queue);
}

int dsrpt_dltque()
{
    return syscall(SYS_delete_queue);
}

int dsrpt_sndmsg(const char *message, size_t size)
{
    return syscall(SYS_msg_send, message, size);
}

int dsrpt_msgrcve(char *buffer, size_t *size)
{
    return syscall(SYS_msg_receive, buffer, size);
}

int dsrpt_ackmsg()
{
    return syscall(SYS_msg_ack);
}