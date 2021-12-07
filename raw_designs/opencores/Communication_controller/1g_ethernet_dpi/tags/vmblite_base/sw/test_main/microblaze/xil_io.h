#ifndef XIL_IO_H
#define XIL_IO_H

#ifdef __cplusplus
extern "C" {
#endif


#include "xil_types.h"

u8 Xil_In8(u32 Addr);
u16 Xil_In16(u32 Addr);
u32 Xil_In32(u32 Addr);

void Xil_Out8(u32 Addr, u8 Value);
void Xil_Out16(u32 Addr, u16 Value);
void Xil_Out32(u32 Addr, u32 Value);



extern u16 Xil_EndianSwap16(u16 Data);
extern u32 Xil_EndianSwap32(u32 Data);

#ifndef __LITTLE_ENDIAN__
extern u16 Xil_In16LE(u32 Addr);
extern u32 Xil_In32LE(u32 Addr);
extern void Xil_Out16LE(u32 Addr, u16 Value);
extern void Xil_Out32LE(u32 Addr, u32 Value);

#define Xil_In16BE(Addr) Xil_In16((Addr))
#define Xil_In32BE(Addr) Xil_In32((Addr))
#define Xil_Out16BE(Addr, Value) Xil_Out16((Addr), (Value))
#define Xil_Out32BE(Addr, Value) Xil_Out32((Addr), (Value))

#define Xil_Htonl(Data) (Data)
#define Xil_Htons(Data) (Data)
#define Xil_Ntohl(Data) (Data)
#define Xil_Ntohs(Data) (Data)

#else

extern u16 Xil_In16BE(u32 Addr);
extern u32 Xil_In32BE(u32 Addr);
extern void Xil_Out16BE(u32 Addr, u16 Value);
extern void Xil_Out32BE(u32 Addr, u32 Value);

#define Xil_In16LE(Addr) Xil_In16((Addr))
#define Xil_In32LE(Addr) Xil_In32((Addr))
#define Xil_Out16LE(Addr, Value) Xil_Out16((Addr), (Value))
#define Xil_Out32LE(Addr, Value) Xil_Out32((Addr), (Value))

#define Xil_Htonl(Data) Xil_EndianSwap32((Data))
#define Xil_Htons(Data) Xil_EndianSwap16((Data))
#define Xil_Ntohl(Data) Xil_EndianSwap32((Data))
#define Xil_Ntohs(Data) Xil_EndianSwap16((Data))

#endif

#ifdef __cplusplus
}
#endif

#endif
