#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <signal.h>

//gcc -DUSE_DSRPT_WRPPR=1  client.c -o client -ldsrpt
#ifdef USE_DSRPT_WRPPR
#include "dsrpt-syscall.h"
#else
#include "kernel-calls.c"
#endif

#define tochar(p) ((*p) * 256 + *(p + 1))

int strtsrv()
{
    char buffer[128];
    size_t* size;

    for (;;)
    {

	int inpt, inpt2;
	scanf("%i", &inpt);

        int status = dsrpt_msgrcve(buffer, size);
        if (status == 0)
        {
            printf("pid: %i  |  message is received: %s\n", getpid(), buffer);
            
            scanf("%i", &inpt2);
          
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
