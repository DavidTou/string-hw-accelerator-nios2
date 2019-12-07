/*
* ###############################################################################
* CPE423
* Assignment 4 - Greatest Common Divisor (GCD Hardware Test Bench)
* Matthew Bowen
* 10/18/2019
* --------------------------------------
* Greatest Common Divisor
* 32 bit integer inputs A and B
* --------------------------------------
* Dev BOARD => Altera DE2-115 and NIOS2
* --------------------------------------
* signals: reset, go, done, result
* ------------------------------------------------------------------------------
* After initial Reset, FSM will follow these steps:
* 0) RESET		=> Initialize all output values  
* 1) WAIT       => Wait for go signal to start computation (After User has passed input numbers)
* 2) GO         => Compute 32 bit GCD and store in result register 
* 3) AGAIN		=> Wait for again signal to restart the system to poll for new input operands
* ###############################################################################
*/
`timescale 1ps / 1ps

module String_HW_TB;			
	logic clk, reset, write, read,chipselect;
	logic [2:0] address;
	logic [31:0] writedata,readdata;
	logic [31:0]  R;
	
	String_HW_Avalon av (clk, reset, writedata, address, readdata, write, read, chipselect);
	
	initial
	begin
		// Reset inputs
		reset = 1;	#10;
		reset = 0;
		chipselect = 1; #10;
		
/************** Writing / Reading *****************/
		address=0;
		writedata = "abcd";
		write = 1;	#10;
		
		read = 0; write = 0;	#10;

		address=0;
		writedata = "1234";
		write = 1;		#10;

		read = 0; write = 0; 	#10;
		
		address=0;
		writedata = "5678";
		write = 1; #10;

		read = 0; write = 0;	#10;
		
		address=0; 
		read=1;					#5;
		R = readdata; 			#5;
		
		assert (R == "abcd") 
			$display("FIFO(%s) == %s PASSED", "abcd", R);
		else 
			$display("Case FIFO(%s) == %s failed", "abcd", R);
		
		read = 0; write = 0; 	#10;
		
		address=0; 
		read=1;					#5;
		R = readdata; 			#5;
		
		assert (R == "1234") 
			$display("FIFO(%s) == %s PASSED", "1234", R);
		else 
			$display("Case FIFO(%s) == %s failed", "1234", R);
			
		read = 0; write = 0; 	#10;
				
		address=0; 
		read=1;					#5;
		R = readdata; 			#5;
		
		assert (R == "5678") 
			$display("FIFO(%s) == %s PASSED", "5678", R);
		else 
			$display("Case FIFO(%s) == %s failed", "5678", R);
			
		read = 0; write = 0; 	#10;
	end
	always  begin
		clk <= 1; #5;
		clk <= 0; #5;
	end

endmodule

