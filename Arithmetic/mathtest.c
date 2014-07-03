// ************************************************************************************************************************************************************************
// ************************************************************************************************************************************************************************
//
//				Name : 		mathtest.c
//				Purpose :	Test program for 31 bit BINAC arithmetic library
//				Created:	3rd July 2014
//				Author:		Paul Robson (paul@robsons.org.uk)
//				License:	MIT
//
// ************************************************************************************************************************************************************************
// ************************************************************************************************************************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "math31.h"

#include "math31.c"

#define DELTA_ERROR (0.00000001) 														// Permissible arithmetic error

// ************************************************************************************************************************************************************************
//																	Do one set of checks on a pair of numbers
// ************************************************************************************************************************************************************************

void checkMath(void) {
	UINT32 n1,n2,n3;

	n1 = rand() & MATH_MASK; 															// 31 bit values
	n2 = rand() & MATH_MASK;

	double d1 = MATHToDouble(n1);														// double equivalents
	double d2 = MATHToDouble(n2);
	double d3,dr;

	if (fabs(d1+d2) < 1) { 																// Check addition
		n3 = MATHAdd(n1,n2);
		d3 = MATHToDouble(n3);
		dr = d1 + d2;
		if (fabs(dr-d3) > DELTA_ERROR)
			printf("ADD: %x %x %x %lf %lf %lf = %lf\n",n1,n2,n3,d1,d2,d3,dr);
	}

	if (fabs(d1-d2) < 1) { 																// Check subtraction
		n3 = MATHSubtract(n1,n2);
		d3 = MATHToDouble(n3);
		dr = d1 - d2;
		if (fabs(dr-d3) > DELTA_ERROR)
			printf("SUB: %x %x %x %lf %lf %lf = %lf\n",n1,n2,n3,d1,d2,d3,dr);
	}

	if (fabs(d1*d2) < 1) { 																// Check multiplication
		n3 = MATHMultiply(n1,n2);
		d3 = MATHToDouble(n3);
		dr = d1 * d2;
		if (fabs(dr-d3) > DELTA_ERROR)
			printf("MUL: %x %x %x %lf %lf %lf = %lf\n",n1,n2,n3,d1,d2,d3,dr);
	}

	if (fabs(d1) < fabs(d2)  && d2 != 0.0) { 											// Check division
		n3 = MATHDivide(n1,n2);
		d3 = MATHToDouble(n3);
		dr = d1 / d2;
		if (fabs(dr-d3) > DELTA_ERROR)
			printf("DIV: %x %x %x %lf %lf %lf = %lf\n",n1,n2,n3,d1,d2,d3,dr);
		if ((n3 & 1) == 0) printf("%x\n",n3);
	}
}


int main(int argc,char *argv[]) {
	srand(42); 																			// Seed RNG
	for (int i = 1;i < 1000*100000;i++)													// Do many tests.
		checkMath();
	printf("Arithmetic okay.\n"); 														// Passed !
}
