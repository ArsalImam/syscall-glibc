#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int dsrpt_crtque()
{
    printf("usrspc: queue creation\n");
    return syscall(601);
}

int dsrpt_dltque()
{
    printf("usrspc: queue dlt\n");
    return syscall(602);
}

int dsrpt_sndmsg(char *message, size_t size)
{
    int syscode = syscall(603, message, size);
    return syscode;
}

int dsrpt_msgrcve(char* buffer, size_t* size)
{
    return syscall(604, buffer, size);
}

int dsrpt_ackmsg()
{
    printf("usrspc: sckmsg\n");
    return syscall(605);
}

int dsrpt_helwrld() {
    return syscall(606);
}