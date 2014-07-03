// ************************************************************************************************************************************************************************
// ************************************************************************************************************************************************************************
//
//				Name : 		math31.c
//				Purpose :	31 bit BINAC arithmetic library
//				Created:	3rd July 2014
//				Author:		Paul Robson (paul@robsons.org.uk)
//				License:	MIT
//
// ************************************************************************************************************************************************************************
// ************************************************************************************************************************************************************************

#include "math31.h"

// ************************************************************************************************************************************************************************
//																	Negate a 31 bit integer
// ************************************************************************************************************************************************************************

UINT32 MATHNegate(UINT32 n) {
	return ((~n)+1) & MATH_MASK;														// 2's complement negation
}

// ************************************************************************************************************************************************************************
//																	Add two 31 bit integers
// ************************************************************************************************************************************************************************

UINT32 MATHAdd(UINT32 n1,UINT32 n2) {
	return (n1 + n2) & MATH_MASK; 														// Add together and dump overflow
}

// ************************************************************************************************************************************************************************
//															Subtract one 31 bit integer from another
// ************************************************************************************************************************************************************************

UINT32 MATHSubtract(UINT32 n1,UINT32 n2) {
	return MATHAdd(n1,MATHNegate(n2)); 													// Add using 2's complement
}

// ************************************************************************************************************************************************************************
//																Check to see if an integer is negative
// ************************************************************************************************************************************************************************

int MATHIsNegative(UINT32 n) {
	return (n & MATH_SIGN_BIT) != 0; 													// Negative if sign bit set.
}

// ************************************************************************************************************************************************************************
//																	Multiply two 31 bit integers
// ************************************************************************************************************************************************************************

UINT32 MATHMultiply(UINT32 n1,UINT32 n2) {
	int isSigned = 0; 																	// Track result signed
	if (MATHIsNegative(n1)) {  															// Remove sign from firsts
		n1 = MATHNegate(n1); 
		isSigned = (isSigned == 0); 
	}
	if (MATHIsNegative(n2)) {  															// Remove sign from second
		n2 = MATHNegate(n2); 
		isSigned = (isSigned == 0); 
	}
	ULONG64 r = n1; 																	// Calculate 64 bit product and get the uppermost 31 bits.
	r = (r * n2) >> 30; 																// It's a shortcut, not using arithmetic.pdf method.
	n1 = (UINT32)(r & MATH_MAGNITUDE); 													// Mask and convert to 31 bit.
	return (isSigned) ? MATHNegate(n1) : n1; 											// Put sign back
}

// ************************************************************************************************************************************************************************
//											Divide one 31 bit integer into another, as in the Robert F Shaw paper from 1950
// ************************************************************************************************************************************************************************

UINT32 MATHDivide(UINT32 n1,UINT32 n2) {
	UINT32 result, p;  																	// Algorithm in Robert F. Shaw's paper.
	result = 0; 																		// Division result.
	p = MATH_SIGN_BIT;																	// The bit to copy, or not, into the result.
	for (int i = 0;i < 30;i++) { 														// Do 30 bits
		if ((n1 & MATH_SIGN_BIT) != (n2 & MATH_SIGN_BIT)) { 							// Sign different.
			n1 = MATHAdd(MATHAdd(n1,n1),n2);
		} else { 																		// Sign same
			n1 = MATHSubtract(MATHAdd(n1,n1),n2);
			result = result | p;
		}
		p = (p >> 1); 																	// Next p
	}
	result = MATHAdd(result,0x40000001); 												// Add fixup.
	return result;
}

// ************************************************************************************************************************************************************************
//												Convert a 31 bit integer to a signed double floating point number
// ************************************************************************************************************************************************************************

double MATHToDouble(UINT32 binary) {
	double sign = 1.0; 																	// Sign of result
	if (binary & MATH_SIGN_BIT) { 														// If signed
		sign = -1.0; 																	// Result will be -ve
		binary = MATHNegate(binary); 													// calculate |binary|
	}
	double value = 0.0; 																// add up all the set bits
	double bitValue = 0.5; 																// value of place
	while (binary != 0) { 																// go until all 1 bits set.
		binary = (binary << 1) & MATH_MASK; 											// shift msb into sign bit.
		if (binary & MATH_SIGN_BIT) value += bitValue; 									// add bit value if set
		bitValue = bitValue / 2.0; 														// do next decimal place
	}
	return sign * value; 																// calculate the result.
}


