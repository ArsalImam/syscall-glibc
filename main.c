#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <signal.h>

//  g++ -DIS_FOR_TESTING=1  main.c -o main
#ifdef IS_FOR_TESTING
#include "mock-syscalls.c"
#endif

#define tochar(p) ((*p) * 256 + *(p + 1))

int strtsrv()
{
    pid_t pid;

    pid = fork();
    
    if (pid == -1) {
        perror("fork");
        exit(EXIT_FAILURE);
        return EAGAIN;
    }

    char buffer[128];
    size_t* size;
    
    printf("starting server...");
    
    for (;;)
    {

        if (signal(SIGCHLD, SIG_IGN) == SIG_ERR) {
            perror("signal");
            exit(EXIT_FAILURE);
        }

        int status = dsrpt_msgrcve(buffer, size);
        if (status == 0)
        {
            buffer[*size] = '\0';
            printf("pid: %i  |  message is received: %s\n", getpid(), buffer);

            status = dsrpt_ackmsg();
            if (status != 0)
            {
                printf("error while acknowledging the message: %i \n", status);
            }
        }
    }
    return 0;
}

int invkclnt(char *arg, char *lstarg)
{

    printf("%s %04x\n", arg, tochar(arg));
    switch (tochar(arg))
    {

    case 0x6877:
        return dsrpt_helwrld();

    case 0x6371:
        return dsrpt_crtque();

    case 0x6471:
        return dsrpt_dltque();

    case 0x736D:
        if (tochar(lstarg) == 0x736D)
            return EINVAL;
        return dsrpt_sndmsg(lstarg, sizeof(lstarg));

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

    return invkclnt(argv[1], argv[argc - 1]);
}
