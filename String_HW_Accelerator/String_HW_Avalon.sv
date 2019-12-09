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



module String_HW_Avalon (input logic clk, reset, read, write, chipselect,
						 input logic [ADDRESS_BITS:0] address,
						 input logic [31:0] writedata, 
						 output logic [31:0] readdata
						);
	parameter MAX_WORDS = 8, ADDRESS_BITS = 4;
	logic write_reg_A, write_reg_B, write_reg_Control;
	logic read_reg_A, read_reg_B, read_reg_Control;
	
	logic [31:0] Control;
	
	/* ------ Control/Status Flags --------- */
	assign read_reg_Control  = (address == 0) && read  && chipselect;
	assign write_reg_Control = (address == 0) && write && chipselect;
	/* ------ END Control/Status Flags --------- */
	
	/* ------ StringA Flags --------- 
	* ADDRESS 1 - MAX_WORDS
	*/
	logic [0:MAX_WORDS-1] [31:0] StringA;
	assign write_reg_A		 		= (address >= 1) && (address <= MAX_WORDS) && write && chipselect;  	// Write Register Flags
	assign read_reg_A 		 		= (address >= 1) && (address <= MAX_WORDS) && read  && chipselect;      // Read Register Flags
	/* ------ END StringA Flags --------- */
	
	
	
	/* ------ StringB Flags ---------
	* ADDRESS 9 - 2*MAX_WORDS
	*/
	logic [0:MAX_WORDS-1] [31:0] StringB;
	assign write_reg_B		 = (address > MAX_WORDS) && (address <= (MAX_WORDS+MAX_WORDS)) && write && chipselect; 	// Write Register Flags
	assign read_reg_B 		 = (address > MAX_WORDS) && (address <= (MAX_WORDS+MAX_WORDS)) && read  && chipselect;  // Read Register Flags

	
	// Instantiate String_HW module
    String_HW U0(.clk(clk), 
				.reset(reset),
				.go(start),
			    .index(index),
			    .A(A), 
			    .B(B),
			    .length(length),
			    .done(done),
			    .result(result)
			    );
			   
    // Control Register bits
    assign Control[0] = done;		   // Output
    assign start 	  = Control[1];    // Input
    assign index  	  = Control[5:2];  // Input
    assign length 	  = Control[13:6]; // Input
	
	
	// Process Read & Write Commands StringA and StringB
	always_ff@(posedge clk)
	begin
		if (reset) begin
			StringA		  <= '{default:32'h0};		//initialize StringA to NULL Chars
			StringB		  <= '{default:32'h0};		//initialize StringB to NULL Chars
			Control[31:1] <= 0;
			end
		// StringA & StringB Read/Write
		else begin
 			if (write_reg_Control) 		Control[31:1] <= writedata[31:1];			   // WRITE Control/STATUS REGISTER  (ignore bit 0: done)
			else if (read_reg_Control)	readdata <= Control; 						   // READ Control/STATUS REGISTER	
			else if (write_reg_A) 		StringA[address - 1] <= writedata; 			   // WRITE TO StringA
			else if (read_reg_A) 		readdata <= StringA[address - 1];  			   // READ FROM StringA
			else if (write_reg_B) 		StringB[address - MAX_WORDS - 1] <= writedata; // WRITE TO StringB
			else if (read_reg_B) 		readdata <= StringB[address - MAX_WORDS - 1];  // READ FROM StringB
		end
	end
	
endmodule