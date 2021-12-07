#ifndef __WB_UART_REGS_H__
#define __WB_UART_REGS_H__

#include "xil_types.h"
#include "xil_io.h"

/* mem-map: */
#define lp_UART_RXD_ADDR        0*4 /* byte-addr */
#define lp_UART_TXD_ADDR        1*4
#define lp_UART_STS_ADDR        2*4

/* */
#define IORD_WB_UART_DATA(base)             Xil_In32(base +lp_UART_RXD_ADDR) 
#define IOWR_WB_UART_DATA(base, data)       Xil_Out32(base+lp_UART_TXD_ADDR, (u32)data)
#define IORD_WB_UART_STS(base)              Xil_In32(base +lp_UART_STS_ADDR) 
/* */
#define WB_UART_TX_BUSY(base) (IORD_WB_UART_STS(base) & 0x01)
#define WB_UART_RX_EF(base)   (IORD_WB_UART_STS(base) & 0x02)


#endif /* __WB_UART_REGS_H__ */