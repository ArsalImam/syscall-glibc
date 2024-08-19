#define _GNU_SOURCE

#include <unistd.h>
#include <sys/syscall.h>
#include <errno.h>

#define SYS_create_queue 601
#define SYS_delete_queue 602
#define SYS_msg_send 603
#define SYS_msg_receive 604
#define SYS_msg_ack 605
#define SYS_hello 606

int dsrpt_crtque()
{
    return syscall(SYS_create_queue);
}

int dsrpt_dltque()
{
    return syscall(SYS_delete_queue);
}

int dsrpt_sndmsg(char *message, size_t size)
{
    return syscall(SYS_msg_send, message, size);
}

int dsrpt_msgrcve(char* buffer, size_t* size)
{
    return syscall(SYS_msg_receive, buffer, size);
}

int dsrpt_ackmsg()
{
    return syscall(SYS_msg_ack);
}

int dsrpt_helwrld()
{
    return syscall(SYS_hello);
}