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

module String_HW_Avalon (clk, reset, writedata, address, readdata, write, read, chipselect, queueA,indexIn,indexOut);
   // signals for connecting to the Avalon fabric
   input logic clk, reset, read, write, chipselect;
   input logic [2:0] address;
   input logic [31:0] writedata;
   output logic [31:0] readdata;
   
   output logic [31:0]  queueA [0:3];
   output logic [3:0]   indexIn;			// indexIn for writes
	output logic [3:0]   indexOut;			// indexOut for reads
	
   logic go, done;
   logic [2:0] index;
   logic [0:3] [7:0] A, B, result;
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
   /* assign control[0] = done;		 // Output
   assign go 		 = control[1];   // Input
   assign index  	 = control[4:2]; // Input
   assign length 	 = control[7:5]; // Input */
   
   // Instantiate String_HW module
   /* String_HW U0(.clk(clk), 
				.reset(reset),
				.go(go),
			    .index(index),
			    .A(A), 
			    .B(B),
			    .length(length),
			    .done(done),
			    .result(result)
			   ); */
	//logic [31:0]  queueA [15:0];    // A bounded queue of 32-bits with maximum size of 16 slots 16*32 = 512 bits
	
	// Process Read & Write Commands
	always_ff@(posedge clk or posedge reset)
		begin
			if (reset) begin										// Synchronous Reset
				readdata <= 0;
				control[31:1] <= 0;
				indexIn <= 0;
				indexOut <= 0;
				// clear 2d fifo
				queueA <= '{default:32'b00};
				end
			else if (write_reg_A)		queueA[indexIn++] <= writedata;//A <= writedata;				// Write to register A
			else if (read_reg_A)		begin readdata<= queueA[indexOut++]; indexOut/=2; end//readdata <= A;				// Read register A
			else if (write_reg_B)		B <= writedata;				// Write to register B
			else if (read_reg_B)   		readdata <= B;				// Read register B
			//else if (write_reg_Control) control[31:1] <= writedata;	// Write control register (ignore bit 0: done)
			else if (read_reg_Control)	readdata <= indexIn;//control;		// Read control register 			
			//else if (read_reg_Result)	readdata <= result;			// Read result from register 3	
			
			/* if (done)
				control[1] <= 1;
			else
				control[1] <= 0; */
		 end
		
/* 
	// Read data into FIFO and wait for go signal
				S1: 	begin 
							// Wait for go or FIFO_read flag
							if (go) nextstate <= S2; 
							else if (FIFO_write) begin
								// Write to FIFO_1
								if (FIFO_select) begin	
									FIFO_1_in[memory_index_1] <= data_in; // Read 32 bits of data from FIFO
									memory_index_1 <= memory_index_1 + 1;		// increment memory index for FIFO 1
									nextstate <= S1;
									end
								// Write to FIFO_0
								else 		
									FIFO_0_in[memory_index_0] <= data_in; // Read 32 bits of data from FIFO
									memory_index_0 <= memory_index_0 + 1;		// increment memory index for FIFO 0
									nextstate <= S1;
									end
							else 
								nextstate <= S1;				 // Do nothing, wait for go or read flag
*/
	
endmodule