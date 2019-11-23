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

timescale 1ps / 1ps

module String_HW_Avalon_TB;			
	logic clk, resetn, read, write, chipselect;
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
		
		
/************** Test gcd (8,6) = 2 ******************/ 
	
		// Write num A to register 0
		address = 0;	    	
		writedata = 32'd8;  #20;	
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
		// Read A from register 0
		address = 0;	
		read = 1;			#20;
		A = readdata; 		#20;	
		
		
		write = 0;read = 0; #20;	
		
		// write num B to register 1
		address = 1;		
		writedata = 32'd6;	#20;
		write = 1;			#20;		
		
		write = 0;read = 0; #20;	
		
		// Read register 1
		address = 1;		
		read = 1;			#20;
		B = readdata;       #20;		
		
		write = 0;read = 0; #20;	
		
		// Write go bit to register 2 (Control)
		address = 2;		
		writedata = 32'b001;#20;		
		write = 1;			#20;
		
		write = 0;read = 0; #200;	
		
		// Read register 2 (control)
		address = 2;		
		read = 1;			#20;
		control = readdata; #20;	
		
		write = 0;read = 0; #20;
		
		// Read register 3 (Result)
		address = 3;  
		read = 1;	  #20;
		R = readdata; #20;			
		
		write = 0;read = 0; #20; 
		
		assert (R == 2) 
			$display("GCD(%0d,%0d) == %0d PASSED",8,6,2);
		else 
			$display("Case GCD A = %0d B = %0d, R = %0d failed",A,B,R);
	
		// Write again bit to register 2 (Control)
		address = 2; 
		writedata[1] = 1;   #20;	// Set Again bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
/************** Test gcd (128,12 = 4) ******************/ 

				// Write num A to register 0
		address = 0;	    	
		writedata = 32'd128;  #20;	
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
		// Read A from register 0
		address = 0;	
		read = 1;			#20;
		A = readdata; 		#20;	
		
		
		write = 0;read = 0; #20;	
		
		// write num B to register 1
		address = 1;		
		writedata = 32'd12;	#20;
		write = 1;			#20;		
		
		write = 0;read = 0; #20;	
		
		// Read register 1
		address = 1;		
		read = 1;			#20;
		B = readdata;       #20;		
		
		write = 0;read = 0; #20;	
		
		// Write go bit to register 2 (Control)
		address = 2;		
		writedata = 32'b001;#20;		
		write = 1;			#20;
		
		write = 0;read = 0; #200;	
		
		// Read register 2 (control)
		address = 2;		
		read = 1;			#20;
		control = readdata; #20;	
		
		write = 0;read = 0; #20;
		
		// Read register 3 (Result)
		address = 3;  
		read = 1;	  #20;
		R = readdata; #20;			
		
		write = 0;read = 0; #20; 
		
		assert (R == 4) 
			$display("GCD(%0d,%0d) == %0d PASSED",128,12,4);
		else 
			$display("Case GCD A = %0d B = %0d, R = %0d failed",A,B,R);
		
		// Write again bit to register 2 (Control)
		address = 2; 
		writedata[1] = 1;   #20;	// Set Again bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
/************** Test gcd (65536,4000 = 32) ******************/ 

				// Write num A to register 0
		address = 0;	    	
		writedata = 32'd65536;  #20;	
		write = 1;			#20;
		
		write = 0;read = 0; #20;
		
		// Read A from register 0
		address = 0;	
		read = 1;			#20;
		A = readdata; 		#20;	
		
		
		write = 0;read = 0; #20;	
		
		// write num B to register 1
		address = 1;		
		writedata = 32'd4000;#20;
		write = 1;			#20;		
		
		write = 0;read = 0; #20;	
		
		// Read register 1
		address = 1;		
		read = 1;			#20;
		B = readdata;       #20;		
		
		write = 0;read = 0; #20;	
		
		// Write go bit to register 2 (Control)
		address = 2;		
		writedata = 32'b001;#20;		
		write = 1;			#20;
		
		write = 0;read = 0; #200;	
		
		// Read register 2 (control)
		address = 2;		
		read = 1;			#20;
		control = readdata; #20;	
		
		write = 0;read = 0; #20;
		
		// Read register 3 (Result)
		address = 3;  
		read = 1;	  #20;
		R = readdata; #20;			
		
		write = 0;read = 0; #20; 
		
		assert (R == 32) 
			$display("GCD(%0d,%0d) == %0d PASSED",65536,4000,32);
		else 
			$display("Case GCD A = %0d B = %0d, R = %0d failed",A,B,R);
			
		// Write again bit to register 2 (Control)
		address = 2; 
		writedata[1] = 1;   #20;	// Set Again bit
		write = 1;			#20;
		
		write = 0;read = 0; #20;
	end

	always
	begin
		clk <= 1; #5;
		clk <= 0; #5;
	end

endmodule
