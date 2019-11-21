.text
.equ	LEDs,  0x10000000
.equ	SWITCHES, 0x10000040
.global _start

_start:
	movia	r2, LEDs		/* Address of red LEDs. */         
	movia	r3, SWITCHES	/* Address of switches. */
LOOP:
	ldwio	r4, (r3)		/* Read the state of switches.*/
	stwio	r4, (r2)		/* Display the state on LEDs. */
	br	LOOP
.end
