;
;		Salary program
;


.wage
		word 	@5000 														; wage / net weekly income
.overtime
		word 	@1504 														; overtime / net yearly income.
.social
		word 	@65 														; social security / net monthly income 
.tax 
		word 	@700 														; federal tax
.bond 
		word 	@200 														; bond deduction.
.hospital
		word 	@156 														; hospitalisation


		a 		wage 														; calculate gross income 
		a 		overtime 
		s 		social
		s 		tax 
		s 		bond
		s  		hospital 													; net income ?

		h 		wage 														; save in wage
		k 		wage 														; put wage in L, clear A

		m 		weeksPerYear 												; multiply wage by weeks per year 
		h 		overtime 													; store in net yearly income.
		d 		monthsPerYear 												; divide by months in a year
		c 		social 														; store in net monthly income and clear
		25000 																; skip
		01000 																; stop

.weeksPerYear 
		word 	@52 														; weeks per year.
.monthsPerYear
		word 	@12
