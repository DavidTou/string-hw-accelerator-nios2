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
	logic [0:3] [7:0] A, B;
	logic [2:0] lengthA, lengthB;
	logic [0:3] [7:0] R;

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
		
/************** Test index 0 (string compare), inputs (abcd, abca)******************/
				A = "abcd";
				B = "acca";
				index = 0;
				go = 1;     #200;
				
				assert (R == 0) 
					$display("String Compare(%s,%s) == %0d PASSED",A,B,R);
				else 
					$display("String Compare(%s,%s) == %0d failed",A,B,R);
				
				go = 0;	#20;

			/************** Test index 0 (string compare), inputs (ab, ac)******************/
				A = "ab";
				B = "ac";
				index = 0;
				go = 1;     #200;
				
				assert (R == 0) 
					$display("String Compare(%s,%s) == %0d PASSED",A,B,R);
				else 
					$display("String Compare(%s,%s) == %0d failed",A,B,R);
				
				go = 0;	#20;
			
			
			/************** Test index 0 (string compare), inputs (abcd, abcd)******************/
				A = "abcd";
				B = "abcd";
				index = 0;
				go = 1;     #200;
				
				assert (R == 1) 
					$display("String Compare(%s,%s) == %0d PASSED",A,B,R);
				else 
					$display("String Compare(%s,%s) == %0d failed",A,B,R);
				
				go = 0;	#20;

			/************** Test index 0 (string compare), inputs (ab, ab)******************/
				A = "ab";
				B = "ab";
				index = 0;
				go = 1;     #200;
				
				assert (R == 1) 
					$display("String Compare(%s,%s) == %0d PASSED",A,B,R);
				else 
					$display("String Compare(%s,%s) == %0d failed",A,B,R);
				
				go = 0;	#20;
		
/************** Test index 1 (string To Upper), inputs (abcd)******************/
				A = "abcd";
				index = 1;  #20;
				go = 1;     #200;
				
				assert (R == "ABCD") 
					$display("String_To_Upper(%s) == %s PASSED", A, R);
				else 
					$display("Case String_To_Upper(%s) == %s failed", A, R);

				go = 0;	#20;

			/************** Test index 1 (string To Upper), inputs (ab)******************/ 
				A = "ab";
				index = 1;  #20;
				go = 1;     #200;
				
				assert (R == "AB") 
					$display("String_To_Upper(%s) == %s PASSED", A, R);
				else 
					$display("Case String_To_Upper(%s) == %s failed", A, R);

				go = 0;	#20;
				
		/************** Test index 1 (string To Upper), inputs (AbCd)******************/
				A = "AbCd";   
				index = 1;  #20;
				go = 1;     #200;
				
				assert (R == "ABCD") 
					$display("String_To_Upper(%s) == %s PASSED", A, R);
				else 
					$display("Case String_To_Upper(%s) == %s failed", A, R);

				go = 0;	#20;
				
			/************** Test index 1 (string To Upper), inputs (Ab)******************/
				A = "Ab";   
				index = 1;  #20;
				go = 1;     #200;
				
				assert (R == "AB") 
					$display("String_To_Upper(%s) == %s PASSED", A, R);
				else 
					$display("Case String_To_Upper(%s) == %s failed", A, R);

				go = 0;	#20;

/************** Test index 2 (string To Lower), inputs (ABCD)******************/ 
				A = "ABCD";   
				index = 2;  #20;
				go = 1;     #1000;
				
				assert (R == "abcd") 
					$display("String_To_Upper(%s) == %s PASSED", A, R);
				else 
					$display("Case String_To_Upper(%s) == %s failed", A, R);

				go = 0;	#20;
		
			/************** Test index 2 (string To Lower), inputs (AB)******************/ 
				A = "AB";   
				index = 2;  #20;
				go = 1;     #1000;
				
				assert (R == "ab") 
					$display("String_To_Upper(%s) == %s PASSED", A, R);
				else 
					$display("Case String_To_Upper(%s) == %s failed", A, R);

				go = 0;	#20;
				
			/************** Test index 2 (string To Lower), inputs (AbCd)******************/ 
				A = "AbCd";   
				index = 2;  #20;
				go = 1;     #200;
				
				assert (R == "abcd") 
					$display("String_To_Upper(%s) == %s PASSED", A, R);
				else 
					$display("Case String_To_Upper(%s) == %s failed", A, R);

				go = 0;	#20;

			/************** Test index 2 (string To Lower), inputs (Ab)******************/ 
				A = "Ab";   
				index = 2;  #20;
				go = 1;     #200;
				
				assert (R == "ab") 
					$display("String_To_Upper(%s) == %s PASSED", A, R);
				else 
					$display("Case String_To_Upper(%s) == %s failed", A, R);

				go = 0;	#20;
				
	end
	always  begin
		clk <= 1; #5;
		clk <= 0; #5;
	end

endmodule

