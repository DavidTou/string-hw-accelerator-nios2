/* 
 * ###############################################################################
 * CPE423
 * String Hardware Avalon INTERFACE--------------------
 * David Tougaw and Matthew Bowen
 * 11/21/2019
 * --------------------------------------
 * 32 bit integer inputs A and B
 * --------------------------------------
 * Dev BOARD => Altera DE2-115
 * ------------------------------------------------------------------------------
 * --------AVALON INTERFACE--------------------
 * ======String HW Accelerator==================
 *   	   32 bit registers
 *	|----Register 0 (Control)---|
 *	|----Register 1-7  (A)------|
 *	|----Register 8-15 (B)------|
 *	
 *	|------------(Control Register)--------------|
 *	   length[13:7], index[6:2], go[1], done[0]
 *
 * ###############################################################################
 */

`timescale 1ps / 1ps

parameter MAX_BLOCKS = 2, ADDRESS_BITS = 5;

module String_HW_Avalon_TB;			
	logic clk, reset, read, write, chipselect;
	logic [ADDRESS_BITS:0] address;
	logic [31:0] writedata, readdata, control;
	logic [0:MAX_BLOCKS-1] [31:0] A, B, R;

	String_HW_Avalon dut(.clk(clk),
						 .reset(reset),
						 .read(read),
						 .write(write),
						 .chipselect(chipselect),
					     .address(address),
						 .writedata(writedata),
						 .readdata(readdata)
						);
	
	initial
	begin
		
		// Reset and initialize values
		reset = 1;	   #20;
		reset = 0;	   #20;
		chipselect = 1;
		write = 0;read = 0; #20;
		
		
/************** Test index 0 (string compare), inputs (abcdefgh, abcdefgh)******************/
			A = 0;
			B = 0;
			
		// Write string A to Register A
			address = 1;	    	
			writedata = "abcd";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
			address = 2;	    	
			writedata = "efgh";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
		
		// Read string A from Register A
			address = 1;	
			read = 1;			#20;
			A[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
			
			address = 2;	
			read = 1;			#20;
			A[1] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
		
		// Write string B to Register B
			address = 3;	    	
			writedata = "abcd";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
			address = 4;	    	
			writedata = "efgh";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
		
		// Read string B from Register B
			address = 3;	
			read = 1;			#20;
			B[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
			
			address = 4;	
			read = 1;			#20;
			B[1] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
		
		// Write 0 to index and set go bit to Control Register
		address = 0;		
		writedata = 32'b000_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #20;	
		
		// Read register 2 (control)
		address = 0;		
		read = 1;			#20;
		control = readdata; #20;	
		
		write = 0;read = 0; #20;
		
		// Read register A (Result)
			address = 1;  
			read = 1;	  #20;
			R[0] = readdata; #20;			
			
			write = 0;read = 0; #20; 

			address = 2;  
			read = 1;	  #20;
			R[1] = readdata; #20;			
			
			write = 0;read = 0; #20; 
		
		assert (R == 1) 
			$display("String Compare(%s,%s) == %0d PASSED",A,B,R);
		else 
			$display("String Compare(%s,%s) == %0d failed",A,B,R);
	
		// reset go bit to register 2 (Control)
		address = 0; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
/************** Test index 0 (string compare), inputs (abcdefgh, abcdabcd)******************/
			A = 0;
			B = 0;
			
		// Write string A to Register A
			address = 1;	    	
			writedata = "abcd";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
			address = 2;	    	
			writedata = "efgh";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
		
		// Read string A from Register A
			address = 1;	
			read = 1;			#20;
			A[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
			
			address = 2;	
			read = 1;			#20;
			A[1] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
		
		// Write string B to Register B
			address = 3;	    	
			writedata = "abcd";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
			address = 4;	    	
			writedata = "abcd";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
		
		// Read string B from Register B
			address = 3;	
			read = 1;			#20;
			B[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
			
			address = 4;	
			read = 1;			#20;
			B[1] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
		
		// Write 0 to index and set go bit to Control Register
		address = 0;		
		writedata = 32'b000_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #20;	
		
		// Read register 2 (control)
		address = 0;		
		read = 1;			#20;
		control = readdata; #20;	
		
		write = 0;read = 0; #20;
		
		// Read register A (Result)
			address = 1;  
			read = 1;	  #20;
			R[0] = readdata; #20;			
			
			write = 0;read = 0; #20; 

			address = 2;  
			read = 1;	  #20;
			R[1] = readdata; #20;			
			
			write = 0;read = 0; #20; 
		
		assert (R == 0) 
			$display("String Compare(%s,%s) == %0d PASSED",A,B,R);
		else 
			$display("String Compare(%s,%s) == %0d failed",A,B,R);
			
	
		// reset go bit to register 2 (Control)
		address = 0; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
/************** Test index 0 (string compare), inputs (abc, abc)******************/
			A = 0;
			B = 0;
			
		// Write string A to Register A
			address = 1;	    	
			writedata = "abc";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
		
		// Read string A from Register A
			address = 1;	
			read = 1;			#20;
			A[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
		
		// Write string B to Register B
			address = 3;	    	
			writedata = "abc";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
		
		// Read string B from Register B
			address = 3;	
			read = 1;			#20;
			B[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;		
		
		// Write 0 to index and set go bit to Control Register
		address = 0;		
		writedata = 32'b000_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #20;	
		
		// Read register 2 (control)
		address = 0;		
		read = 1;			#20;
		control = readdata; #20;	
		
		write = 0;read = 0; #20;
		
		// Read register A (Result)
			address = 1;  
			read = 1;	  #20;
			R[0] = readdata; #20;			
			
			write = 0;read = 0; #20; 

			address = 2;  
			read = 1;	  #20;
			R[1] = readdata; #20;			
			
			write = 0;read = 0; #20; 
		
		assert (R == 1) 
			$display("String Compare(%s,%s) == %0d PASSED",A,B,R);
		else 
			$display("String Compare(%s,%s) == %0d failed",A,B,R);
			
	
		// reset go bit to register 2 (Control)
		address = 0; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
/************** Test index 1 (string To Upper), inputs (abcdefgh)******************/
	
			A = 0;
			B = 0;
			
		// Write string A to Register A
			address = 1;	    	
			writedata = "abcd";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
			address = 2;	    	
			writedata = "efgh";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
		
		// Read string A from Register A
			address = 1;	
			read = 1;			#20;
			A[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
			
			address = 2;	
			read = 1;			#20;
			A[1] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
		
		// Write 1 to index and set go bit to Control Register
		address = 0;		
		writedata = 32'b001_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #20;	
		
		// Read register 2 (control)
		address = 0;		
		read = 1;			#20;
		control = readdata; #20;	
		
		write = 0;read = 0; #20;
		
		// Read register A (Result)
			address = 1;  
			read = 1;	  #20;
			R[0] = readdata; #20;			
			
			write = 0;read = 0; #20; 

			address = 2;  
			read = 1;	  #20;
			R[1] = readdata; #20;			
			
			write = 0;read = 0; #20; 
		
		assert (R == "ABCDEFGH") 
			$display("String_To_Upper(%s) == %s PASSED", A, R);
		else 
			$display("Case String_To_Upper(%s) == %s failed", A, R);
	
		// reset go bit to register 2 (Control)
		address = 0; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
/************** Test index 1 (string To Upper), inputs (AbCdEf)******************/
	
		A = 0;
		B = 0;
			
		// Write string A to Register A
			address = 1;	    	
			writedata = "AbCd";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
			address = 2;	    	
			writedata = "Ef  ";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
		
		// Read string A from Register A
			address = 1;	
			read = 1;			#20;
			A[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
			
			address = 2;	
			read = 1;			#20;
			A[1] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
		
		// Write 1 to index and set go bit to Control Register
		address = 0;		
		writedata = 32'b001_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #20;	
		
		// Read register 2 (control)
		address = 0;		
		read = 1;			#20;
		control = readdata; #20;	
		
		write = 0;read = 0; #20;
		
		// Read register A (Result)
			address = 1;  
			read = 1;	  #20;
			R[0] = readdata; #20;			
			
			write = 0;read = 0; #20; 

			address = 2;  
			read = 1;	  #20;
			R[1] = readdata; #20;			
			
			write = 0;read = 0; #20; 
		
		assert (R == "ABCDEF  ") 
			$display("String_To_Upper(%s) == %s PASSED", A, R);
		else 
			$display("Case String_To_Upper(%s) == %s failed", A, R);
	
		// reset go bit to register 2 (Control)
		address = 0; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
/************** Test index 2 (string To Lower), inputs (ABCDEFGH)******************/
	
			A = 0;
			B = 0;
			
		// Write string A to Register A
			address = 1;	    	
			writedata = "ABCD";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
			address = 2;	    	
			writedata = "EFGH";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
		
		// Read string A from Register A
			address = 1;	
			read = 1;			#20;
			A[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
			
			address = 2;	
			read = 1;			#20;
			A[1] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
		
		// Write 2 to index and set go bit to Control Register
		address = 0;		
		writedata = 32'b010_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #20;	
		
		// Read register 2 (control)
		address = 0;		
		read = 1;			#20;
		control = readdata; #20;	
		
		write = 0;read = 0; #20;
		
		// Read register A (Result)
			address = 1;  
			read = 1;	  #20;
			R[0] = readdata; #20;			
			
			write = 0;read = 0; #20; 

			address = 2;  
			read = 1;	  #20;
			R[1] = readdata; #20;			
			
			write = 0;read = 0; #20; 
		
		assert (R == "abcdefgh") 
			$display("String_To_Lower(%s) == %s PASSED", A, R);
		else 
			$display("Case String_To_Lower(%s) == %s failed", A, R);
	
		// reset go bit to register 2 (Control)
		address = 0; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
/************** Test index 2 (string To Lower), inputs (AbCdE)******************/
	
		A = 0;
		B = 0;
			
		// Write string A to Register A
			address = 1;	    	
			writedata = "AbCd";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
			address = 2;	    	
			writedata = "E   ";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
		
		// Read string A from Register A
			address = 1;	
			read = 1;			#20;
			A[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
			
			address = 2;	
			read = 1;			#20;
			A[1] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
		
		// Write 2 to index and set go bit to Control Register
		address = 0;		
		writedata = 32'b010_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #20;	
		
		// Read register 2 (control)
		address = 0;		
		read = 1;			#20;
		control = readdata; #20;	
		
		write = 0;read = 0; #20;
		
		// Read register A (Result)
			address = 1;  
			read = 1;	  #20;
			R[0] = readdata; #20;			
			
			write = 0;read = 0; #20; 

			address = 2;  
			read = 1;	  #20;
			R[1] = readdata; #20;			
			
			write = 0;read = 0; #20; 
		
		assert (R == "abcde   ") 
			$display("String_To_Lower(%s) == %s PASSED", A, R);
		else 
			$display("Case String_To_Lower(%s) == %s failed", A, R);
	
		// reset go bit to register 2 (Control)
		address = 0; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;
	
/************** Test index 3 (string Reverse), inputs (Hello!)******************/
	
		A = 0;
		B = 0;
			
		// Write string A to Register A
			address = 1;	    	
			writedata = "Hell";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
			address = 2;	    	
			writedata = "o!  ";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
		
		// Read string A from Register A
			address = 1;	
			read = 1;			#20;
			A[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
			
			address = 2;	
			read = 1;			#20;
			A[1] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
		
		// Write 2 to index and set go bit to Control Register
		address = 0;		
		writedata = 32'b011_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #20;	
		
		// Read register 2 (control)
		address = 0;		
		read = 1;			#20;
		control = readdata; #20;	
		
		write = 0;read = 0; #20;
		
		// Read register A (Result)
			address = 1;  
			read = 1;	  #20;
			R[0] = readdata; #20;			
			
			write = 0;read = 0; #20; 

			address = 2;  
			read = 1;	  #20;
			R[1] = readdata; #20;			
			
			write = 0;read = 0; #20; 
		
		assert (R == "  !olleH") 
			$display("StringReverse(%s) == %s PASSED", A, R);
		else 
			$display("Case String_To_Lower(%s) == %s failed", A, R);
	
		// reset go bit to register 2 (Control)
		address = 0; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;	
		
		/************** Test index 3 (string Reverse), inputs (  !olleH)******************/
	
		A = 0;
		B = 0;
			
		// Write string A to Register A
			address = 1;	    	
			writedata = "  !o";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
			address = 2;	    	
			writedata = "lleH";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
		
		// Read string A from Register A
			address = 1;	
			read = 1;			#20;
			A[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
			
			address = 2;	
			read = 1;			#20;
			A[1] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
		
		// Write 2 to index and set go bit to Control Register
		address = 0;		
		writedata = 32'b011_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #20;	
		
		// Read register 2 (control)
		address = 0;		
		read = 1;			#20;
		control = readdata; #20;	
		
		write = 0;read = 0; #20;
		
		// Read register A (Result)
			address = 1;  
			read = 1;	  #20;
			R[0] = readdata; #20;			
			
			write = 0;read = 0; #20; 

			address = 2;  
			read = 1;	  #20;
			R[1] = readdata; #20;			
			
			write = 0;read = 0; #20; 
		
		assert (R == "Hello!  ") 
			$display("StringReverse(%s) == %s PASSED", A, R);
		else 
			$display("Case String_To_Lower(%s) == %s failed", A, R);
	
		// reset go bit to register 2 (Control)
		address = 0; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;	
		
/************** Test index 4 (string Search), inputs (It was I), find(It)******************/ 
	
		A = 0;
		B = 0;
			
		// Write string A to Register A
			address = 1;	    	
			writedata = "It w";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
			address = 2;	    	
			writedata = "as I";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
		
		// Read string A from Register A
			address = 1;	
			read = 1;			#20;
			A[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
			
			address = 2;	
			read = 1;			#20;
			A[1] = readdata; 	#20;	
			
			write = 0;read = 0; #20;

		// Write string B to Register B
			address = 3;	    	
			writedata = "It  ";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
		// Read string B from Register B
			address = 3;	
			read = 1;			#20;
			B[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
		
		// Write 2 to length, 4 to index, and set go bit to Control Register
		address = 0;		
		writedata = 32'b10_0100_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #200;	
		
		// Read register 2 (control)
		address = 0;		
		read = 1;			#20;
		control = readdata; #20;	
		
		write = 0;read = 0; #20;
		
		// Read register A (Result)
			address = 1;  
			read = 1;	  #20;
			R[0] = readdata; #20;			
			
			write = 0;read = 0; #20; 

			address = 2;  
			read = 1;	  #20;
			R[1] = readdata; #20;			
			
			write = 0;read = 0; #20; 
		
		assert (R == 0) 
			$display("StringSearch(%s, %s) == %0d PASSED", A, B, R);
		else 
			$display("Case StringSearch(%s, %s) == %0d failed", A, B, R);
	
		// reset go bit to register 2 (Control)
		address = 0; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;	

		/************** Test index 4 (string Search), inputs (It was I) Find (was) ******************/ 
	
		// Write string A to Register A
		A = 0;
		B = 0;
			
		// Write string A to Register A
			address = 1;	    	
			writedata = "It w";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
			address = 2;	    	
			writedata = "as I";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
		
		// Read string A from Register A
			address = 1;	
			read = 1;			#20;
			A[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
			
			address = 2;	
			read = 1;			#20;
			A[1] = readdata; 	#20;	
			
			write = 0;read = 0; #20;

		// Write string B to Register B
			address = 3;	    	
			writedata = "was ";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
		// Read string B from Register B
			address = 3;	
			read = 1;			#20;
			B[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
		
		// Write 3 to length, 4 to index, and set go bit to Control Register
		address = 0;		
		writedata = 32'b011_0100_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #200;	
		
		// Read register 2 (control)
		address = 0;		
		read = 1;			#20;
		control = readdata; #20;	
		
		write = 0;read = 0; #20;
		
		// Read register A (Result)
			address = 1;  
			read = 1;	  #20;
			R[0] = readdata; #20;			
			
			write = 0;read = 0; #20; 

			address = 2;  
			read = 1;	  #20;
			R[1] = readdata; #20;			
			
			write = 0;read = 0; #20; 
		
		assert (R == 3) 
			$display("StringSearch(%s, %s) == %0d PASSED", A, B, R);
		else 
			$display("Case StringSearch(%s, %s) == %0d failed", A, B, R);
	
		// reset go bit to register 2 (Control)
		address = 0; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;		
		
	/************** Test index 4 (string Search), inputs (It was I) Find ("I") ******************/ 
	
		// Write string A to Register A
		A = 0;
		B = 0;
			
		// Write string A to Register A
			address = 1;	    	
			writedata = "It w";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
			address = 2;	    	
			writedata = "as I";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
		
		// Read string A from Register A
			address = 1;	
			read = 1;			#20;
			A[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
			
			address = 2;	
			read = 1;			#20;
			A[1] = readdata; 	#20;	
			
			write = 0;read = 0; #20;

		// Write string B to Register B
			address = 3;	    	
			writedata = " I  ";  #20;	
			write = 1;			 #20;
			
			write = 0;read = 0;  #20;
			
		// Read string B from Register B
			address = 3;	
			read = 1;			#20;
			B[0] = readdata; 	#20;	
			
			write = 0;read = 0; #20;	
		
		// Write 2 to length, 4 to index, and set go bit to Control Register
		address = 0;		
		writedata = 32'b010_0100_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #200;	
		
		// Read register 2 (control)
		address = 0;		
		read = 1;			#20;
		control = readdata; #20;	
		
		write = 0;read = 0; #20;
		
		// Read register A (Result)
			address = 1;  
			read = 1;	  #20;
			R[0] = readdata; #20;			
			
			write = 0;read = 0; #20; 

			address = 2;  
			read = 1;	  #20;
			R[1] = readdata; #20;			
			
			write = 0;read = 0; #20; 
		
		assert (R == 6) 
			$display("StringSearch(%s, %s) == %0d PASSED", A, B, R);
		else 
			$display("Case StringSearch(%s, %s) == %0d failed", A, B, R);
	
		// reset go bit to register 2 (Control)
		address = 0; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;		

	$stop;
	end

	always
	begin
		clk <= 1; #5;
		clk <= 0; #5;
	end

endmodule
