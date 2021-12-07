
#include "xil_io.h"
#include "xil_types.h"

u8 Xil_In8(u32 Addr) {
	return *(volatile u8 *)Addr;
}
u16 Xil_In16(u32 Addr) {
	return *(volatile u16 *)Addr;
}
u32 Xil_In32(u32 Addr) {
	return *(volatile u32 *)Addr;
}


void Xil_Out8(u32 Addr, u8 Value) {
	u8 *LocalAddr = (u8 *)Addr;
	*LocalAddr = Value;
}
void Xil_Out16(u32 Addr, u16 Value) {
	u16 *LocalAddr = (u16 *)Addr;
	*LocalAddr = Value;
}
void Xil_Out32(u32 Addr, u32 Value) {
	u32 *LocalAddr = (u32 *)Addr;
	*LocalAddr = Value;
}


u16 Xil_EndianSwap16(u16 Data)
{
	return (u16) (((Data & 0xFF00U) >> 8U) | ((Data & 0x00FFU) << 8U));
}
u32 Xil_EndianSwap32(u32 Data)
{
	u16 LoWord;
	u16 HiWord;


	LoWord = (u16) (Data & 0x0000FFFFU);
	HiWord = (u16) ((Data & 0xFFFF0000U) >> 16U);


	LoWord = (((LoWord & 0xFF00U) >> 8U) | ((LoWord & 0x00FFU) << 8U));
	HiWord = (((HiWord & 0xFF00U) >> 8U) | ((HiWord & 0x00FFU) << 8U));


	return ((((u32)LoWord) << (u32)16U) | (u32)HiWord);
}

#ifndef __LITTLE_ENDIAN__
u16 Xil_In16LE(u32 Addr)
#else
u16 Xil_In16BE(u32 Addr)
#endif
{
	u16 Value;

	Value = Xil_In16(Addr);

	return Xil_EndianSwap16(Value);
}

#ifndef __LITTLE_ENDIAN__
u32 Xil_In32LE(u32 Addr)
#else
u32 Xil_In32BE(u32 Addr)
#endif
{
	u32 InValue;

	InValue = Xil_In32(Addr);
	return Xil_EndianSwap32(InValue);
}

#ifndef __LITTLE_ENDIAN__
void Xil_Out16LE(u32 Addr, u16 Value)
#else
void Xil_Out16BE(u32 Addr, u16 Value)
#endif
{
	u16 OutValue;

	OutValue = Xil_EndianSwap16(Value);

	Xil_Out16(Addr, OutValue);
}

#ifndef __LITTLE_ENDIAN__
void Xil_Out32LE(u32 Addr, u32 Value)
#else
void Xil_Out32BE(u32 Addr, u32 Value)
#endif
{
	u32 OutValue;

	OutValue = Xil_EndianSwap32(Value);
	Xil_Out32(Addr, OutValue);
}
