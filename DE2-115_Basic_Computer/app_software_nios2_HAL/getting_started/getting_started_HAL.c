#include "altera_up_avalon_parallel_port.h"
/* This program demonstrates use of parallel ports in the DE2-115 board
 *
 * It performs the following: 
 * 	1. displays the SW switch values on the red LEDR
 * 	2. displays the KEY[3..1] pushbutton values on the green LEDG
 * 	3. displays a rotating pattern on the HEX displays
 * 	4. if KEY[3..1] is pressed, uses the SW switches as the pattern
*/
int main(void)
{
	/* Declare volatile pointers to I/O registers (volatile means that IO load
	 * and store instructions will be used to access these pointer locations, 
	 * instead of regular memory loads and stores)
	*/
	alt_up_parallel_port_dev * red_LED_ptr 	= alt_up_parallel_port_open_dev ("/dev/Red_LEDs");
	alt_up_parallel_port_dev * green_LED_ptr	= alt_up_parallel_port_open_dev ("/dev/Green_LEDs");
	alt_up_parallel_port_dev * HEX3_HEX0_ptr	= alt_up_parallel_port_open_dev ("/dev/HEX3_HEX0");
	alt_up_parallel_port_dev * HEX7_HEX4_ptr	= alt_up_parallel_port_open_dev ("/dev/HEX7_HEX4");
	alt_up_parallel_port_dev * SW_switch_ptr	= alt_up_parallel_port_open_dev ("/dev/Slider_Switches");
	alt_up_parallel_port_dev * KEY_ptr			= alt_up_parallel_port_open_dev ("/dev/Pushbuttons");

	int HEX_bits = 0x0000000F;					// pattern for HEX displays
	int SW_value, KEY_value;
	volatile int delay_count;					// volatile so the C compiler doesn't remove the loop

	while(1)
	{
		SW_value = alt_up_parallel_port_read_data(SW_switch_ptr);	// read the SW slider switch values
        alt_up_parallel_port_write_data(red_LED_ptr, SW_value);		// light up the red LEDs

		KEY_value = alt_up_parallel_port_read_data(KEY_ptr); 		// read the pushbutton KEY values
		alt_up_parallel_port_write_data(green_LED_ptr, KEY_value);	// light up the green LEDs
        
		if (KEY_value != 0)						// check if any KEY was pressed
		{
			HEX_bits = SW_value;					// set pattern using SW values
			while (alt_up_parallel_port_read_data(KEY_ptr));						// wait for pushbutton KEY release
		}
        
		alt_up_parallel_port_write_data(HEX3_HEX0_ptr, HEX_bits);	// display pattern on HEX3 ... HEX0
		alt_up_parallel_port_write_data(HEX7_HEX4_ptr, HEX_bits);			// display pattern on HEX7 ... HEX4

		/* rotate the pattern shown on the HEX displays */
		if (HEX_bits & 0x80000000)
			HEX_bits = (HEX_bits << 1) | 1;
		else
			HEX_bits = HEX_bits << 1;

		for (delay_count = 10000; delay_count != 0; --delay_count); // delay loop
	}
}