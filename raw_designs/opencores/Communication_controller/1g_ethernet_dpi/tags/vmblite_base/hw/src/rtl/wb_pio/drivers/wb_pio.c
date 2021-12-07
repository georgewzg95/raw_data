
#include "xil_types.h"
#include "wb_pio_regs.h"
#include "wb_pio.h"

u32 u32_wb_pio_base;

void wb_pio_init(int base)
{
    u32_wb_pio_base = base;
}

int wb_pio_read(void)
{
    return (IORD_WB_PIO_DATA(u32_wb_pio_base));
}

void wb_pio_write(int data)
{
    IOWR_WB_PIO_DATA(u32_wb_pio_base, data);
}
