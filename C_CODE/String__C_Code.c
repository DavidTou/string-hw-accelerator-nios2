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
#define BUFFER_SIZE 64

#define READ_CONTROL_STATUS *(String_HW_ptr)
#define WRITE_CONTROL_STATUS *(String_HW_ptr)
#define CLEAR_CONTROL_STATUS *(String_HW_ptr) = 0;

#define MAX_BLOCKS 8
// INDEXES
#define TEST -13
#define COMPARE 0
#define TOUPPER 1
#define TOLOWER 2
#define REVERSE 3
#define SEARCH  4

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
void clearTerminal();
void SwapValue(char *a, char *b);

void stringHWCall(uint32_t index,char* stringA,char* stringB, char length);

/* String HW prototypes */
uint32_t stringHW_ToUpper(uint32_t A);
uint32_t stringHW_ToLower(uint32_t A);
uint32_t stringHW_compare(uint32_t A, uint32_t B);

/* String SW prototypes */
void strToUpper(char* string, int length);
void strToLower(char* string, int length);
void strReverse(char* string, char length);

// POINTERS
volatile uint32_t * TIMER_ptr = (uint32_t *)TIMER_BASE;
volatile uint32_t * String_HW_ptr = (uint32_t *)String_HW_BASE;


char length = 64;
char test[65] = "lylatagssongdamptynecapebarnflowonceafanjohnleadkokodirtgeekhaul"; 	// double quotes add null terminator
char cmp_1 [33] = 	"LYLA----------------------------";
char cmp_2 [33] = 	"LYLA----LYLA----LYLA----LYLA----";

char str1_UPPER[33] = "LYLAtagsSONGdamptyneCAPEBARNflow";

void main() {
	
	uint32_t ticksHW,ticksSW;
	
	while(1){
		char str1[33] = "lylatagssongdamptynecapebarnflow"; 	// double quotes add null terminator
		char str2[33] = "onceafanjohnleadkokodirtgeekhaul"; 	// double quotes add null terminator
		char out [4];				// temp var
		// reset for next round
		ticksSW=0;
		ticksHW=0;
		printf("\n#### string.h vs String HW + peripheral ####\n");
		printf("####    BY D. Tougaw & Matthew Bowen    ####\n");
		printf("%-7s%-25s\n", "Index", "Function"); 
		printf("%-7s%-25s\n", "#", "TEST READ/WRITE AVALON"); 
		printf("%-7s%-25s\n", "0", "Compare"); 
		printf("%-7s%-25s\n", "1", "ToUpper");
		printf("%-7s%-25s\n", "2", "ToLower"); 
		printf("%-7s%-25s\n", "3", "Reverse"); 
		printf("%-7s%-25s\n", "4", "Search"); 
		printf("Select function [Index]: ");
		inputParamTerminal(out);
		putchar('\n');
		// input ASCII to number
		char index = out[0] - 48;
		switch(index) {
			case TEST: {
				printf("\n#### TEST READ/WRITE AVALON ####\n");
				// WRITE 4 char blocks to HW module
				char k;
				printf("Control/Status: %x\n",READ_CONTROL_STATUS);
				
				for(k=0; k < length/4; k++)
				{
					get4Chars(test,out, k);
					*(String_HW_ptr + k + 1) = *((uint32_t *)(out));
					if((k+1) <= 8)
						printf("Write A: %s \n",out);
					else
						printf("Write B: %s \n",out);
				}
				
				WRITE_CONTROL_STATUS = 0xFEED0000;
				printf("WRITE Control/Status: %x\n",0xFEED0000);
				
				// PRINT TO CONSOLE INT TO CHAR
				printf("Control/Status: %x\n",READ_CONTROL_STATUS);
				for(k=0; k < length/4; k++)
				{
					uint32_t val;
					val = *(String_HW_ptr + k + 1);
					//printf("Read HEX: %x \n",val);
					if((k+1) <= 8)
						printf("Read A: ");
					else
						printf("Read B: ");
					putchar(val & 0x000000FF);
					putchar((val & 0x0000FF00) >> 8);
					putchar((val & 0x00FF0000) >> 16);
					putchar((val & 0xFF000000) >> 24);
					putchar('\n');
				}
				CLEAR_CONTROL_STATUS;
			}break;
			case COMPARE: {
					printf("=========== StringCompare(str1, str2) ===========\n");
					char k;
					for(k=0; k < MAX_BLOCKS; k++)
					{
						get4Chars(cmp_1,out, k);
						*(String_HW_ptr + k + 1) = *((uint32_t *)(out));
						//printf("WRITE A: %s \n",out);
					}
					printf("String A: %s \n",cmp_1);
					printf("String B: %s \n",cmp_2);
					for(k=0; k < MAX_BLOCKS; k++)
					{
						get4Chars(cmp_1,out, k);
						*(String_HW_ptr + k + MAX_BLOCKS + 1) = *((uint32_t *)(out));
						//printf("WRITE B: %s \n",out);
					}
					// WRITE INDEX and GO BIT
					for(k=0; k < MAX_BLOCKS+MAX_BLOCKS; k++)
					{
						uint32_t val;
						val = *(String_HW_ptr + k + 1);
						printf("Read [%d]: ",(k+1));
						
						putchar(val & 0x000000FF);
						putchar((val & 0x0000FF00) >> 8);
						putchar((val & 0x00FF0000) >> 16);
						putchar((val & 0xFF000000) >> 24);
						putchar('\n');
					}
					inputParamTerminal(str2);
					start_timer();
					WRITE_CONTROL_STATUS = 0b00010;	// index = 0, go = 1
					
					while(!(READ_CONTROL_STATUS & 1));
					
					ticksHW = snapshot_timer();
					
					uint32_t resHW = *(String_HW_ptr + 8);
					
					for(k=0; k < MAX_BLOCKS; k++)
					{
						uint32_t val;
						val = *(String_HW_ptr + k + 1);
						printf("Read Res [%d]: ",(k+1));
						
						putchar(val & 0x000000FF);
						putchar((val & 0x0000FF00) >> 8);
						putchar((val & 0x00FF0000) >> 16);
						putchar((val & 0xFF000000) >> 24);
						putchar('\n');
					}
					
					CLEAR_CONTROL_STATUS;
					
					start_timer();
					uint32_t resSW = strcmp(str1,str1);
					ticksSW = snapshot_timer();
				/********* StringCompare Display Code **********/
					printf("=========== StringCompare(str1, str2) ===========\n");
					//printf("Software strcmp(%s, %s) = ",str1, str1);
					if (!resSW)	printf("SW EQUAL \n");
					else		printf("SW NOT EQUAL \n");
					//printf("Hardware strcmp(%s, %s) = ",str1, str1);
					if (resHW)	printf("HW EQUAL \n");
					else		printf("HW NOT EQUAL \n");
					printf("Software CC = %-8d ET = %-5f us\n",ticksSW,ticksSW/CLOCK_RATE*1000000);
					printf("Hardware CC = %-8d ET = %-5f us\n",ticksHW,ticksHW/CLOCK_RATE*1000000);
					printf("Speedup = %-8f\n",ticksSW/ticksHW*1.0);
					printf("=================================================\n");
				
			}break;
			case TOUPPER: {
				
				printf("=========== StringToUpper(str) ===========\n");
				char k;
				for(k=0; k < MAX_BLOCKS; k++)
				{
					get4Chars(str1,out, k);
					*(String_HW_ptr + k + 1) = *((uint32_t *)(out));
				}
				printf("String A: %s \n",str1);
				// WRITE INDEX and GO BIT
				start_timer();
				WRITE_CONTROL_STATUS = ((uint32_t) index << 2) | 2;
				
				while(!(READ_CONTROL_STATUS & 1));
				
				ticksHW = snapshot_timer();
				
				start_timer();
				strToUpper(str1,32);
				ticksSW = snapshot_timer();
				
				for(k=0; k < MAX_BLOCKS; k++)
				{
					uint32_t val;
					val = *(String_HW_ptr + k + 1);
					printf("Read A: ");
					
					putchar(val & 0x000000FF);
					putchar((val & 0x0000FF00) >> 8);
					putchar((val & 0x00FF0000) >> 16);
					putchar((val & 0xFF000000) >> 24);
					putchar('\n');
				}
				CLEAR_CONTROL_STATUS;
				/************* String to Upper Display Code ***************/
				
				printf("=========== StringToUpper(str) ===========\n");
				//printf("Software strToUpper(%s) = %s \n",str1, str2);
				//printf("Hardware strToUpper(%s) = %s \n",str1, result_str);
				printf("Software CC = %-8d ET = %-5f us\n",ticksSW,ticksSW/CLOCK_RATE*1000000);
				printf("Hardware CC = %-8d ET = %-5f us\n",ticksHW,ticksHW/CLOCK_RATE*1000000);
				printf("Speedup = %-8f\n",ticksSW/ticksHW*1.0);
				printf("=================================================\n");
				
			}break;
			case TOLOWER: {
				printf("=========== StringToLower(str) ===========\n");
				char k;
				for(k=0; k < MAX_BLOCKS; k++)
				{
					get4Chars(str1_UPPER,out, k);
					*(String_HW_ptr + k + 1) = *((uint32_t *)(out));
				}
				printf("String A: %s \n",str1_UPPER);
				// WRITE INDEX and GO BIT
				start_timer();
				WRITE_CONTROL_STATUS = ((uint32_t) index << 2) | 2;
				
				while(!(READ_CONTROL_STATUS & 1));
				
				ticksHW = snapshot_timer();
				
				start_timer();
				strToLower(str1,32);
				ticksSW = snapshot_timer();
				
				for(k=0; k < MAX_BLOCKS; k++)
				{
					uint32_t val;
					val = *(String_HW_ptr + k + 1);
					printf("Read A: ");
					
					putchar(val & 0x000000FF);
					putchar((val & 0x0000FF00) >> 8);
					putchar((val & 0x00FF0000) >> 16);
					putchar((val & 0xFF000000) >> 24);
					putchar('\n');
				}
				CLEAR_CONTROL_STATUS;
				/************ String to Lower Display Code *************/
				
					printf("=========== StringToLower(str) ===========\n");
					//printf("Software strToLower(%s) = %s \n",str1, str2);
					//printf("Hardware strToLower(%s) = %s \n",str1, result_str);
					printf("Software CC = %-8d ET = %-5f us\n",ticksSW,ticksSW/CLOCK_RATE*1000000);
					printf("Hardware CC = %-8d ET = %-5f us\n",ticksHW,ticksHW/CLOCK_RATE*1000000);
					printf("Speedup = %-8f\n",ticksSW/ticksHW*1.0);
					printf("=================================================\n");
				
			}break;
			case REVERSE: {
				printf("=========== Reverse(str) ===========\n");
				char k;
				for(k=0; k < MAX_BLOCKS; k++)
				{
					get4Chars(str1_UPPER,out, k);
					*(String_HW_ptr + k + 1) = *((uint32_t *)(out));
				}
				printf("String A: %s \n",str1_UPPER);
				// WRITE INDEX and GO BIT
				start_timer();
				WRITE_CONTROL_STATUS = ((uint32_t) index << 2) | 2;
				
				while(!(READ_CONTROL_STATUS & 1));
				
				ticksHW = snapshot_timer();
				
				// SW
				start_timer();
				strReverse(str1_UPPER,32);
				ticksSW = snapshot_timer();
				printf("String A SW Reversed: %s \n",str1_UPPER);
				for(k=0; k < MAX_BLOCKS; k++)
				{
					uint32_t val;
					val = *(String_HW_ptr + k + 1);
					printf("Read A: ");
					
					putchar(val & 0x000000FF);
					putchar((val & 0x0000FF00) >> 8);
					putchar((val & 0x00FF0000) >> 16);
					putchar((val & 0xFF000000) >> 24);
					putchar('\n');
				}
				CLEAR_CONTROL_STATUS;
				/************ String to Lower Display Code *************/
				
					printf("=========== Reverse(str) ===========\n");
					//printf("Software strToLower(%s) = %s \n",str1, str2);
					//printf("Hardware strToLower(%s) = %s \n",str1, result_str);
					printf("Software CC = %-8d ET = %-5f us\n",ticksSW,ticksSW/CLOCK_RATE*1000000);
					printf("Hardware CC = %-8d ET = %-5f us\n",ticksHW,ticksHW/CLOCK_RATE*1000000);
					printf("Speedup = %-8f\n",ticksSW/ticksHW*1.0);
					printf("=================================================\n");
			}break;
			case SEARCH: {
				printf("=========== Search(strA,strB) ===========\n");
				char k;
				for(k=0; k < MAX_BLOCKS; k++)
				{
					get4Chars(str1_UPPER,out, k);
					*(String_HW_ptr + k + 1) = *((uint32_t *)(out));
				}
				printf("String A: %s \n",str1_UPPER);
				//char find [4]= {'S','O','N','G'};
				char find [4]= {'G','N','O','S'};
				//char find [4] = "SONG";
				
				get4Chars(find,out, 0);
				printf("String B: %s \n",out);
				*(String_HW_ptr + 1) = *((uint32_t *)(out));
				
				// WRITE INDEX and GO BIT
				uint32_t len = 32;
				start_timer();
				
				WRITE_CONTROL_STATUS = (len << 6) |((uint32_t) index << 2) | 2;
				
				while(!(READ_CONTROL_STATUS & 1));
				
				ticksHW = snapshot_timer();
				
				start_timer();
				char res;
				if(strstr(str1, find) != NULL)
					// get offset in bytes
					res = strstr(str1, find);
				else
					res = 0;
				ticksSW = snapshot_timer();
				
				
				printf("SW: %d\n",res);
				uint32_t resHW;
				resHW = *(String_HW_ptr + 1);
				printf("HW: %d\n",resHW);
				
				CLEAR_CONTROL_STATUS;
				/************ String to Lower Display Code *************/
				
					printf("=========== Search(strA,strB) ===========\n");
					if (res>0)	printf("SW FOUND at pos: %d \n",res);
					else		printf("SW NOT FOUND \n");
					//printf("Hardware strcmp(%s, %s) = ",str1, str1);
					if (resHW != 0xFF)	printf("HW FOUND at pos: %d \n",resHW);
					else		printf("HW NOT FOUND \n");
					//printf("Software strToLower(%s) = %s \n",str1, str2);
					//printf("Hardware strToLower(%s) = %s \n",str1, result_str);
					printf("Software CC = %-8d ET = %-5f us\n",ticksSW,ticksSW/CLOCK_RATE*1000000);
					printf("Hardware CC = %-8d ET = %-5f us\n",ticksHW,ticksHW/CLOCK_RATE*1000000);
					printf("Speedup = %-8f\n",ticksSW/ticksHW*1.0);
					printf("=================================================\n");
			}break;
			
			default: {
				printf("\nOption not handled.\n");
			}break;
			
		}
		
		printf("Any char to continue..");
		inputParamTerminal(str2);
		clearTerminal();
	}
}


/********************************************************************************
 * StringCompare Function converts inputted string to uint32_teger 32 bit
********************************************************************************/
uint32_t stringHW_compare(uint32_t A, uint32_t B)
{
	uint32_t result;
	*(String_HW_ptr) = A;
	*(String_HW_ptr+1) = B;
	
	*(String_HW_ptr+2) = 0b00010;	// index = 0, go = 1
	
	while((*(String_HW_ptr+2) & 0b01) != 0b01);	// wait for done
	result = *(String_HW_ptr+3);				// store result
	
	*(String_HW_ptr+2) = 0;		// reset go bit
	
	return result;
}

/********************************************************************************
 * StringToUpper Function converts inputted string to uint32_teger 32 bit
********************************************************************************/
uint32_t stringHW_ToUpper(uint32_t A)
{
	
	uint32_t result;
	*(String_HW_ptr) = A;
	*(String_HW_ptr+2) = 0b00110;	// index = 1, go = 1
	
	while((*(String_HW_ptr+2) & 0b01) != 0b01);	// wait for done
	result = *(String_HW_ptr+3);				// store result
	
	*(String_HW_ptr+2) = 0;		// reset go bit
	
	return result;
}

/********************************************************************************
 * StringToLower Function converts inputted string to uint32_teger 32 bit
********************************************************************************/
uint32_t stringHW_ToLower(uint32_t A)
{
	uint32_t result;
	*(String_HW_ptr) = A;
	
	*(String_HW_ptr+2) = 0b01010;	// index = 2, go = 1
	
	while((*(String_HW_ptr+2) & 0b01) != 0b01);	// wait for done
	result = *(String_HW_ptr+3);				// store result
	
	*(String_HW_ptr+2) = 0;		// reset go bit
	
	return result;
}

/********************************************************************************
 * StringReverse Function reverses string
********************************************************************************/
void strReverse(char* string, char length)
{
	// Swap character starting from two 
    // corners 
    for (int i = 0; i < length / 2; i++) 
        SwapValue(&string[i], &string[length - i - 1]); 
}

/********************************************************************************
 * StringToUpper Function converts inputted string to uint32_teger 32 bit
********************************************************************************/
void strToUpper(char* string, int length)
{
	for (int i = 0; i < length; i++)
		if (string[i] >= 'a' && string[i] <= 'z')
			string[i] -= 32;
}

/********************************************************************************
 * StringToLower Function converts inputted string to uint32_teger 32 bit
********************************************************************************/
void strToLower(char* string, int length)
{
	char result[4];
	for (int i = 0; i < length; i++)
		if (string[i] >= 'A' && string[i] <= 'Z')
			string[i] += 32;
}

/********************************************************************************
 * SwapValue Function 
********************************************************************************/

void SwapValue(char *a, char *b) {
   char t = *a;
   *a = *b;
   *b = t;
}

/********************************************************************************
 * clearTerminal()
********************************************************************************/
void clearTerminal()
{
	putchar(0x1B);
	putchar('[');
	putchar('2');
	putchar('J');
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