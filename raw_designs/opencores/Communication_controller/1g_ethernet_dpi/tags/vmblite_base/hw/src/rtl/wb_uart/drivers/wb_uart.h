#ifndef __WB_UART_H__
#define __WB_UART_H__

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

void wb_uart_init(int base);
/* sync */
int  wb_uart_read_s(void); 
void wb_uart_write_s(int data);
/* async */
int wb_uart_read_a(void); 
int wb_uart_write_a(int data);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __WB_UART_H__ */