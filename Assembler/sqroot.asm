;
;		Square Root program from AuerBach - Newton Rhapson Approximation.
;

		org 		0

		25000
		u			l024 												; skip over input data, and clear.
.l001

		org 		024
.l024
		a 			l001 												; read first number
		h 			m057 												; store in m057 and hold (mu)
		23000 															; shift right (number divided by 2)
		a 			m046 												; mu / 2 + 0.5 is the first approximation (Zi)
		c 			m055 												; store in m055 and clear accumulator
		25000 															; skip

.l027
		a 			m057 												; get the number
		d 			m055 												; divide by Zi, the last approximation (mu/Zi)
		s 			m055 												; subtract the last approximation (mu / Zi - Zi)
		23000 															; divide by 2 1/2( mu/Zi -Zi)
		a 			m055 												; add zi 1/2 (mu/Zi + Zi) e.g. next Newton Rhapson Approximation.
		c 			m056 												; save it and clear accumulator

		a 			m055 												; get difference between last approx and next approx
		s 			m056
		s 			m054 												; subtract 2 ^ -14
		t 			l036 												; if difference < that value , then calculation is over

		a 			m056 												; add next approximation (t clears Acc)
		c 			m055 												; store in current approximation.
		25000 															; skip instruction
		u 			l027 												; go back for next iteration.

.l036 
		a 			m056 												; get result
		c 			m755 												; store in result area and clear

		a 			l024 												; get the l024 word (a 001 h m057)
		a 			m052 												; bump address in first word (e.g. a 001 => a 002)
		c 			l024 									 			; write it back.

		a 			l036 												; get the l036 word (a m056 c m755)
		a 			m053 												; bump address in the second word
		h 			l036 												; write back, hold value in A

		s 			m051 												; subtract the last value + 1 (A 056 A 000)
		t 			l024 												; if negative, i.e. not reached it, do the next square root.

		a 			m047 												; reset code at l024
		c 			l024 
		a 			m050 												; reset code at l036
		c 			l036

		25000 															; skip
		u 			l754 												; go to data, get ready for print

.m046 	
		40000  															; 1/2 as a decimal.
		00000 		

.m047 	a 			l001
		h 			m057

.m050 	a 			m056
		c 			m755

.m051 	a 			m056 												; A 000 is C 777 + 1
		a 			000

.m052 
		00001
		00000

.m053 	
		00000
		00001

.m054 
		00002 															; 2 ^ -14 	
		00000
.m055
 		word 		0  													; current approximation
.m056  																	
		word 		0 													; next approximation.
.m057 																	
		word   		0 													; u value 


		org 		754
		25000 															; skip 
		01000 															; stop

.m755  																	; result area.
