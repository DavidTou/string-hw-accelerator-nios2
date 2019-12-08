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

	parameter MAX_WORDS = 4;
   // signals for connecting to the Avalon fabric
	input logic clk, reset, read, write, chipselect;
	input logic [2:0] address;
	input logic [31:0] writedata;
	output logic [31:0] readdata;
	
	logic write_reg_A, write_reg_B, write_reg_Control;
	logic  read_reg_A,  read_reg_B,  read_reg_Control, read_reg_Result;
	
	/* ------ FIFO A --------- */
	logic [31:0] FIFOA [0:MAX_WORDS-1];
	logic [2:0]  Count; 
	logic [2:0]  readCounter, writeCounter; 
	logic EMPTY, FULL;

	// Write Register Flags
	assign write_reg_A 		= (address == 0) && write && chipselect;
	//assign write_reg_B		= (address == 1) && write && chipselect;
	assign write_reg_StatusA = (address == 2) && write && chipselect;

	// Read Register Flags
	assign read_reg_A 		= (address == 0) && read  && chipselect;
	//assign read_reg_B 		= (address == 1) && read  && chipselect;
	assign read_reg_StatusA  = (address == 2) && read  && chipselect;
	//assign read_reg_Result 	= (address == 3) && read  && chipselect;
	
	assign EMPTY = (Count==0);
	assign FULL = (Count==MAX_WORDS);

	/* ------ END FIFO A --------- */

	// Process Read & Write Commands FIFO A
	always_ff@(posedge clk)
	begin
		if (reset) begin										// Synchronous Reset
			readCounter <= 0;
			writeCounter <= 0;
			Count <= 0; 
			FIFOA <= '{default:32'hdeadfeed};
			end
		// FIFO STUFF
		else begin
			// reset FIFO writing to Status register
			if (write_reg_StatusA) begin
				readCounter <= 0;
				writeCounter <= 0;
				Count <= 0;
				end
			// WRITE TO FIFOA
			else if (write_reg_A && Count < MAX_WORDS) begin
				FIFOA[writeCounter] <= writedata;
				writeCounter <= writeCounter + 1;
				end
			// READ FROM FIFOA
			else if (read_reg_A && Count != 0) begin
				readdata <= FIFOA[readCounter];
			    readCounter <= readCounter + 1;
				end
			// READ STATUS REGISTER
			else if (read_reg_StatusA)	
				readdata <= {29'b0,Count};//control;		// Read control register 			
			else;
			
			if(readCounter == MAX_WORDS)
				readCounter <= 0;
			else if (writeCounter == MAX_WORDS) 
				writeCounter <= 0;
			else;
			
			// HANDLE COUNT calculation
			if(readCounter >= writeCounter)
				Count <= readCounter - writeCounter;
			else if (writeCounter > readCounter) 
				Count <= writeCounter - readCounter; 
			else;
		end
	end
	
endmodule