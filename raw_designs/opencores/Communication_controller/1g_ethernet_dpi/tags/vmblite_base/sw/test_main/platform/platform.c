
#include "platform.h"

#ifdef PLTFRM_WBS_PIO
 #include "wb_pio.h"
#endif /* PLTFRM_WBS_PIO */

#ifdef PLTFRM_WBS_UART
 #include "wb_uart.h"
#endif /* PLTFRM_WBS_UART */

void init_platform(void)
{
#ifdef PLTFRM_WBS_PIO
    wb_pio_init(PLTFRM_WBS_PIO_BASEADDR);
#endif /* PLTFRM_WBS_PIO */

#ifdef PLTFRM_WBS_UART
    wb_uart_init(PLTFRM_WBS_UART_BASEADDR);
#endif /* PLTFRM_WBS_UART */
}

void cleanup_platform(void)
{

}
