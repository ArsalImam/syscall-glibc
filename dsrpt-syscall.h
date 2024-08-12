#include <unistd.h>

int dsrpt_crtque(void);
int dsrpt_dltque(void);
int dsrpt_ackmsg(void);
int dsrpt_sndmsg(const char *message, size_t size);
int dsrpt_msgrcve(char *buffer, size_t *size);