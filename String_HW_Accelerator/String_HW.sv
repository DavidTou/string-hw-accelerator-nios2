/* 
 * ###############################################################################
 * CPE423
 * Greatest Common Divisor
 * David Tougaw 
 * 10/15/2019
 * --------------------------------------
 * Greatest Common Calculator
 * 32 bit integer inputs A and B
 * --------------------------------------
 * Dev BOARD => Altera DE2-115
 * ------------------------------------------------------------------------------
 * -----------AVALON INTERFACE--------------------
 * ============== 32 bit GCD HW ==================
 *   	   32 bit registers
 *	|----Register 0 (A)---------|
 *	|----Register 1 (B)---------|
 *	|----Register 2 (Control)---|
 *	|----Register 3 (GCD)-------|
 * ------------------------------------------------------------------------------
 * 0) LoadA => load 32 bit A
 * 1) LoadB => load 32 bit B and start calculation
 * 2) Output result and done signal
 * ###############################################################################
 */

module String_HW (input logic clk, reset, go,
			   input logic [2:0]  index,
			   input logic [0:1] [7:0] A, B,
			   input logic [1:0] lengthA, lengthB,
			   output logic done,
			   output logic [0:1][7:0] result
			  );

	parameter RESET=3'b000, S1=3'b001, S2=3'b010,
				 S3=3'b011, S4=3'b100, S5=3'b101,
				 S6=3'b110, DONE =3'b111;

	logic [2:0] state, nextstate;
	integer count;
	
	always_ff @(posedge clk)
		if (reset) state <= RESET;		// Asynchronous Reset
		else state <= nextstate;
	
	always@(posedge clk) begin
			case(state)
				// RESET State
				RESET: 	begin 
							done <= 0;
							nextstate <= S1;
							count <= 0;
							result <= 0;
						end	
				// Wait for go signal
				S1: begin 
						done <= 0;
						result <= 0;
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
							result <= 1;	// equal
						else
							result <= 0;	// not equal
						nextstate <= DONE;
					end
						
				// Sring To Upper [index = 1]
				S4: begin
						// if character is lowercase
						if (count < lengthA) begin
							if ((A[count] >= "a") && (A[count] <= "z"))
								result[count] = A[count] - 32;
							else
								result[count] = A[count];
								
							count = count + 1;	// Increment element counter
							nextstate = S4;
							end
						else begin
							count = 0;
							nextstate = DONE;
						end
					end
				// String to Lower [index = 2]
				S5: begin
						// if character is uppercase
						if (count < lengthA) begin
							if ((A[count] >= "A") && (A[count] <= "Z"))
								result[count] = A[count] + 32;
							else
								result[count] = A[count];
								
							count = count + 1;	// Increment element counter
							nextstate = S5;
							end
						else begin
							count = 0;
							nextstate = DONE;
						end
					end
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