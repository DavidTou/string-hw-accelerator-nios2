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
parameter MAX_WORDS = 8;

module String_HW_TB;			
	logic clk, reset, go, done;
	logic [2:0] index;
	logic [0:MAX_WORDS-1] [7:0] A, B, R;
	logic [2:0] length;

	String_HW dut(.clk(clk),
		.reset(reset),
		.go(go),
		.index(index),
		.A(A), 
		.B(B),
		.length(length),
		.done(done),
		.result(R)
		);
	
	initial
	begin
		// Reset inputs
		reset = 1;	#20;
		reset = 0;
		
/************** Test index 0 (string compare), inputs (abcdefgh, abcadead)******************/
				A = "abcdefgh";
				B = "abcadead";
				index = 0;
				go = 1;     #200;
				
				assert (R == 0) 
					$display("String Compare(%0s,%0s) == %0d PASSED",A,B,R);
				else 
					$display("String Compare(%0s,%0s) == %0d failed",A,B,R);
				
				go = 0;	#20;

			/************** Test index 0 (string compare), inputs (ab, ac)******************/
				A = "ab";
				B = "ac";
				index = 0;
				go = 1;     #200;
				
				assert (R == 0) 
					$display("String Compare(%0s,%0s) == %0d PASSED",A,B,R);
				else 
					$display("String Compare(%0s,%0s) == %0d failed",A,B,R);
				
				go = 0;	#20;
			
			
			/************** Test index 0 (string compare), inputs (abcdefgh, abcdefgh)******************/
				A = "abcdefgh";
				B = "abcdefgh";
				index = 0;
				go = 1;     #200;
				
				assert (R == 1) 
					$display("String Compare(%0s,%0s) == %0d PASSED",A,B,R);
				else 
					$display("String Compare(%0s,%0s) == %0d failed",A,B,R);
				
				go = 0;	#20;

			/************** Test index 0 (string compare), inputs (ab, ab)******************/
				A = "ab";
				B = "ab";
				index = 0;
				go = 1;     #200;
				
				assert (R == 1) 
					$display("String Compare(%0s,%0s) == %0d PASSED",A,B,R);
				else 
					$display("String Compare(%0s,%0s) == %0d failed",A,B,R);
				
				go = 0;	#20;
		
/************** Test index 1 (string To Upper), inputs (abcdefgh)******************/
				A = "abcdefgh";
				index = 1;  #20;
				go = 1;     #200;
				
				assert (R == "ABCDEFGH") 
					$display("String_To_Upper(%0s) == %0s PASSED", A, R);
				else 
					$display("Case String_To_Upper(%0s) == %0s failed", A, R);

				go = 0;	#20;

			/************** Test index 1 (string To Upper), inputs (ab)******************/ 
				A = "ab";
				index = 1;  #20;
				go = 1;     #200;
				
				assert (R == "AB") 
					$display("String_To_Upper(%0s) == %0s PASSED", A, R);
				else 
					$display("Case String_To_Upper(%0s) == %0s failed", A, R);

				go = 0;	#20;
				
		/************** Test index 1 (string To Upper), inputs (AbCdef)******************/
				A = "AbCdef";   
				index = 1;  #20;
				go = 1;     #200;
				
				assert (R == "ABCDEF") 
					$display("String_To_Upper(%0s) == %0s PASSED", A, R);
				else 
					$display("Case String_To_Upper(%0s) == %0s failed", A, R);

				go = 0;	#20;
				
			/************** Test index 1 (string To Upper), inputs (Ab)******************/
				A = "Ab";   
				index = 1;  #20;
				go = 1;     #200;
				
				assert (R == "AB") 
					$display("String_To_Upper(%0s) == %0s PASSED", A, R);
				else 
					$display("Case String_To_Upper(%0s) == %0s failed", A, R);

				go = 0;	#20;

/************** Test index 2 (string To Lower), inputs (ABCDEFGH)******************/ 
				A = "ABCDEFGH";   
				index = 2;  #20;
				go = 1;     #1000;
				
				assert (R == "abcdefgh") 
					$display("String_To_Lower(%0s) == %0s PASSED", A, R);
				else 
					$display("Case String_To_Lower(%0s) == %0s failed", A, R);

				go = 0;	#20;
		
			/************** Test index 2 (string To Lower), inputs (AB)******************/ 
				A = "AB";   
				index = 2;  #20;
				go = 1;     #1000;
				
				assert (R == "ab") 
					$display("String_To_Lower(%0s) == %0s PASSED", A, R);
				else 
					$display("Case String_To_Lower(%0s) == %0s failed", A, R);

				go = 0;	#20;
				
			/************** Test index 2 (string To Lower), inputs (AbCdEf)******************/ 
				A = "AbCdEf";   
				index = 2;  #20;
				go = 1;     #200;
				
				assert (R == "abcdef") 
					$display("String_To_Lower(%0s) == %0s PASSED", A, R);
				else 
					$display("Case String_To_Lower(%0s) == %0s failed", A, R);

				go = 0;	#20;

			/************** Test index 2 (string To Lower), inputs (Ab)******************/ 
				A = "Ab";   
				index = 2;  #20;
				go = 1;     #200;
				
				assert (R == "ab") 
					$display("String_To_Lower(%0s) == %0s PASSED", A, R);
				else 
					$display("Case String_To_Lower(%0s) == %0s failed", A, R);

				go = 0;	#20;
			
			$stop;
				
	end
	always  begin
		clk <= 1; #5;
		clk <= 0; #5;
	end

endmodule

