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
#include "nios2_ctrl_reg_macros.h"

// needed for printf
#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define CLOCK_RATE 50000000.0

/* function prototypes */
char get_char( void );
uint32_t get_uint( void );
void put_char( char c );
uint32_t pow(uint32_t n, char p);
uint32_t stringToInt32bit(char buffer[],unsigned lastIndex);
void inputParamTerminal( char buffer []) ;
void start_timer();
uint32_t snapshot_timer();
void get4Chars(char* string,char *out, int index);

// POINTERS
volatile int * TIMER_ptr = (int *)TIMER_BASE;
volatile int * String_HW_ptr = (int *)String_HW_BASE;

void main() {
	
	uint32_t ticksHW,ticksSW;
	//while(1){
		// reset for next round
		ticksSW=0;
		ticksHW=0;
		printf("#### string.h vs String HW peripheral ####\n");
		
		char str1[128]; 		// double quotes add null terminator
		char str2[128]; 		// double quotes add null terminator
		char out [4];
		printf("String 1: ");
		inputParamTerminal(str1);
		get4Chars(str1,out, 0);
		*(String_HW_ptr) = (uint32_t) out;
		printf("0^ 4 chars: %s\n",out);
		
		printf("0^ chars read: %s\n",*(String_HW_ptr));

		get4Chars(str1,out, 1);
		*(String_HW_ptr) = (uint32_t) out;
		printf("1^ 4 chars: %s\n",out);

		get4Chars(str1,out, 2);
		*(String_HW_ptr) = (uint32_t) out;
		printf("2^ 4 chars: %s\n",out);

		//printf("String 2: ");
		//inputParamTerminal(str2);
		printf("4 chars read: %s\n",*((char* )String_HW_ptr));
		printf("4 chars read: %s\n",*(String_HW_ptr));
		printf("4 chars read: %s\n",*(String_HW_ptr));
		//strcpy(str1, "abcdef");
   		//strcpy(str2, "ABCDEF");

		start_timer();
		int ret = strcmp(str1,str2);
		ticksHW = snapshot_timer();
		
		printf("=========== strcmp(str1,str2) ===========\n");
		if(ret == 0) printf("Result = EQUAL\n"); else printf("Result = NOT EQUAL\n");
		printf("CC     = %-10d\n",ticksHW);
		printf("ET (s) = %-10f\n",ticksHW/CLOCK_RATE);
		printf("=========================================\n");
		
}
/********************************************************************************
 * get4Chars(char index) 
 * index specifies 4 char blocks
********************************************************************************/
void get4Chars(char* string,char *out, int index)
{
	//char out [4];
	out[0]=string[0+4*index];
	out[1]=string[1+4*index];
	out[2]=string[2+4*index];
	out[3]=string[3+4*index];
	//return (uint32_t)out;
}


/********************************************************************************
 * inputParamTerminal Function 
********************************************************************************/
void inputParamTerminal( char buffer []) 
{
	unsigned char pos=0;
	char a;
	a=get_char();
	while(a != '\r' && a != '\n' & pos<128) // carriage return, new line
	{
		// if something inserted
		if(a!='\0'&& a!='\r' && a!='\n') {
			buffer[pos]=a;
			pos++;
			put_char(a);			// print ASCII number
		}
		else if(a == '\r')
			pos--;
		
		a=get_char();
	}
	if(pos==128)
		put_char('\n');
	put_char(a);
	// add null char
	buffer[pos] = '\0';
	return;
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