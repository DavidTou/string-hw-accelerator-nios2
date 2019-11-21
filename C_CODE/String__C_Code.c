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

/* function prototypes */
unsigned int gcd_SW(unsigned int, unsigned int);
unsigned int gcd_HW(unsigned int, unsigned int);
char get_char( void );
unsigned int get_uint( void );
void put_char( char c );
unsigned int pow(unsigned int n, char p);
unsigned int stringToInt32bit(char buffer[],unsigned lastIndex);
unsigned int inputParamTerminal( char buffer []) ;
void start_timer();

// POINTERS
volatile int * TIMER_ptr = (int *)TIMER_BASE;
volatile int * GCD_HW_ptr = (int *)GCD_HW_32_BASE;

void main() {
	
	unsigned int opA,opB, GCD, ticksHW,ticksSW;
	char buffer [10];
	while(1){
		// reset for next round
		opA=0;
		opB=0;
		ticksSW=0;
		ticksHW=0;
		GCD = 0;
		printf("#### HW/SW GCD Comparison ####\n");
		printf("NOTE: Enter non-zero unsigned integers\n");
		// Terminal Prompt
		// Operand A
		printf("Insert opA: ");
		opA=inputParamTerminal(buffer);
		
		// Operand B
		printf("Insert opB: ");
		opB=inputParamTerminal(buffer);
		
		// ###### SOFTWARE ######
		// GCD SW calculation
		start_timer();
		GCD = gcd_SW(opA,opB);
		*(TIMER_ptr + 4) = 0x1; //dummy write to snap_low
		ticksSW = 0xFFFF - *(TIMER_ptr + 4);
		printf("SW_GCD = %d\n", GCD );		// Print Result to Terminal
		printf("SW_Clock Cycles = %d\n", ticksSW );
		// ###### END SOFTWARE ######
		GCD=0;
		// ###### HARDWARE ######
		
		//*(GCD_HW_ptr) = opA;
		start_timer();
		//*(GCD_HW_ptr+1) = opB;
		GCD = gcd_HW(opA,opB);
		// poll until bit 0 of address 2 is set to 1
		//while(!(*(GCD_HW_ptr+2) & 0x0001));
		//GCD = *(GCD_HW_ptr+3);
		*(TIMER_ptr + 4) = 0x1; //dummy write to snap_low
		ticksHW = 0xFFFF - *(TIMER_ptr + 4);
		printf("HW_GCD = %d\n", GCD );		// Print Result to Terminal
		printf("HW_Clock Cycles = %d\n", ticksHW );
		// ###### END HARDWARE ######
		printf("#### END HW/SW GCD Comparison ####\n");
		
	}
}
/********************************************************************************
 * inputParamTerminal Function 
********************************************************************************/
unsigned int inputParamTerminal( char buffer []) 
{
	unsigned char pos=0;
	char a;
	a=get_char();
	while(a != '\r' && a != '\n') // carriage return, new line
	{
		// if something inserted
		if(a!='\0'&& a!='\r' && a!='\n') {
			buffer[pos]=a;
			pos++;
			put_char(a);			// print ASCII number
		}
		a=get_char();
	}
	put_char(a);

	return stringToInt32bit(buffer,pos);
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
 * stringToInt32bit Function converts inputted string to unsigned integer 32 bit
********************************************************************************/

unsigned int stringToInt32bit(char buffer[],unsigned lastIndex)
{
	unsigned int n=0;
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

unsigned int pow(unsigned int base, char p)
{
	unsigned int result=1;
	char exp;
	for(exp=p; exp>0;exp--)
		result = result*base;
	
	return result;
}

/********************************************************************************
 * GCD HARWARE Function
********************************************************************************/

unsigned int gcd_HW(unsigned int opA, unsigned int opB)
{
	unsigned int GCD=0;
	// WRITE Operands to Avalon Interface
	*(GCD_HW_ptr) = opA;
	*(GCD_HW_ptr+1) = opB;
	// Poll until bit 0 of Control_Register(address 2) is set to 1
	while(!(*(GCD_HW_ptr+2) & 0x0001));
	GCD = *(GCD_HW_ptr+3);
	return GCD;
}

/********************************************************************************
 * GCD SOFTWARE Algorithm Function
********************************************************************************/

unsigned int gcd_SW(unsigned int m, unsigned int n)
{
	unsigned int temp;
	if (n > m)
	{
		temp = m;
		m = n;
		n = temp;
	}
	while (n != 0)
	{
		temp = m % n; // Remeinder
		m = n;
		n = temp;
	}
	return m;
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