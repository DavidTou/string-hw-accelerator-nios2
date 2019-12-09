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
 * 2) Perform 1 clock cycle computation
 * 3) Wait in Done state until go bit reset
 * ###############################################################################
 */
parameter MAX_BLOCKS=8;	// Max number of characters
module String_HW (input logic clk, reset, go,
			   input logic [3:0]  index,
			   input logic [0:MAX_BLOCKS*4-1][7:0] A, B,
			   output logic done,
			   output logic [0:MAX_BLOCKS*4-1][7:0] Result
			  );
	parameter RESET=4'd0, S1=4'd1, S2=4'd2,
				 S3=4'd3, S4=4'd4, S5=4'd5,
				 S6=4'd6, S7=4'd7, S8=4'd8,
				 S9=4'd9, DONE =4'd10;

	logic [3:0] state, nextstate;
	integer i, count;
	
	always_ff @(posedge clk)
		if (reset) state <= RESET;		// synchronous Reset
		else state <= nextstate;
	
	always@(posedge clk) begin
			case(state)
				// RESET State
				RESET: 	begin 
							done <= 0;
							nextstate <= S1;
							count <= 0;
							Result <= '{default:8'h0};
						end	
				// Wait for go signal
				S1: begin 
						done <= 0;
						Result <= '{default:8'h0};
						if (go)
							nextstate <= S2;
						else
							nextstate <= S1;
					end

				// Read index for computation
				S2: begin 
						case (index)
								0: nextstate <= S3;		// String Compare
								1: nextstate <= S4; 	// String To Upper
								2: nextstate <= S5; 	// String To Lower
						  default: nextstate <= RESET; 	// Invalid index
						endcase
					end
					
				// String Compare [index = 0]
				S3:	begin
						if (A == B)
							Result[0] <= 1;
						else
							Result[0] <= 0;
								
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
				/* String Reverse [index = 3]
				S6: begin
						for (i = 0; i < 4; i = i+1) 
							if (A[i] >= "A" && A[i] <= "Z") // if character is uppercase
								Result[i] <= A[i] + 32;		// Convert to lowercase
							else
								Result[i] <= A[i];			// Unchanged
				
						nextstate <= DONE;
					end
				*/
				// DONE State. 
			  DONE: begin
						done <= 1;
						// Wait until go signal is deasserted 
						if (~go)	
							nextstate <= S1;
						else 
							nextstate <= DONE;
					end
			
		       default: nextstate <= RESET;
			endcase
		end
endmodule