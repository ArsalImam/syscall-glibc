#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int dsrpt_crtque()
{
    printf("queue creation");
    return 0;
}

int dsrpt_dltque()
{
    printf("queue deletion");
    return 0;
}

int dsrpt_sndmsg(char *message, size_t size)
{
    return 0;
}

int dsrpt_ackmsg()
{
    return 0;
}

int dsrpt_msgrcve(char* buffer, size_t size)
{
     const char *new_data = "Test message sent";
   
    if (strlen(new_data) < size)
    {
        strcpy(buffer, new_data);
    }
    return 0;
}