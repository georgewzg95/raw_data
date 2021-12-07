/*
 stdio
*/
#include "wb_uart.h"

void outbyte(char c)
{
    wb_uart_write_s(c);
}

char inbyte()
{
    char rxd = wb_uart_read_s();
    return rxd;
}
