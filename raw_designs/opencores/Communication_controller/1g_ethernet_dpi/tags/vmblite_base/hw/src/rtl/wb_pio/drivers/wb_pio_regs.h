#ifndef __WB_PIO_REGS_H__
#define __WB_PIO_REGS_H__

#include "xil_types.h"
#include "xil_io.h"


#define lp_PIO_IN_ADDR     0*4
#define lp_PIO_OUT_ADDR    1*4

#define IORD_WB_PIO_DATA(base)             Xil_In32(base +lp_PIO_IN_ADDR) 
#define IOWR_WB_PIO_DATA(base, data)       Xil_Out32(base+lp_PIO_OUT_ADDR, (u32)data)


#endif