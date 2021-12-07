
#include "xil_types.h"
#include "wb_uart_regs.h"
#include "wb_uart.h"

u32 u32_wb_uart_base;

void wb_uart_init(int base)
{
    u32_wb_uart_base = (u32)base;
}

/* sync */
int  wb_uart_read_s(void)
{
    int rxd;

    IORD_WB_UART_STS(u32_wb_uart_base);
    while (WB_UART_RX_EF(u32_wb_uart_base));
    rxd = (IORD_WB_UART_DATA(u32_wb_uart_base) & 0xFF);
    return (rxd);
}
void wb_uart_write_s(int data)
{
    IORD_WB_UART_STS(u32_wb_uart_base);
    while (WB_UART_TX_BUSY(u32_wb_uart_base));
    IOWR_WB_UART_DATA(u32_wb_uart_base, data);
}
/* async */
int wb_uart_read_a(void)
{
    if (WB_UART_RX_EF(u32_wb_uart_base)) {
        return -1;
    }
    else {
        int rxd = IORD_WB_UART_DATA(u32_wb_uart_base) & 0xFF;
        return (rxd);
    }
}
int wb_uart_write_a(int data)
{
    if (WB_UART_TX_BUSY(u32_wb_uart_base)) {
        return -1;
    } else {
        IOWR_WB_UART_DATA(u32_wb_uart_base, data);
        return 0;
    }
}
