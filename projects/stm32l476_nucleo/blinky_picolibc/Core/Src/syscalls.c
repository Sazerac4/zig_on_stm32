#include <stdio.h>

static int _putc(char c, FILE* file)
{
    (void)file; /* Not used in this function
    // __uart_putc(c);		/* Defined by underlying system */
    return c;
}

static int _getc(FILE* file)
{
    unsigned char c;
    (void)file; /* Not used in this function */
    // c = __uart_getc();	/* Defined by underlying system */
    return c;
}

static int _flush(FILE* file)
{
    /* This function doesn't need to do anything */
    (void)file; /* Not used in this function */
    return 0;
}

/* Define a stdio */
static FILE __stdio = FDEV_SETUP_STREAM(_putc, _getc, _flush, _FDEV_SETUP_RW);

/* Define stdin, stdout and stderr */
FILE* const stdin = &__stdio;
__strong_reference(stdin, stdout);
__strong_reference(stdin, stderr);


_Noreturn void _exit(int status)
{
    (void)status;
    while (1)
        ;
}
