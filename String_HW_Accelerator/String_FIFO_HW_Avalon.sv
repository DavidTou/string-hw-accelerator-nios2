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

module String_HW_Avalon (clk, reset, writedata, address, readdata, write, read, chipselect
// TESTBENCH
//,FIFOA,readCounter,writeCounter, Count);
/*output logic [31:0] statusA;
   	
	output logic [31:0]  queueA [0:MAX_WORDS-1];    // A bounded queue of 32-bits with maximum size of 16 slots 16*32 = 512 bits
	output logic [3:0]   indexIn;			// indexIn for writes
	output logic [3:0]   indexOut;			// indexOut for reads
	*/
);
	parameter MAX_WORDS = 8 ;
   // signals for connecting to the Avalon fabric
	input logic clk, reset, read, write, chipselect;
	input logic [2:0] address;
	input logic [31:0] writedata;
	output logic [31:0] readdata;

	logic go, done;
	logic [2:0] index;
	logic [0:3] [7:0] A, B, result;

	
	logic write_reg_A, write_reg_B, write_reg_Control;
	logic  read_reg_A,  read_reg_B,  read_reg_Control, read_reg_Result;

	// Write Register Flags
	assign write_reg_A 		= (address == 0) && write && chipselect;
	assign write_reg_B		= (address == 1) && write && chipselect;
	assign write_reg_StatusA = (address == 2) && write && chipselect;

	// Read Register Flags
	assign read_reg_A 		= (address == 0) && read  && chipselect;
	assign read_reg_B 		= (address == 1) && read  && chipselect;
	assign read_reg_StatusA  = (address == 2) && read  && chipselect;
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
			   
	/* ------ FIFO A --------- */
	logic [31:0] FIFOA [0:MAX_WORDS-1];
	logic [2:0]  Count = 0; 
	logic [2:0]  readCounter = 0, writeCounter = 0; 
	logic EMPTY, FULL, HOLD;
	
	assign EMPTY = (Count==0)? 1'b1:1'b0; 

	assign FULL = (Count==MAX_WORDS)? 1'b1:1'b0; 

	/* ------ END FIFO A --------- */

	// Process Read & Write Commands FIFO A
	always_ff@(posedge clk)
	begin
		// do nothing
		if (chipselect == 0);
		
		else if (reset) begin										// Synchronous Reset
			readCounter = 0;
			writeCounter = 0;
			Count = 0; 
		end
		// FIFO STUFF
		else begin
			// reset FIFO writing to Status register
			if (write_reg_StatusA == 1) begin
				readCounter = 0;
				writeCounter = 0;
				Count = 0;
			end
			else if (write_reg_A == 1 && Count < MAX_WORDS) begin
				FIFOA[writeCounter] = writedata;
				writeCounter = writeCounter + 1;
			end
			else if (read_reg_A == 1 && Count != 0) begin
				readdata = FIFOA[readCounter];
				readCounter = readCounter + 1;
			end
			//else if (read_reg_StatusA == 1)	
			//	readdata = Count;//control;		// Read control register 			
			else;
			
			if(readCounter == MAX_WORDS)
				readCounter = 0;
			else if (writeCounter == MAX_WORDS) 
				writeCounter = 0;
			else;
			
			// HANDLE COUNT calculation
			if(readCounter > writeCounter)
				Count = readCounter - writeCounter;
			else if (writeCounter > readCounter) 
				Count = writeCounter - readCounter; 
			else;
		end
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