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

	parameter MAX_WORDS = 8;
   // signals for connecting to the Avalon fabric
	input logic clk, reset, read, write, chipselect;
	input logic [MAX_WORDS/2:0] address;
	input logic [31:0] writedata;
	output logic [31:0] readdata;
	
	logic write_reg_A, write_reg_B, write_reg_Control_Status;
	logic read_reg_A, read_reg_B, read_reg_Control_Status;
	
	logic [31:0] Control_Status;
	
	/* ------ Control/Status Flags --------- */
	assign read_reg_Control_Status  = (address == 0) && read  && chipselect;
	assign write_reg_Control_Status = (address == 0) && write && chipselect;
	/* ------ END Control/Status Flags --------- */
	
	/* ------ StringA Flags --------- 
	* ADDRESS 1 - MAX_WORDS
	*/
	logic [31:0] StringA [0:MAX_WORDS-1];
	// Write Register Flags
	assign write_reg_A		 		= (address >= 1) && (address <= MAX_WORDS) && write && chipselect;
	// Read Register Flags
	assign read_reg_A 		 		= (address >= 1) && (address <= MAX_WORDS) && read  && chipselect;
	/* ------ END StringA Flags --------- */
	
	/* ------ StringB Flags ---------
	* ADDRESS 9 - 2*MAX_WORDS
	*/
	logic [31:0] StringB [0:MAX_WORDS-1];
	// Write Register Flags
	assign write_reg_B		 = (address > MAX_WORDS) && (address <= (MAX_WORDS+MAX_WORDS)) && write && chipselect;
	// Read Register Flags
	assign read_reg_B 		 = (address > MAX_WORDS) && (address <= (MAX_WORDS+MAX_WORDS)) && read  && chipselect;
	// Process Read & Write Commands StringA and StringB
	always_ff@(posedge clk)
	begin
		if (reset) begin
			StringA		<= '{default:32'h0};		//initialize StringA to NULL Chars
			StringB		<= '{default:32'h0};		//initialize StringB to NULL Chars
			Control_Status 	<= 0;
			end
		// StringA & StringB Read/Write
		else begin
			// WRITE CONTROL/STATUS REGISTER
 			if (write_reg_Control_Status) begin
				Control_Status <= writedata;
				end
				
			// WRITE TO StringA
			if (write_reg_A) begin
				StringA[address - 1] <= writedata;
				//writeCounter <= writeCounter + 1;
				end
			// READ FROM StringA
			else if (read_reg_A) begin
				readdata <= StringA[address - 1];
			    //readCounter <= readCounter + 1;
				end
				
			// WRITE TO StringB
			if (write_reg_B) begin
				StringB[address - MAX_WORDS - 1] <= writedata;
				//writeCounter <= writeCounter + 1;
				end
			// READ FROM StringB
			else if (read_reg_B) begin
				readdata <= StringB[address - MAX_WORDS - 1];
			    //readCounter <= readCounter + 1;
				end
				
			// READ CONTROL/STATUS REGISTER
			else if (read_reg_Control_Status)	
				readdata <= Control_Status; 			
			else;
			
		end
	end
	
endmodule