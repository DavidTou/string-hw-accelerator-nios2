.include "address_map_nios2.s"

/* This program exercises various features of the DE2-115 computer, as a test and
 * to provide and example. 
 *
 * It performs the following: 
 * 1. tests the SRAM repeatedly
 * 2. scrolls some text on the hex displays, which alternates between "dE2 115" and
 * "PASSEd" if there is no SRAM error detected, and "Error" if an error is detected 
 * 3. flashes the green LEDs. The speed of flashing and scrolling for 2. is controlled
 * by timer interrupts
 * 4. connects the SW switches to red LEDs
 * 5. handles pushbutton interrupts: pushing KEY1 speeds up the scrolling of text, 
 * pushing KEY2 slows it down, and pushing KEY3 stops the scrolling
 * 6. can test the GPIO JP5 expansion ports, if any odd-numbered data pins
 * and the even-numbered data pins are connected together, it will toggle the reg LEDs. 
 * The pin assignments of the port is listed below.
 * 7. echos text received from the JTAG UART (such as text typed in the
 * terminal window of the Monitor Program) to the serial port UART, and vice versa
 
  * The 32 data pins' (D0 to D31) distribution on the 40-pin expansion port:

      X     .   .   D0
      X     .   .   D1
     D2     .   .   D3
     D4     .   .   D5
     D6     .   .   D7
     5V     .   .   GND
     D8     .   .   D9
     D10    .   .   D11
     D12    .   .   D13
      X     .   .   D14
      X     .   .   D15       
     D16    .   .   D17
     D18    .   .   D19
     D20    .   .   D21
     3.3V   .   .   GND
     D22    .   .   D23
     D24    .   .   D25
     D26    .   .   D27
     D28    .   .   D29
     D30    .   .   D31
 
 */

	.text
	.global _start
_start:
	/* set up sp and fp */
	movia 	sp, SDRAM_END - 3			# stack starts from largest memory address 
	mov 		fp, sp

	/* initialize 7-segment displays buffer (dE2 115 just before being visible on left side) */
	movia 	r16, DISPLAY_BUFFER
	movia		r17, 0xde20115
	stw		r17, 0(r16)
	stw		zero, 4(r16)
	stw		zero, 8(r16)

	/* initialize green LED values */
	movia		r2, 0x55555555
	movia		r16, GREEN_LED_PATTERN
	stw		r2, 0(r16)

	/* initialize delay counter used to decide when to change displayed text */
	movia		r16, EIGHT_SEC
	stw		zero, 0(r16)

	/* initialize display toggle */
	movia		r16, DISPLAY_TOGGLE
	stw		zero, 0(r16)

	/* shift direction will be stored in SHIFT_DIRECTION, where 0 = left and 1 = right */
	movi		r2, 1
	movia		r16, SHIFT_DIRECTION
	stw		r2, 0(r16)

	/* start interval timer, enable its interrupts */
	movia		r16, TIMER_BASE
	movi		r15, 0b0111		# START = 1, CONT = 1, ITO = 1 
	sthio		r15, 4(r16)

	/* enable pushbutton interrupts */
	movia		r16, KEY_BASE
	movi		r15, 0b01110		# set all 3 interrupt mask bits to 1 (bit 0 is Nios II Reset) 
	stwio		r15, 8(r16)

	/* enable processor interrupts */
	movi		r15, 0b011		# enable interrupts for timer and pushbuttons 
	ori		r15, r15, 0b100000000000	# also enable interrupts for expansion port (JP5) 
    
	wrctl		ienable, r15
	movi		r15, 1
	wrctl		status, r15

	/* loop that tests the SRAM and keeps displays updated */
	movia		r15, 0x55555555
	movia		r17, ONCHIP_SRAM_END
DO_DISPLAY:
	movia		r16, ONCHIP_SRAM_BASE
	movia		r17, ONCHIP_SRAM_END
MEM_LOOP:
	call 		UPDATE_HEX_DISPLAY
	call		TEST_EXPANSION_PORTS		# test expansion ports
	call 		UPDATE_RED_LED			# read slider switches and show on red LEDs 
	call 		UPDATE_UARTS			# update both the JTAG and serial port UARTs 
  
	stw		r15, 0(r16)
	ldw		r14, 0(r16)
	bne		r14, r15, SHOW_ERROR
	addi		r16, r16, 4
	ble		r16, r17, MEM_LOOP
	
	xori		r15, r15, 0xFFFF
	xorhi		r15, r15, 0xFFFF

	/* change 7-segment displays buffer approx every 8 seconds */
	movia		r16, EIGHT_SEC
	ldw		r17, 0(r16)
	movi		r14, 80					#  80 timer interrupts ~= 10 sec 
	ble		r17, r14, DO_DISPLAY

	stw		zero, 0(r16)			# reset delay counter used to toggle displayed text 
	/* toggle display of dE2 115 and PASSEd */
	movia 	r16, DISPLAY_TOGGLE
	ldw		r17, 0(r16)
	beq		r17, zero, SHOW_PASSED

	stw		zero, 0(r16)			# toggle display setting 
	/* show dE2 115 */
	movia 	r16, DISPLAY_BUFFER
	movia		r17, 0xdE20115
	stw		r17, 0(r16)
	stw		zero, 4(r16)
	stw		zero, 8(r16)
	br 		DO_DISPLAY
SHOW_PASSED:
	movi		r17, 1
	stw		r17, 0(r16)				# toggle display setting 
	movia 	r16, DISPLAY_BUFFER
	movia		r17, 0xbA55Ed			# Passed 
	stw		r17, 0(r16)
	stw		zero, 4(r16)
	stw		zero, 8(r16)
	br 		DO_DISPLAY

SHOW_ERROR:
	movia 	r16, DISPLAY_BUFFER
	movia		r17, 0xe7787			# Error 
	stw		r17, 0(r16)
	stw		zero, 4(r16)
	stw		zero, 8(r16)
DO_ERROR:
	call 		UPDATE_HEX_DISPLAY
	br			DO_ERROR

/********************************************************************************
 * Updates the value displayed on the hex display. The value is taken from the 
 * buffer.
 *
 */
	.global UPDATE_HEX_DISPLAY
UPDATE_HEX_DISPLAY:
	subi		sp, sp, 36		# reserve space on the stack 
	/* save registers */
	stw		ra, 0(sp)
	stw		fp, 4(sp)
	stw 		r15, 8(sp)
	stw 		r16, 12(sp)
	stw 		r17, 16(sp)
	stw 		r18, 20(sp)
	stw 		r19, 24(sp)
	stw 		r20, 28(sp)
	stw 		r21, 32(sp)
	addi		fp, sp, 36

	/* load hex value to display */
	movia		r15, DISPLAY_BUFFER
	ldw		r16, 4(r15)		# value to display is in second full-word of buffer 

/* Loop to fill the two-word buffer that drives the parallel port on the DE2-115 
 * computer connected to the HEX7 to HEX0 displays. The loop produces for each 4-bit
 * character in r16 a corresponding 8-bit code for the segments of the displays
*/
	movia		r17, 7
	movia		r15, HEX3_HEX0	
	movia		r19, SEVEN_SEG_DECODE_TABLE
SEVEN_SEG_DECODER:
	mov		r18, r16
	andi		r18, r18, 0x000F
	add		r20, r19, r18						# index into decode table based on character 
	add		r21, zero, zero
	ldb		r21, 0(r20)							# r21 <- 7-seg character code 
	stb		r21, 0(r15)							# store 7-seg code into buffer 

	srli		r16, r16, 4
	addi		r15, r15, 1
	subi		r17, r17, 1
	bge		r17, zero, SEVEN_SEG_DECODER

	/* write parallel port buffer words */
	movia		r15, HEX3_HEX0
	ldw		r16, 0(r15)
	movia		r17, HEX3_HEX0_BASE
	stwio		r16, 0(r17)
	ldw		r16, 4(r15)
	movia		r17, HEX7_HEX4_BASE
	stwio		r16, 0(r17)

	/* restore registers */
	ldw		ra, 0(sp)
	ldw		fp, 4(sp)
	ldw 		r15, 8(sp)
	ldw 		r16, 12(sp)
	ldw 		r17, 16(sp)
	ldw 		r18, 20(sp)
	ldw 		r19, 24(sp)
	ldw 		r20, 28(sp)
	ldw 		r21, 32(sp)
	addi		sp, sp, 36		# release the reserved stack space 

	ret

/********************************************************************************
 * Updates the value displayed on the red LEDs. The value is taken from the 
 * slider switches.
 *
 */
	.global UPDATE_RED_LED
UPDATE_RED_LED:
	/* save registers */
	subi		sp, sp, 16		# reserve space on the stack 
	stw		ra, 0(sp)
	stw		fp, 4(sp)
	stw 		r15, 8(sp)
	stw 		r16, 12(sp)
	addi		fp, sp, 16

	/* load slider switch value to display */
	movia		r15, SW_BASE
	ldwio		r16, 0(r15)	

	/* read LED_toggle value */
	movia		r15, LED_TOGGLE      
	ldw     r15, 0(r15)    
	beq     r15, zero, SHOW_LED

	/* if toggled, write the complementary value of SW to the LED*/
	movia       r15, 0xffffffff
	xor     r16, r16, r15     
    
SHOW_LED:    
	/* write to red LEDs */
	movia		r15, RED_LED_BASE
	stwio		r16, 0(r15)

	/* restore registers */
	ldw		ra, 0(sp)
	ldw		fp, 4(sp)
	ldw		r15, 8(sp)
	ldw		r16, 12(sp)
	addi		sp, sp, 16

	ret

/********************************************************************************
 * Reads characters received from either JTAG or serial port UARTs, and echo
 * character to both ports.
 *
 */
	.global UPDATE_UARTS
UPDATE_UARTS:
	/* save registers */
	subi		sp, sp, 28		# reserve space on the stack 
	stw		ra, 0(sp)
	stw		fp, 4(sp)
	stw 		r15, 8(sp)
	stw 		r16, 12(sp)
	stw 		r17, 16(sp)
	stw 		r18, 20(sp)
	stw 		r19, 24(sp)
	addi		fp, sp, 28

	movia	r15, JTAG_UART_BASE
	movia	r19, SERIAL_PORT_BASE

GET_CHAR:
   ldwio   r17, 0(r15)				# Check if JTAG UART has new data and 
   andi    r18, r17, 0x8000		# read in the character          
   beq     r18, r0, GET_CHAR_UART		
   andi    r16, r17, 0x00ff

/* echo character */
PUT_CHAR:
   ldwio   r17, 4(r15)					# Check if JTAG UART is ready for data 
   andhi   r17, r17, 0xffff			# Check for write space 
   beq     r17, r0, PUT_CHAR_UART	
   stwio   r16, 0(r15)					# echo the character 

PUT_CHAR_UART:
   ldwio   r17, 4(r19)					# Check if UART is ready for data 
   andhi   r17, r17, 0xffff			# Check for write space 
   beq     r17, r0, GET_CHAR_UART	
   stwio   r16, 0(r19)					# echo the character 

GET_CHAR_UART:
   ldwio   r17, 0(r19)				# Check if UART has new data and 
   andhi   r18, r17, 0xFFFF		# read in the character          
   beq     r18, r0, NO_CHAR		
   andi    r16, r17, 0x00ff

/* echo character */
   ldwio   r17, 4(r19)					# Check if UART is ready for data 
   andhi   r17, r17, 0xffff			# Check for write space 
   beq     r17, r0, PUT_CHAR_JTAG	
   stwio   r16, 0(r19)					# echo the character 

PUT_CHAR_JTAG:
   ldwio   r17, 4(r15)					# Check if JTAG UART is ready for data 
   andhi   r17, r17, 0xffff			# Check for write space 
   beq     r17, r0, NO_CHAR	
   stwio   r16, 0(r15)					# echo the character 

NO_CHAR:
	/* restore registers */
	ldw		ra, 0(sp)
	ldw		fp, 4(sp)
	ldw		r15, 8(sp)
	ldw		r16, 12(sp)
	ldw		r17, 16(sp)
	ldw		r18, 20(sp)
	ldw		r19, 24(sp)
	addi		sp, sp, 28

	ret

/********************************************************************************
 * This code tests the GPIO JP5 expansion port. The code requires one  
 * even-numbered data pin(e.g. D2) to be connected with one odd-numbered
 * pin in the port(e.g. D3), which would typically be done using a wire 
 * or a pin connector.
 * If the two pins work properly, the code will toggle the red LEDs. 
 
 * The 32 data pins' (D0 to D31) distribution on the 40-pin expansion port 
 * is shown at line 21 
 */
	.global TEST_EXPANSION_PORTS
TEST_EXPANSION_PORTS:
	/* save registers */
	subi		sp, sp, 24		            # reserve space on the stack 
	stw     ra, 0(sp)
	stw     fp, 4(sp)
	stw 		r15, 8(sp)
	stw 		r16, 12(sp)
	stw 		r17, 16(sp)
	stw 		r18, 20(sp)
	addi		fp, sp, 24

	movia		r15, EXPANSION_JP5_BASE
	movia		r17, 0xFFFFFFFF		
	stwio		r17, 4(r15)				    # set all pins to be outputs
	stwio		r17, 0(r15)                 # restore 1 to all pins

    movia		r17, 0x55555555             
    stwio		r17, 4(r15)				    # set the odd-numbered pins to be output pins
       
    add     r17, zero, zero				    
    stwio		r17, 0(r15)                 # write 0 to all output pins
    
    call GPIO_DELAY                         # add a delay to make sure the output pins get pulled down to 0
    
    ldwio       r16, 0(r15)                 # read the input pins value        
 
    
	movia		r17, 0xFFFFFFFF		
	stwio		r17, 4(r15)				    # set all pins to be outputs
	stwio		r17, 0(r15)                 # restore 1 to all pins    
    
    movia		r17, 0xaaaaaaaa             
	stwio		r17, 4(r15)				    # set the even-numbered pins to be output pins    
    
	add     r17, zero, zero		
    stwio		r17, 0(r15)                 # write 0 to all output pins   

    call GPIO_DELAY                         
    
    ldwio       r18, 0(r15)                 # read the input pins value 
    
	movia		r15, LED_TOGGLE             # initialize the LED_TOGGLE to be 0
    movia       r17, 0x0
	stw		r17, 0(r15)        

    movia		r17, 0xaaaaaaaa             
    beq     r16, r17, RETURN                # if one input pin connected to one output pin, its value would be drawn to 0.    
                                            # if the value of input pin doesn't change, there is an error
                                       
    movia		r17, 0x55555555
    beq     r18, r17, RETURN                # if one input pin connected to one output pin, its value would be drawn to 0.
                                            # if the value of input pin doesn't change, there is an error
                                           
	movia		r15, LED_TOGGLE             # if both of input and output function correctly for the two pins, toggle the red LEDs
    movia       r17, 0x1
	stw		r17, 0(r15)

RETURN:
	ldw		ra, 0(sp)
	ldw		fp, 4(sp)
	ldw		r15, 8(sp)
	ldw		r16, 12(sp)
	ldw		r17, 16(sp)
	ldw		r18, 20(sp)
	addi		sp, sp, 24

	ret

    
GPIO_DELAY:
	/* save registers */
	subi		sp, sp, 12		# reserve space on the stack 
	stw		ra, 0(sp)
	stw		fp, 4(sp)
	stw 		r15, 8(sp)
	addi		fp, sp, 12
 
	movia		r15, 0x100
DELAY: 
    subi        r15, r15, 1
    bne         r15, zero, DELAY
   
	/* restore registers */
	ldw		ra, 0(sp)
	ldw		fp, 4(sp)
	ldw		r15, 8(sp)
	addi		sp, sp, 12

	ret    
    
/********************************************************************************
 * DATA SECTION
 */

	.data

/* Buffer to hold values to display on the hex display.
 * The buffer contains 3 full-words: before, visible, after
 */
	.global DISPLAY_BUFFER
DISPLAY_BUFFER:
	.fill 3, 4, 0

	.global SHIFT_DIRECTION
SHIFT_DIRECTION:
	.word 0

/* SEVEN_SEGMENT_DECODE_TABLE give the on/off settings for all segments in 
 * a single 7-seg display in the DE2-115 computer, for the characters 
 * 'blank', 1, 2, 3, 4, S, 6, r, o, 9, A, P, C, d, E, F. These values obey 
 * the digit indexes on the DE2-115 board 7-seg displays, and the assignment of 
 * these signals to parallel port pins in the DE2-115 computer.
*/
SEVEN_SEG_DECODE_TABLE:
	.byte 0b00000000, 0b00000110, 0b01011011, 0b01001111 
	.byte 0b01100110, 0b01101101, 0b01111101, 0b01010000
	.byte 0b01011100, 0b01100111, 0b01110111, 0b01110011 
	.byte 0b00111001, 0b01011110, 0b01111001, 0b01110001
/* HEX3_HEX0 and HEX7_HEX4 are used to hold the on/off settings for all segments in 
 * the 8 digits of 7-seg *	displays in the DE2-115 computer. The first word is 
 * written to the parallel port that drives HEX3 to HEX0, and the second word is 
 * written to the parallel port that drives HEX7 to HEX4.
*/
HEX3_HEX0:
	.word 0
HEX7_HEX4:
	.word 0

	.global GREEN_LED_PATTERN
GREEN_LED_PATTERN:
	.word 0

	.global EIGHT_SEC
EIGHT_SEC:
	.word 0

DISPLAY_TOGGLE:
	.word 0
    
LED_TOGGLE:
	.word 0    
    
	.end
