// ************************************************************************************************************************************************************************
// ************************************************************************************************************************************************************************
//
//				Name : 		math31.h
//				Purpose :	Header, 31 bit BINAC arithmetic library
//				Created:	3rd July 2014
//				Author:		Paul Robson (paul@robsons.org.uk)
//				License:	MIT
//
// ************************************************************************************************************************************************************************
// ************************************************************************************************************************************************************************

#ifndef _MATH31_H
#define _MATH31_H

typedef unsigned int UINT32; 															// 32 bit unsigned
typedef unsigned long ULONG64; 															// 64 bit unsigned

#define MATH_SIGN_BIT 	(0x40000000) 													// Mask out sign bit (bit 31)
#define MATH_MASK 		(0x7FFFFFFF) 													// Mask 31 bit integer
#define MATH_MAGNITUDE  (0x3FFFFFFF)

UINT32 MATHNegate(UINT32 n);
UINT32 MATHAdd(UINT32 n1,UINT32 n2);
UINT32 MATHSubtract(UINT32 n1,UINT32 n2);
UINT32 MATHMultiply(UINT32 n1,UINT32 n2);
UINT32 MATHDivide(UINT32 n1,UINT32 n2);
int MATHIsNegative(UINT32 n);
double MATHToDouble(UINT32 binary);

#endif