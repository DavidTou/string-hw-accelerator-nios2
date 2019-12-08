/* 
 * ###############################################################################
 * CPE423
 * Midterm - SW - HW Greatest Common Divisor
 * David Tougaw 
 * 10/15/2019
 * -----------------------------------------------
 * Greatest Common Divisor Comparison
 * SW and HW using NIOS 2
 * 32 bit integer inputs A and B
 * -----------------------------------------------
 * Dev BOARD => Altera DE2-115
 * DE2-115 Computer System + Custom GCD comp.
 * -----------------------------------------------
 * JTAG_UART used for terminal inputs and outputs
 * ------------------------------------------------------------------------------
 * ###############################################################################
 */
// include files
#include "address_map_nios2.h"

// needed for printf
#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define CLOCK_RATE 50000000.0
#define READ_STATUS_A *(String_HW_ptr)

#define BUFFER_SIZE 128

/* function prototypes */
char get_char( void );
uint32_t get_uint( void );
void put_char( char c );
uint32_t pow(uint32_t n, char p);
uint32_t stringToInt32bit(char buffer[],unsigned lastIndex);
unsigned int inputParamTerminal(char buffer[]);	              // Retrieves string input from terminal
void start_timer();
uint32_t snapshot_timer();
void get4Chars(char* string,char *out, int index);
void get4CharsInt(uint32_t value, char *out);
void pointer4CharsInt(uint32_t value, char * out);

// POINTERS
volatile uint32_t * TIMER_ptr = (uint32_t *)TIMER_BASE;
volatile uint32_t * String_HW_ptr = (uint32_t *)String_HW_BASE;

void main() {
	
	uint32_t ticksHW,ticksSW;

	while(1){
		// reset for next round
		ticksSW=0;
		ticksHW=0;
		printf("#### string.h vs String HW peripheral ####\n");
		
		char length = 12;		
		char out [4];				// temp var
		
		char str1[128] = "ABCD1234EFGH"; 	// double quotes add null terminator
		char str2[128]; 						// double quotes add null terminator
		char result_str[128];
		
		// WRITE 4 char blocks to HW module
		char k;
		//*(String_HW_ptr+2) = 0; 	// Dummy write to reset signals
		
		printf("Control/Status: %x\n",READ_STATUS_A);
		
		for(k=0; k < length/4; k++)
		{
			get4Chars(str1,out, k);
			*(String_HW_ptr + k + 1) = *((uint32_t *)(out));
			 printf("Write: %s \n",out);
			 //printf("Read: %s \tFIFO Size: %u \n",out, *(String_HW_ptr+2));
		}
		
		//*(String_HW_ptr);
		// PRINT TO CONSOLE INT TO CHAR
		printf("Control/Status: %x\n",READ_STATUS_A);
		for(k=0; k < length/4; k++)
		{
			uint32_t val;
			val = *(String_HW_ptr + k + 1);
			printf("Read HEX: %x \n",val);
		    printf("Read: ");
			putchar(val & 0x000000FF);
			putchar((val & 0x0000FF00) >> 8);
			putchar((val & 0x00FF0000) >> 16);
			putchar((val & 0xFF000000) >> 24);
			printf("\n");
		}

		printf("Any char to continue..");
		inputParamTerminal(str1);
		//printf("0^ 4 chars: %s\n",out);
		/*printf("String 1: ");
		inputParamTerminal(str1);
		get4Chars(str1,out, 0);
		*(String_HW_ptr) = (uint32_t) out;
		printf("FIFO Size: %x\n",READ_STATUS_A>> 28);
		printf("0^ 4 chars: %s\n",out);
		
		printf("AVALON read: %x\n",*(String_HW_ptr));

		get4Chars(str1,out, 1);
		*(String_HW_ptr) = (uint32_t) out;
		printf("FIFO Size: %x\n",READ_STATUS_A>> 28);
		printf("1^ 4 chars: %s\n",out);

		printf("AVALON read: %x\n",*(String_HW_ptr));

		get4Chars(str1,out, 2);
		*(String_HW_ptr) = (uint32_t) out;
		printf("FIFO Size: %x\n",READ_STATUS_A>> 28);
		printf("2^ 4 chars: %s\n",out);

		printf("AVALON read: %x\n",*(String_HW_ptr));
		//printf("String 2: ");
		//inputParamTerminal(str2);
		//*(String_HW_ptr)
		printf("AVALON: %x\n",*(String_HW_ptr));
		printf("AVALON: %x\n",*(String_HW_ptr));
		printf("AVALON: %x\n",*(String_HW_ptr));
		printf("AVALON: %x\n",*(String_HW_ptr));
		//strcpy(str1, "abcdef");
   		//strcpy(str2, "ABCDEF");
		*/
	}
}
/********************************************************************************
 * get4Chars(char index) 
 * index specifies 4 char blocks
********************************************************************************/
void get4Chars(char* string, char *out, int index)
{
	out[0]=string[0+4*index];
	out[1]=string[1+4*index];
	out[2]=string[2+4*index];
	out[3]=string[3+4*index];
}

/********************************************************************************
 * get4CharsInt(char index) 
********************************************************************************/
void get4CharsInt(uint32_t value, char *out)
{
	//char out [4];
	out[0]=(char)(value & 0xFF000000) >> 24;
	out[1]=(char)(value & 0x00FF0000) >> 16;
	out[2]=(char)(value & 0x0000FF00) >> 8;
	out[3]=(char)(value & 0x000000FF);
	//return (uint32_t)out;
}

/********************************************************************************
 * print4CharsInt(char index) 
********************************************************************************/
void pointer4CharsInt(uint32_t value, char * out)
{
	//char out [5];
	out[0]=(char)(value & 0xFF000000) >> 24;
	out[1]=(char)(value & 0x00FF0000) >> 16;
	out[2]=(char)(value & 0x0000FF00) >> 8;
	out[3]=(char)(value & 0x000000FF);
	out[4]=(char) 0x0A; // NULL CHAR
	//return out;
}


/********************************************************************************
 * inputParamTerminal Function 
********************************************************************************/
unsigned int inputParamTerminal(char buffer[])		// Retrieves string input from terminal
	{
		char in_char;
		unsigned int num, i;
		num = 0; i = 0;
		
		in_char = get_char();
		while(in_char != '\r' && in_char != '\n')	// Wait until character entered thats not ENTER
		{
			
			if (in_char != '\0')  	 // If not NULL,
			{
				if (in_char == 0x08) // backspace
				{
					if (i > 0)	// Only backspace if there are characters in buffer
					{
						i--;
						printf("%c",in_char);
						buffer[i] = 0x00; // Delete previous char from buffer (NUL character)
					}
				}
				else
				{
					if (i < BUFFER_SIZE)
					{
						printf("%c",in_char);
						buffer[i] = in_char; // Add char to buffer
						i++;				 // Increment counter
					}
				}
			}
			in_char = get_char();
		}
		return i; // return length of string
	}

/********************************************************************************
 * start_timer Function 
********************************************************************************/

void start_timer(){
	volatile int * TIMER_ptr = (int *)TIMER_BASE;
	*(TIMER_ptr + 2) = 0xFFFF;			// Reset timer to 0xFFFF
	*(TIMER_ptr + 1) = 0x4;				// Set start bit
}

/********************************************************************************
 * snapshot_timer Function 
********************************************************************************/

uint32_t snapshot_timer()
{
	*(TIMER_ptr + 4) = 0x1; //dummy write to snap_low
	return 0xFFFF - *(TIMER_ptr + 4);
}

/********************************************************************************
 * stringToInt32bit Function converts inputted string to uint32_teger 32 bit
********************************************************************************/

uint32_t stringToInt32bit(char buffer[],unsigned lastIndex)
{
	uint32_t n=0;
	int k;
	for(k=0; k<lastIndex;k++) {
		n+=(buffer[k]-0x30)*pow(10,lastIndex-k-1);	// ASCII to int
		buffer[k] = 0x00;							// clear buffer
	}
	
	return n;
}

/********************************************************************************
 * POW Function
********************************************************************************/

uint32_t pow(uint32_t base, char p)
{
	uint32_t result=1;
	char exp;
	for(exp=p; exp>0;exp--)
		result = result*base;
	
	return result;
}


/********************************************************************************
* Subroutine to read a character from the JTAG UART
* Returns \0 if no character, otherwise returns the character
********************************************************************************/
char get_char( void )
{
	volatile int * JTAG_UART_ptr = (int *) JTAG_UART_BASE; // JTAG UART address
	int data;
	data = *(JTAG_UART_ptr); // read the JTAG_UART data register
	if (data & 0x00008000) // check RVALID to see if there is new data
		return ((char) data & 0xFF);
	else
		return ('\0');
}

/********************************************************************************
* Subroutine to send a character to the JTAG UART
********************************************************************************/
void put_char( char c )
{
	volatile int * JTAG_UART_ptr = (int *) JTAG_UART_BASE; // JTAG UART address
	int control;
	control = *(JTAG_UART_ptr + 1); // read the JTAG_UART control register
	if (control & 0xFFFF0000) // if space, write character, else ignore
		*(JTAG_UART_ptr) = c;
}