#ifndef __WB_PIO_H__
#define __WB_PIO_H__

#ifdef __cplusplus
extern "C"
{
#endif

void wb_pio_init(int base);
int wb_pio_read(void);
void wb_pio_write(int data);

#ifdef __cplusplus
}
#endif

#endif