#include "address_map_nios2.h"
#include "nios2_ctrl_reg_macros.h"

/* function prototypes */
void Update_HEX_display(int);
void Update_red_LED(void);
void Update_UARTs(void);
void Test_expansion_ports (void);


/* global variables */

int	display_buffer[] = { 0, 0, 0 };	/* Buffer to hold values to display on the hex display.
 													 * The buffer contains 3 full-words: before, visible, 
													 * after */
int	shift_direction = 0;					// display scrolling direction (right = 1, left = 0)
/* SEVEN_SEGMENT_DECODE_TABLE gives the on/off settings for all segments in 
 * a single 7-seg display in the DE2-115 computer, for the characters 
 * 'blank', 1, 2, 3, 4, S, 6, r, o, 9, A, P, C, d, E, F. These values obey 
 * the digit indexes on the DE2-115 board 7-seg displays, and the assignment of 
 * these signals to parallel port pins in the DE2-115 computer 
 */
char	seven_seg_decode_table[] = {	0x00, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x50, 
		  										0x5C, 0x67, 0x77, 0x73, 0x39, 0x5E, 0x79, 0x71 };
char	hex_segments[] = { 0, 0, 0, 0, 0, 0, 0, 0 };
int	green_LED_pattern = 0;				// used for a flashing pattern on the green lights
int	eight_sec = 0;							/* used to keep track of a delay, which is 8 seconds
													 * for the default display scrolling speed */
int	display_toggle = 0;					// toggles display of the text dE2 115 and PASSED
int LED_toggle = 0;                     //toggles display of the red LEDs

/***************************************************************************************
 * Main program: exercises various features of the computer, as a test 
 * and to provide an example.
 * It performs the following: 
 * 1. tests the SRAM repeatedly
 * 2. scrolls some text on the hex displays, which alternates between "dE2 115" and
 *    "PASSEd" if there is no SRAM error detected, and "Error" if an error is detected 
 * 3. flashes the green LEDs. The speed of flashing and scrolling for 2. is controlled
 *    by timer interrupts
 * 4. connects the SW switches to red LEDs
 * 5. handles pushbutton interrupts: pushing KEY1 speeds up the scrolling of text, 
 *    pushing KEY2 slows it down, and pushing KEY3 stops the scrolling
 * 6. can test the GPIO JP5 expansion ports, if any odd-numbered data pins and 
 *    the even-numbered data pins are connected together, it will toggle the reg LEDs.
 *    The pin assignments of the port is listed below.
 * 7. echos text received from the JTAG UART (such as text typed in the
 *    terminal window of the Monitor Program) to the serial port UART, and vice versa
 
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
    
****************************************************************************************/
int main(void)
{
	/* Declare volatile pointers to I/O registers (volatile means that IO load
	 * and store instructions will be used to access these pointer locations, 
	 * instead of regular memory loads and stores)
	*/
	volatile int * interval_timer_ptr = (int *) TIMER_BASE;
	volatile int * pushbutton_ptr = (int *) KEY_BASE;

	/* initialize 7-segment displays buffer (dE2 115 just before being visible on left side) */
	display_buffer[0] = 0xdE20115;			
	display_buffer[1] = 0x0;		
	display_buffer[2] = 0x0;	

	green_LED_pattern = 0x55555555;	// used for a flashing pattern on the green lights
	eight_sec = 0;							// initialize 8-second delay counter
	display_toggle = 0;					// display initialized to scroll the text dE2 115
	shift_direction = 1;					// initial shift direction is to the right

	*(interval_timer_ptr + 1) = 0x7;	// Set START = 1, CONT = 1, ITO = 1
	*(pushbutton_ptr + 2) = 0xE; 		// Set the 3 interrupt mask bits to 1 (bit 0 is Nios II reset)


	NIOS2_WRITE_IENABLE( 0x3 | 0x8000 );	// Set interrupt mask for the interval timer, pushbuttons and expansion port (JP5)
	NIOS2_WRITE_STATUS( 1 );			// Enable Nios II interrupts

	int * SRAM_ptr;

	int SRAM_write = 0x55555555;
	int SRAM_read;
	int memory_error = 0;
	while ( !memory_error )
	{
		SRAM_ptr = (int *) ONCHIP_SRAM_BASE;
		while( (SRAM_ptr < (int *) ONCHIP_SRAM_END) & !memory_error )
		{
			Update_HEX_display ( display_buffer[1] );
			Test_expansion_ports ( );
			Update_red_LED ( );							// read slider switches and show on red LEDs
			Update_UARTs ( );								// update both the JTAG and serial port UARTs

			// test SRAM
			* SRAM_ptr = SRAM_write; 
			SRAM_read = * SRAM_ptr; 
			if (SRAM_read != SRAM_write)
			{
				memory_error = 1;
			}
			SRAM_ptr += 1;
		};
		SRAM_write = ~SRAM_write;
		if ( eight_sec > 80 )
		{
			eight_sec = 0;									// restart the 8-second delay counter
			if ( display_toggle == 0 )
			{
				display_toggle = 1;
				display_buffer[0] = 0xbA55Ed;			// code for the word PASSEd
				display_buffer[1] = 0x0;		
				display_buffer[2] = 0x0;	
			}
			else
			{
				display_toggle = 0;
				display_buffer[0] = 0xdE20115;				// code for the word dE2 115
				display_buffer[1] = 0x0;		
				display_buffer[2] = 0x0;	
			}
		}
	};
	display_buffer[0] = 0xe7787;				// code for the word Error
	display_buffer[1] = 0x0;		
	display_buffer[2] = 0x0;	
	while ( 1 )
	{
		Update_HEX_display ( display_buffer[1] );
	}

	return 0;
}

/*******************************************************************************
 * Updates the value displayed on the hex display. The value is taken from the 
 * buffer.
********************************************************************************/
void Update_HEX_display( int buffer )
{
	volatile int * HEX3_HEX0_ptr = (int *) HEX3_HEX0_BASE;
	volatile int * HEX7_HEX4_ptr = (int *) HEX7_HEX4_BASE;
	int shift_buffer, nibble;
	char code;
	int i;

	shift_buffer = buffer;
	for ( i = 0; i < 8; ++i )
	{
		nibble = shift_buffer & 0x0000000F;		// character is in rightmost nibble
		code = seven_seg_decode_table[nibble];
		hex_segments[i] = code;
		shift_buffer = shift_buffer >> 4;
	}
	*(HEX3_HEX0_ptr) = *(int *) hex_segments; 		// drive the hex displays
	*(HEX7_HEX4_ptr) = *(int *) (hex_segments+4);	// drive the hex displays
	return;
}

/********************************************************************************
 * Updates the value displayed on the red LEDs. The value is taken from the 
 * slider switches.
********************************************************************************/
void Update_red_LED( void )
{
  	volatile int * slider_switch_ptr = (int *) SW_BASE;
	volatile int * red_LED_ptr = (int *) RED_LED_BASE;

	int sw_values;
	sw_values = *(slider_switch_ptr); 	// Read the SW slider switch values
    
    if(LED_toggle == 0)
        *(red_LED_ptr) = sw_values; 			// Light up the red LEDs
    else 
        *(red_LED_ptr) = ~sw_values; 
        
	return;
}

/********************************************************************************
 * Reads characteres received from either JTAG or serial port UARTs, and echo
 * character to both ports.
********************************************************************************/
void Update_UARTs( void )
{
  	volatile int * JTAG_UART_ptr = (int *) JTAG_UART_BASE;
	volatile int * UART_ptr = (int *) SERIAL_PORT_BASE;

	int JTAG_data_register, JTAG_control_register;
	char JTAG_char;
	int UART_data_register, UART_control_register;
	char UART_char;

	// check for char from JTAG, echo to both JTAG and serial port UARTs
	JTAG_data_register = *(JTAG_UART_ptr); 	// bit 15 is RVALID, bits 7-0 is char data
	if ( (JTAG_data_register & 0x8000) )		// have valid data to read?
	{
		JTAG_char = (char) (JTAG_data_register & 0xFF); 	// extract the character
		JTAG_control_register = *(JTAG_UART_ptr + 1); 		// upper halfword is WSPACE
		if ( (JTAG_control_register & 0xFFFF0000) != 0)		// okay to echo char to JTAG?
		{
			*(JTAG_UART_ptr) = JTAG_char; 		// echo the character
		}
		UART_control_register = *(UART_ptr + 1); 		// upper halfword is WSPACE
		if ( (UART_control_register & 0xFFFF0000) != 0)		// okay to echo char to serial port?
		{
			*(UART_ptr) = JTAG_char; 		// echo the character
		}
	}
	// check for char from serial port UART, echo to both serial port and JTAG UARTs
	UART_data_register = *(UART_ptr);		// bit 15 is RVALID, bits 7-0 is char data
	if ( (UART_data_register & 0x8000) )	// have valid data to read?
	{
		UART_char = (char) (UART_data_register & 0xFF); 	// extract the character
		UART_control_register = *(UART_ptr + 1); 		// upper halfword is WSPACE
		if ( (UART_control_register & 0xFFFF0000) != 0)		// okay to echo char to serial port?
		{
			*(UART_ptr) = UART_char; 		// echo the character
		}
		JTAG_control_register = *(JTAG_UART_ptr + 1); 		// upper halfword is WSPACE
		if ( (JTAG_control_register & 0xFFFF0000) != 0)		// okay to echo char to serial port?
		{
			*(JTAG_UART_ptr) = UART_char; 		// echo the character
		}
	}
	return;
}

/********************************************************************************
 * This code tests the GPIO JP5 expansion port. The code requires one  
 * even-numbered data pin(e.g. D2) to be connected with one odd-numbered
 * pin in the port(e.g. D3), which would typically be done using a wire 
 * or a pin connector.
 * If the two pins work properly, the code will toggle the red LEDs. 
 
 * The 32 data pins' (D0 to D31) distribution on the 40-pin expansion port 
 * is shown at line 51 
********************************************************************************/
void Test_expansion_ports( void )
{
  	volatile int * JP5_EXPANSION_ptr = (int *) EXPANSION_JP5_BASE;
    
    // set all pins to be outputs and restore 1 to all pins
    *(JP5_EXPANSION_ptr+1) = 0xffffffff;    
    *(JP5_EXPANSION_ptr) = 0xffffffff;    
    
    // set the even-numbered pins to be output pins and write 0 to all output pins
	*(JP5_EXPANSION_ptr+1) = 0x55555555;    
    *(JP5_EXPANSION_ptr) = 0x0;    
    
    //read the input pins value
    volatile int odd_in = *(JP5_EXPANSION_ptr); 
    
     //if one input pin connected to one output pin, its value would be drawn to 0.
    int odd_correct = (odd_in != 0xaaaaaaaa) ? 1 : 0;  
                                                      
                                                      
    // set all pins to be outputs and restore 1 to all pins
    *(JP5_EXPANSION_ptr+1) = 0xffffffff;    
    *(JP5_EXPANSION_ptr) = 0xffffffff;    
    
    //set the odd-numbered pins to be the output pins and write 0 to all output pins
	*(JP5_EXPANSION_ptr+1) = 0xaaaaaaaa;       
    *(JP5_EXPANSION_ptr) = 0x0;    
    
    //read the input pins value
    volatile int even_in = *(JP5_EXPANSION_ptr);    
    
    //if one input pin connected to one output pin, its value would be drawn to 0.    
    int even_correct = (even_in != 0x55555555) ? 1 : 0; 

    //if both of input and output function correctly for the two pins, toggle the red LEDs
    LED_toggle = odd_correct && even_correct;
 
}
