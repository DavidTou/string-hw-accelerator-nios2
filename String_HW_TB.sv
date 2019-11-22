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
	logic clk, reset, go, done;
	logic [2:0] index;
	logic [0:1] [7:0] A, B;
	logic [1:0] lengthA, lengthB;
	logic [0:1] [7:0] R;

	String_HW dut(.clk(clk),
		.reset(reset),
		.go(go),
		.index(index),
		.A(A), 
		.B(B),
		.lengthA(lengthA),
		.lengthB(lengthB),
		.done(done),
		.result(R)
		);
	
	initial
	begin
		// Reset inputs
		reset = 1;	#20;
		reset = 0;
		
/************** Test index 0 (string compare), inputs (8, 6)******************/ 
		A = 8'd8;
		B = 8'd6;
		index = 0;
		go = 1;     #200;
		
		assert (R == 0) 
			$display("String_Compare(%0d,%0d) == %0d PASSED",8,6,0);
		else 
			$display("Case GCD A = %0d B = %0d, R = %0d failed",A[0],B[0],R);
		
		go = 0;	#20;
	
/************** Test index 0 (string compare), inputs (8, 8)******************/ 
		A = 8'd8;
		B = 8'd8;
		index = 0;  #20;
	    go = 1;     #200;
		
		assert (R == 1) 
			$display("String_Compare(%0d,%0d) == %0d PASSED",8,8,1);
		else 
			$display("Case GCD A = %0d B = %0d, R = %0d failed",A[0],B[0],R);

		go = 0;	#20;
		
/************** Test index 1 (string To Upper), inputs (ab)******************/ 
		A[0] = 8'd97;	// 'a'
		A[1] = 8'd98;   // 'b'
		lengthA = 2;
		index = 1;  #20;
	    go = 1;     #200;
		
		assert (R[0] == 65 && R[1] == 66) 
			$display("String_To_Upper(%0d %0d) == %0d %0d PASSED",97,98, 65, 66);
		else 
			$display("Case GCD A = %0d B = %0d, R = %0d %0d failed",97,96, R[0],R[1]);

		go = 0;	#20;
	end

	always  begin
		clk <= 1; #5;
		clk <= 0; #5;
	end

endmodule

