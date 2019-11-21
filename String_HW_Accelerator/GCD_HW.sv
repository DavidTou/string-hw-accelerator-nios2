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

module GCD_HW (clock, resetn, opIn, loadA, loadB, outGCD, outDone,
// TESTBENCH LOGIC
 state, AA, BB);
	input clock,resetn;
	input loadA, loadB;
	input logic [31:0] opIn;
	output logic [31:0] outGCD,AA, BB;
	
	output logic outDone;
	output logic [2:0] state;
	// 32 bit operands
	logic [31:0] A, B;
	
	// GCD Calc values 
	integer unsigned a,b,k,x,gcd;
	
	// 32 bit result
	logic [31:0] OUT;
	
	// state definitions
	logic [2:0] currentState;
	// TESTBENCH
	assign state=currentState;

	assign AA=A;
	assign BB=B;

	parameter S0=3'b000, S1=3'b001, S2=3'b010,
				 S3=3'b011, S4=3'b111;
	// Done signal
	logic doneCalc, OUTPUT;
	
	assign outGCD = OUT;
	
	assign outDone = OUTPUT;
	
	always@(posedge clock) begin
			doneCalc=0;
			OUTPUT=0;
			if(!resetn) begin
				currentState=S0;
			end
			else
			case(currentState)
				// Initial state, Wait for A to be written
				S0: 	begin 
							// Load A 
							if(loadA) begin
								A = opIn;
								currentState=S1;
							end
							else
								currentState=S0;
						end
				// Wait for B to be written
				S1: 	begin 
							// Load B 
							if(loadB) begin
								B = opIn;
								currentState=S2;
							end
							else
								currentState=S1;
						end
							
				// INIT GCD
				S2:   begin 
							OUT=0;
							a=A;
							b=B;
							k=0;
							gcd=1;
							x=1;
							currentState=S3;
					end
				// Binary GCD - 32bit numbers
				S3:	begin
						// SAME => output one of them
						if(a==b)		begin
							doneCalc=1;
							gcd=a;
						end
						// 0 INPUT => output non-zero value
						else if((a==0)&&(b!=0)) begin
							doneCalc=1;
							gcd=b;
						end
						// 0 INPUT => output non-zero value
						else if((a!=0)&&(b==0)) begin
							doneCalc=1;
							gcd=a;
						end
						// EVEN INPUTS => Increment Common Factor
						else if((a[0]==0)&&(b[0]==0)) begin
							k=k+1;
							a=a>>1;
							b=b>>1;
						end
						// ODD/EVEN => Divide Even by 2
						else if((a[0]==1)&&(b[0]==0)) begin
							b=b>>1;
						end
						else if((a[0]==0)&&(b[0]==1)) begin
							a=a>>1;
						end
						// ODD INPUTS
						else if((a[0]==1)&&(b[0]==1)) begin
							if(a>=b) begin
								a=(a-b)/2;
								b=b;
							end
							else if(b>a) begin
								b=(b-a)/2;
								a=a;
							end
						end
					
						if(doneCalc)
							currentState=S4;
						else
							currentState=S3;
						end
				// DISPLAY
				S4:   begin 
					if(k>0)
						x=2<<(k-1);
					OUT = gcd*x;
					OUTPUT = 1;
					// go back and wait for new inputs
					currentState=S0;
				end
					
			endcase
	end

endmodule