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

module GCD_HW (input logic clk, reset, go,
			   input logic [2:0]  index,
			   input logic  [7:0] [5:0] A,
			   output logic [7:0] [5:0] B,
			   output logic done
			  );

	parameter RESET=3'b000, S1=3'b001, S2=3'b010,
				 S3=3'b011, S4=3'b100, S5=3'b101,
				 S6=3'b110, DONE =3'b111;

	logic [2:0] state, nextstate;
	
	integer memory_index_0, memory_index_1;
	
	always_ff @(posedge clk)
		if (reset) state <= RESET;		// Asynchronous Reset
		else state <= nextstate;
	
	always@(posedge clk) begin
			case(state)
				// RESET State
				RESET: 	begin 
							done <= 0;
							FIFO_write <= 0;
							memory_index_0 <= 0;
							memory_index_1 <= 0;
							nextstate <= S1;
						end
				
						end
							
				// Read index for computation
				S2:   	begin 
							if (index == 3'd0)
								nextstate <= S3;
							else if (index == 3'd1)
								nextstate <= S4;
							else 
								nextstate <= S2;	// error, no valid index
						end
				// String Compare [index = 0]
				S3:	begin
						nextstate <= DONE;
					end
						
				// Sring Command [index = 1]
				S4: begin
						nextstate <= DONE;
					end
				// DONE State. 
			  DONE: begin
						nextstate <= S1;
					end
			
		       default: nextstate <= RESET;
			endcase
	end

endmodule