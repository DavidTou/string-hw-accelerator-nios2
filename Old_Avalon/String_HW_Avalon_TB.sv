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
 *	|----Register 0 (A)---------|
 *	|----Register 1 (B)---------|
 *	|----Register 2 (Control)---|
 *	|----Register 3 (Result)----|
 *	
 *	
 *	|----(Control Register)---|
 *	   [length,index,go,done]
 *	
 * ------------------------------------------------------------------------------
 * 0) LoadA => load 32 bit A
 * 1) LoadB => load 32 bit B and start calculation
 * 2) Output result and done signal
 * ###############################################################################
 */

`timescale 1ps / 1ps

module String_HW_Avalon_TB;			
	logic clk, reset, read, write, chipselect;
	logic [2:0] address;
	logic [31:0] writedata, readdata, control;
	
	logic go, done;
	logic [2:0] index;
	logic [0:3] [7:0] A, B, R;
	logic [2:0] length;

	String_HW_Avalon dut(.clk(clk),
						 .reset(reset), 
						 .writedata(writedata), 
						 .address(address), 
						 .readdata(readdata), 
						 .write(write), 
						 .read(read), 
						 .chipselect(chipselect)
						);
	
	initial
	begin
		
		// Reset and initialize values
		reset = 1;	   #20;
		reset = 0;	   #20;
		chipselect = 1;
		write = 0;read = 0; #20;
		
		
/************** Test index 0 (string compare), inputs (abcd, abca)******************/
	
		// Write string A to register 0
		address = 0;	    	
		writedata = "abcd";  #20;	
		write = 1;			 #20;
		
		write = 0;read = 0;  #20;
		
		// Read A from register 0
		address = 0;	
		read = 1;			#20;
		A = readdata; 		#20;	
		
		
		write = 0;read = 0; #20;	
		
		// write string B to register 1
		address = 1;		
		writedata = "abca";	#20;
		write = 1;			#20;		
		
		write = 0;read = 0; #20;	
		
		// Read B from register 1
		address = 1;		
		read = 1;			#20;
		B = readdata;       #20;		
		
		write = 0;read = 0; #20;	
		
		// Write 0 to index and set go bit to register 2 (Control)
		address = 2;		
		writedata = 32'b000_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #200;	
		
		// Read register 2 (control)
		address = 2;		
		read = 1;			#20;
		control = readdata; #200;	
		
		write = 0;read = 0; #20;
		
		// Read register 3 (Result)
		address = 3;  
		read = 1;	  #20;
		R = readdata; #20;			
		
		write = 0;read = 0; #20; 
		
		assert (R == 0) 
			$display("String Compare(%s,%s) == %0d PASSED",A,B,R);
		else 
			$display("String Compare(%s,%s) == %0d failed",A,B,R);
	
		// reset go bit to register 2 (Control)
		address = 2; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
/************** Test index 0 (string compare), inputs (ab, ab)******************/
	
		// Write string A to register 0
		address = 0;	    	
		writedata = "abcd";  #20;	
		write = 1;			 #20;
		
		write = 0;read = 0;  #20;
		
		// Read A from register 0
		address = 0;	
		read = 1;			#20;
		A = readdata; 		#20;	
		
		
		write = 0;read = 0; #20;	
		
		// write string B to register 1
		address = 1;		
		writedata = "abcd";	#20;
		write = 1;			#20;		
		
		write = 0;read = 0; #20;	
		
		// Read B from register 1
		address = 1;		
		read = 1;			#20;
		B = readdata;       #20;		
		
		write = 0;read = 0; #20;	
		
		// Write 0 to index and set go bit to register 2 (Control)
		address = 2;		
		writedata = 32'b000_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #200;	
		
		// Read register 2 (control)
		address = 2;		
		read = 1;			#20;
		control = readdata; #200;	
		
		write = 0;read = 0; #20;
		
		// Read register 3 (Result)
		address = 3;  
		read = 1;	  #20;
		R = readdata; #20;			
		
		write = 0;read = 0; #20; 
		
		assert (R == 1) 
			$display("String Compare(%s,%s) == %0d PASSED",A,B,R);
		else 
			$display("String Compare(%s,%s) == %0d failed",A,B,R);
	
		// reset go bit to register 2 (Control)
		address = 2; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
/************** Test index 1 (string To Upper), inputs (abcd)******************/
	
		// Write string A to register 0
		address = 0;	    	
		writedata = "abcd";  #20;	
		write = 1;			 #20;
		
		write = 0;read = 0;  #20;
		
		// Read A from register 0
		address = 0;	
		read = 1;			#20;
		A = readdata; 		#20;	
		
		write = 0;read = 0; #20;	
		
		// Write 1 to index and set go bit to register 2 (Control)
		address = 2;		
		writedata = 32'b001_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #200;	
		
		// Read register 2 (control)
		address = 2;		
		read = 1;			#20;
		control = readdata; #200;	
		
		write = 0;read = 0; #20;
		
		// Read register 3 (Result)
		address = 3;  
		read = 1;	  #20;
		R = readdata; #20;			
		
		write = 0;read = 0; #20; 
		
		assert (R == "ABCD") 
			$display("String_To_Upper(%s) == %s PASSED", A, R);
		else 
			$display("Case String_To_Upper(%s) == %s failed", A, R);
	
		// reset go bit to register 2 (Control)
		address = 2; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
/************** Test index 1 (string To Upper), inputs (Ab)******************/
	
		// Write string A to register 0
		address = 0;	    	
		writedata = "Ab";  #20;	
		write = 1;			 #20;
		
		write = 0;read = 0;  #20;
		
		// Read A from register 0
		address = 0;	
		read = 1;			#20;
		A = readdata; 		#20;	
		
		write = 0;read = 0; #20;	
		
		// Write 1 to index and set go bit to register 2 (Control)
		address = 2;		
		writedata = 32'b001_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #200;	
		
		// Read register 2 (control)
		address = 2;		
		read = 1;			#20;
		control = readdata; #200;	
		
		write = 0;read = 0; #20;
		
		// Read register 3 (Result)
		address = 3;  
		read = 1;	  #20;
		R = readdata; #20;			
		
		write = 0;read = 0; #20; 
		
		assert (R == "AB") 
			$display("String_To_Upper(%s) == %s PASSED", A, R);
		else 
			$display("Case String_To_Upper(%s) == %s failed", A, R);
	
		// reset go bit to register 2 (Control)
		address = 2; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
/************** Test index 2 (string To Lower), inputs (ABCD)******************/
	
		// Write string A to register 0
		address = 0;	    	
		writedata = "ABCD";  #20;	
		write = 1;			 #20;
		
		write = 0;read = 0;  #20;
		
		// Read A from register 0
		address = 0;	
		read = 1;			#20;
		A = readdata; 		#20;	
		
		write = 0;read = 0; #20;	
		
		// Write 2 to index and set go bit to register 2 (Control)
		address = 2;		
		writedata = 32'b010_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #200;	
		
		// Read register 2 (control)
		address = 2;		
		read = 1;			#20;
		control = readdata; #200;	
		
		write = 0;read = 0; #20;
		
		// Read register 3 (Result)
		address = 3;  
		read = 1;	  #20;
		R = readdata; #20;			
		
		write = 0;read = 0; #20; 
		
		assert (R == "abcd") 
			$display("String_To_Lower(%s) == %s PASSED", A, R);
		else 
			$display("Case String_To_Lower(%s) == %s failed", A, R);
	
		// reset go bit to register 2 (Control)
		address = 2; 
		writedata[1] = 0;   #20;	// reset go bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
/************** Test index 2 (string To Upper), inputs (Ab)******************/
	
		// Write string A to register 0
		address = 0;	    	
		writedata = "Ab";  #20;	
		write = 1;			 #20;
		
		write = 0;read = 0;  #20;
		
		// Read A from register 0
		address = 0;	
		read = 1;			#20;
		A = readdata; 		#20;	
		
		write = 0;read = 0; #20;	
		
		// Write 2 to index and set go bit to register 2 (Control)
		address = 2;		
		writedata = 32'b010_10; #20;		
		write = 1;			    #20;
		
		write = 0;read = 0; #200;	
		
		// Read register 2 (control)
		address = 2;		
		read = 1;			#20;
		control = readdata; #200;	
		
		write = 0;read = 0; #20;
		
		// Read register 3 (Result)
		address = 3;  
		read = 1;	  #20;
		R = readdata; #20;			
		
		write = 0;read = 0; #20; 
		
		assert (R == "ab") 
			$display("String_To_Lower(%s) == %s PASSED", A, R);
		else 
			$display("Case String_To_Lower(%s) == %s failed", A, R);
	
		// reset go bit to register 2 (Control)
		address = 2; 
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
