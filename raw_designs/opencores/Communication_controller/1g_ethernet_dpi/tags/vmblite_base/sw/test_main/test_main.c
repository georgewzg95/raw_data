/*
 * simple test application
 *
 *
 */

#include <stdio.h> /* xil_printf, .. */

#include "platform.h"
#include "wb_pio.h" /* wb_pio_write */


int main(void)
{

    init_platform();
    /*fflush(stdin);*/

    wb_pio_write(1);
    xil_printf("Finished\n");

    cleanup_platform();
    return 0;
}
