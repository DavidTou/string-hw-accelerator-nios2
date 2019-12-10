/* 
 * ###############################################################################
 * CPE423
 * String_HW 
 * David Tougaw and Matthew Bowen
 * 11/24/2019
 * --------------------------------------
 * String.h Hardware Accelerator +
 * --------------------------------------
 * Dev BOARD => Altera DE2-115
 * ------------------------------------------------------------------------------
 * 0) Wait for go
 * 1) Go to string function depending on index value
 * 2) Perform Computation
 * 3) Wait in Done state until go bit reset
 * ###############################################################################
 */
module String_HW #(MAX_BLOCKS = 2)
			  (input logic clk, reset, go,
			   input logic [3:0]  index,
			   input logic [7:0] length,
			   input logic [0:MAX_BLOCKS*4-1][7:0] A, B,	
			   output logic done,
			   output logic [0:MAX_BLOCKS*4-1][7:0] Result
			  );
	parameter RESET=4'd0, S1=4'd1, S2=4'd2,
				 S3=4'd3, S4=4'd4, S5=4'd5,
				 S6=4'd6, S7=4'd7, S8=4'd8,
				 S9=4'd9, DONE =4'd10;

	logic [3:0] state, nextstate;
	logic found;
	integer i, j, count, string_index;	// Counter variables
	
	always_ff @(posedge clk)
		if (reset) state <= RESET;		// synchronous Reset
		else state <= nextstate;
	
	always@(posedge clk) begin
			case(state)
				// RESET State
				RESET: 	begin 
							done <= 0;					// Reset done flag
							nextstate <= S1;			// Go to wait state
							count <= 0;					// Reset count
							Result <= '{default:8'h0};	// Reset result
						end	
				// Wait for go signal
				S1: begin 
						done <= 0;						// Reset done flag
						i <= 0;							// Reset counter i
						j <= 0;							// Reset counter j
						found <= 0;						// Reset found flag
						Result <= '{default:8'h0};		// Reset result
						if (go)
							nextstate <= S2;			// Go flag set, go to Function Selection
						else							
							nextstate <= S1;			// Wait for go
					end

				// Read index for computation
				S2: begin 
						case (index)
								0: nextstate <= S3;		// String Compare
								1: nextstate <= S4; 	// String To Upper
								2: nextstate <= S5; 	// String To Lower
								3: nextstate <= S6;		// String Reverse
								4: nextstate <= S7;		// String Search
						  default: nextstate <= RESET; 	// Invalid index
						endcase
					end
					
				// String Compare [index = 0]
				S3:	begin
						if (A == B)
							Result <= 1;				// Strings Equal, return 1
						else
							Result <= 0;				// Strings Not Equal, return 0
								
						nextstate <= DONE;				
				
					end
		
				// String To Upper [index = 1]
				S4: begin
						for (i = 0; i < MAX_BLOCKS*4; i = i+1) 
							if (A[i] >= "a" && A[i] <= "z") // if character is lowercase
								Result[i] <= A[i] - 32;		// Convert to uppercase
							else
								Result[i] <= A[i];			// Unchanged
				
						nextstate <= DONE;
					end
					
				// String to Lower [index = 2]
				S5: begin
						for (i = 0; i < MAX_BLOCKS*4; i = i+1) 
							if (A[i] >= "A" && A[i] <= "Z") // if character is uppercase
								Result[i] <= A[i] + 32;		// Convert to lowercase
							else
								Result[i] <= A[i];			// Unchanged
				
						nextstate <= DONE;
					end
					
				// String Reverse [index = 3]
				S6: begin
						for (i = 0; i < MAX_BLOCKS*4; i = i+1) 
							Result[i] <= A[MAX_BLOCKS*4-1 - i];	// Reverse String
							
						nextstate <= DONE;
					end
					
				// String Search [index = 4]
				S7: begin
						if (found) begin
							Result <= string_index; 	// String found, assign Result = string starting location
							nextstate <= DONE;			// Go to Done state
							end
						else
							Result <= 256;				// Default "Not Found" value
						
						if (i < MAX_BLOCKS*4 && ~found) begin	
							if (B[j] == A[i]) begin
								if (j == 0)				// First character correct
									string_index <= i;	// Mark starting location of string
								j <= j + 1;				// Increment j for every correct character in sequence
								
								if (j == length-1)		// If number of correct characters in sequence = length
									found <= 1;			// String has been found
							end
							else
								j = 0;					// If character in sequence is incorrect, reset sequence counter j
							
							i <= i + 1;					// Go to next character in string
						end
						else 
							nextstate <= DONE;
					end
					
				// DONE State. 
			  DONE: begin
						done <= 1;						// Done flag set
						
						// Wait until go signal is deasserted 
						if (~go)	
							nextstate <= S1;			// Go to Wait state
						else 
							nextstate <= DONE;			// Stay in Done state
					end
			
		       default: nextstate <= RESET;
			endcase
		end
endmodule