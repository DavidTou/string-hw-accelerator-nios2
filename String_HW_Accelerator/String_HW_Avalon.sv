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

module String_HW_Avalon (clk, reset, writedata, address, readdata, write, read, chipselect);
   // signals for connecting to the Avalon fabric
   input logic clk, reset, read, write, chipselect;
   input logic [2:0] address;
   input logic [31:0] writedata;
   output logic [31:0] readdata;
	
   logic go, done;
   logic [2:0] index;
   logic [0:SIZE-1] [7:0] A, B, result;
   logic [2:0] length;
   logic [31:0] control;
   
   logic write_reg_A, write_reg_B, write_reg_Control;
   logic  read_reg_A,  read_reg_B,  read_reg_Control, read_reg_Result;
   
   // Write Register Flags
   assign write_reg_A 		= (address == 0) && write && chipselect;
   assign write_reg_B		= (address == 1) && write && chipselect;
   assign write_reg_Control = (address == 2) && write && chipselect;
   
   // Read Register Flags
   assign read_reg_A 		= (address == 0) && read  && chipselect;
   assign read_reg_B 		= (address == 1) && read  && chipselect;
   assign read_reg_Control  = (address == 2) && read  && chipselect;
   assign read_reg_Result 	= (address == 3) && read  && chipselect;
   
   // Control Register bits
   assign control[0] = done;		 // Output
   assign go 		 = control[1];   // Input
   assign index  	 = control[4:2]; // Input
   assign length 	 = control[7:5]; // Input
   
   // Instantiate String_HW module
   String_HW U0(.clk(clk), 
				.reset(reset),
				.go(go),
			    .index(index),
			    .A(A), 
			    .B(B),
			    .length(length),
			    .done(done),
			    .result(result)
			   );
	
	// Process Read & Write Commands
	always_ff@(posedge clk or posedge reset)
		begin
			if (reset) begin									// Synchronous Reset
				readdata <= 0;
				control[31:1] <= 0;
				end
			else if (write_reg_A)		A <= writedata;						// Write to register A
			else if (read_reg_A)		readdata <= A;						// Read register A
			else if (write_reg_B)		B <= writedata;						// Write to register B
			else if (read_reg_B)   		readdata <= B;						// Read register B
			else if (write_reg_Control) control[31:1] <= writedata[31:1];	// Write control register (ignore bit 0: done)
			else if (read_reg_Control)	readdata <= control;				// Read control register 			
			else if (read_reg_Result) begin 
										readdata <= result;					// Read result from register 3		
										control[1] <= 0;					// Reset go bit
									  end 
		 end
endmodule