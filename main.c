#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>

//  g++ -DIS_FOR_TESTING=1  main.c -o main
#ifdef IS_FOR_TESTING
#include "mock-syscalls.c"
#endif

#define tochar(p) ((*p) * 256 + *(p + 1))


int strtsrv()
{
    if (fork() != 0)
        return EAGAIN;

    char buffer[128];
    size_t size = sizeof buffer;

    for (;;)
    {
        int status = prvpn_msgrcve(buffer, size);
        if (status != 0)
        {
            printf("error received from message received: %i \n", status);
        }
        buffer[size] = '\0';
        printf("pid: %i  |  message is received: %s\n", getpid(), buffer);

        status = prvpn_ackmsg();
        if (status != 0)
        {
            printf("error while acknowledging the message: %i \n", status);
        }
    }
    return 0;
}

int invkclnt(char *arg, char *lstarg)
{
    switch (tochar(arg))
    {
    case 0x6371:
        return prvpn_crtque();

    case 0x6471:
        return prvpn_dltque();

    case 0x736D:
        if (tochar(lstarg) == 0x736D)
            return EINVAL;

        return prvpn_sndmsg(lstarg, sizeof(lstarg));

    default:
        return EINVAL;
    }
    return EINVAL;
}

int main(int argc, char *argv[])
{
    printf("main invoked with %d arguments:\n", argc);

    if (1 == argc)
        return strtsrv();

    return invkclnt(argv[0], argv[argc - 1]);
}
