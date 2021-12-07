#ifndef XIL_TYPES_H
#define XIL_TYPES_H

#include <stdint.h>
#include <stddef.h>



#ifndef TRUE
#  define TRUE		1U
#endif

#ifndef FALSE
#  define FALSE		0U
#endif

#ifndef NULL
#define NULL		0U
#endif


#ifndef __KERNEL__
#ifndef XBASIC_TYPES_H

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;

#define __XUINT64__
typedef struct
{
	u32 Upper;
	u32 Lower;
} Xuint64;
#define XUINT64_MSW(x) ((x).Upper)
#define XUINT64_LSW(x) ((x).Lower)

#endif


typedef char char8;
typedef int8_t s8;
typedef int16_t s16;
typedef int32_t s32;
typedef int64_t s64;
typedef uint64_t u64;
typedef int sint32;

typedef intptr_t INTPTR;
typedef uintptr_t UINTPTR;
typedef ptrdiff_t PTRDIFF;

#if !defined(LONG) || !defined(ULONG)
typedef long LONG;
typedef unsigned long ULONG;
#endif

#define ULONG64_HI_MASK	0xFFFFFFFF00000000U
#define ULONG64_LO_MASK	~ULONG64_HI_MASK

#else
#include <linux/types.h>
#endif


#define UPPER_32_BITS(n) ((u32)(((n) >> 16) >> 16))
#define LOWER_32_BITS(n) ((u32)(n))

#endif
