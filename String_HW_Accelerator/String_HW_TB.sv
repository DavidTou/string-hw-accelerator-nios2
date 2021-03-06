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
 
`timescale 1ps / 1ps
parameter MAX_BLOCKS = 2;

module String_HW_TB;			
	logic clk, reset, go, done;
	logic [3:0] index;
	logic [7:0] length;
	logic [0:MAX_BLOCKS*4-1] [7:0] A, B, R;

	String_HW dut(.clk(clk),
		.reset(reset),
		.go(go),
		.index(index),
		.length(length),
		.A(A), 
		.B(B),
		.done(done),
		.Result(R)
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
			
			
			/************** Test index 0 (string compare), inputs (abcdefgh, abcdefgh)******************/
				A = "abcdefgh";
				B = "abcdefgh";
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
		
/************** Test index 1 (string To Upper), inputs (abcdefgh)******************/
				A = "abcdefgh";
				index = 1;  #20;
				go = 1;     #200;
				
				assert (R == "ABCDEFGH") 
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
				
		/************** Test index 1 (string To Upper), inputs (AbCdef)******************/
				A = "AbCdef";   
				index = 1;  #20;
				go = 1;     #200;
				
				assert (R == "ABCDEF") 
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

/************** Test index 2 (string To Lower), inputs (ABCDEFGH)******************/ 
				A = "ABCDEFGH";   
				index = 2;  #20;
				go = 1;     #1000;
				
				assert (R == "abcdefgh") 
					$display("String_To_Lower(%s) == %s PASSED", A, R);
				else 
					$display("Case String_To_Lower(%s) == %s failed", A, R);

				go = 0;	#20;
		
			/************** Test index 2 (string To Lower), inputs (AB)******************/ 
				A = "AB";   
				index = 2;  #20;
				go = 1;     #1000;
				
				assert (R == "ab") 
					$display("String_To_Lower(%s) == %s PASSED", A, R);
				else 
					$display("Case String_To_Lower(%s) == %s failed", A, R);

				go = 0;	#20;
				
			/************** Test index 2 (string To Lower), inputs (AbCdEf)******************/ 
				A = "AbCdEf";   
				index = 2;  #20;
				go = 1;     #200;
				
				assert (R == "abcdef") 
					$display("String_To_Lower(%s) == %s PASSED", A, R);
				else 
					$display("Case String_To_Lower(%s) == %s failed", A, R);

				go = 0;	#20;

			/************** Test index 2 (string To Lower), inputs (Ab)******************/ 
				A = "Ab";   
				index = 2;  #20;
				go = 1;     #200;
				
				assert (R == "ab") 
					$display("String_To_Lower(%s) == %s PASSED", A, R);
				else 
					$display("Case String_To_Lower(%s) == %s failed", A, R);

				go = 0;	#20;
				
/************** Test index 3 (string Reverse), inputs (Hello!)******************/ 
				A = "Hello!  ";   
				index = 3;  #20;
				go = 1;     #200;
				
				assert (R == "  !olleH") 
					$display("StringReverse(%s) == %s PASSED", A, R);
				else 
					$display("Case String_To_Lower(%s) == %s failed", A, R);

				go = 0;	#20;
				
			/************** Test index 3 (string Reverse), inputs (!olleH)******************/ 
				A = "  !olleH";   
				index = 3;  #20;
				go = 1;     #200;
				
				assert (R == "Hello!  ") 
					$display("StringReverse(%s) == %s PASSED", A, R);
				else 
					$display("Case String_To_Lower(%s) == %s failed", A, R);

				go = 0;	#20;
				
/************** Test index 4 (string Search), inputs (It was I) Find (It) ******************/ 
				A = "It was I";
				B = "It      ";
				length = 2;
				index = 4;  #20;
				go = 1;     #200;
				
				assert (R == 0) 
					$display("StringSearch(%s, %s) == %0d PASSED", A, B, R);
				else 
					$display("Case StringSearch(%s, %s) == %0d failed", A, B, R);

				go = 0;	#20;

			/************** Test index 4 (string Search), inputs (It was I) Find (was) ******************/ 
				A = "It was I";
				B = "was     ";
				length = 3;
				index = 4;  #20;
				go = 1;     #200;
				
				assert (R == 3) 
					$display("StringSearch(%s, %s) == %0d PASSED", A, B, R);
				else 
					$display("Case StringSearch(%s, %s) == %0d failed", A, B, R);

				go = 0;	#20;

			/************** Test index 4 (string Search), inputs (It was I) Find ("I") ******************/ 
				A = "It was I";
				B = " I      ";
				length = 2;
				index = 4;  #20;
				go = 1;     #200;
				
				assert (R == 6) 
					$display("StringSearch(%s, %s) == %0d PASSED", A, B, R);
				else 
					$display("Case StringSearch(%s, %s) == %0d failed", A, B, R);

				go = 0;	#20;
			
			$stop;
				
	end
	always  begin
		clk <= 1; #5;
		clk <= 0; #5;
	end

endmodule

