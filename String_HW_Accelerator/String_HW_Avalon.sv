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

module String_HW_Avalon #(MAX_BLOCKS = 2, ADDRESS_BITS = 5)
						(input logic clk, reset, read, write, chipselect,
						 input logic [ADDRESS_BITS - 1:0] address,
						 input logic [31:0] writedata, 
						 output logic [31:0] readdata
						);
						
	logic write_reg_A, write_reg_B, write_reg_Control;
	logic read_reg_A, read_reg_B, read_reg_Control, read_reg_Result;
	
	logic [31:0] Control;
	
	logic start, done;
    logic [3:0] index;
	logic [7:0] length;
	
	/* ------ Control/Status Flags --------- */
	assign read_reg_Control  = (address == 0) && read  && chipselect;
	assign write_reg_Control = (address == 0) && write && chipselect;
	
	
	/* ------ StringA Flags --------- 
	* ADDRESS 1 - MAX_BLOCKS
	*/
	logic [0:MAX_BLOCKS-1] [31:0] StringA;
	assign write_reg_A		 		= (address >= 1) && (address <= MAX_BLOCKS) && write && chipselect;			  	// Write Register Flags
	assign read_reg_A 		 		= (address >= 1) && (address <= MAX_BLOCKS) && read  && chipselect && ~done;    // Read Register Flags
	
	/* ------ StringB Flags ---------
	* ADDRESS 9 - 2*MAX_BLOCKS
	*/
	logic [0:MAX_BLOCKS-1] [31:0] StringB;
	assign write_reg_B		 = (address > MAX_BLOCKS) && (address <= (MAX_BLOCKS+MAX_BLOCKS)) && write && chipselect; 	// Write Register Flags
	assign read_reg_B 		 = (address > MAX_BLOCKS) && (address <= (MAX_BLOCKS+MAX_BLOCKS)) && read  && chipselect;  // Read Register Flags
	
	/* ------ Result Flags ---------
	* ADDRESS 9 - 2*MAX_BLOCKS
	*/
	logic [0:MAX_BLOCKS-1] [31:0] Result;
	assign read_reg_Result 	 = (address >= 1) && (address <= MAX_BLOCKS) && read  && chipselect && done;    		    // Read Register Flags
	
	
	// Instantiate String_HW module
    String_HW U0(.clk(clk), 
				.reset(reset),
				.go(start),
			    .index(index),
				.length(length),
			    .A(StringA), 
			    .B(StringB),
			    .done(done),
			    .Result(Result)
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
			StringA		  <= '{default:32'h0};		// initialize StringA to NULL Chars
			StringB		  <= '{default:32'h0};		// initialize StringB to NULL Chars
			Control[31:1] <= 0;						// Reset Control Register
			end
		// StringA & StringB Read/Write
		else begin
 			if (write_reg_Control) 		Control[31:1] <= writedata[31:1];			    // WRITE Control/STATUS REGISTER  (ignore bit 0: done)
			else if (read_reg_Control)	readdata <= Control; 						    // READ Control/STATUS REGISTER	
			else if (write_reg_A) 		StringA[address - 1] <= writedata; 			    // WRITE TO StringA
			else if (read_reg_A) 		readdata <= StringA[address - 1];  			    // READ FROM StringA
			else if (write_reg_B) 		StringB[address - MAX_BLOCKS - 1] <= writedata; // WRITE TO StringB
			else if (read_reg_B) 		readdata <= StringB[address - MAX_BLOCKS - 1];  // READ FROM StringB
			else if (read_reg_Result)   begin 
											readdata <= Result[address-1];			   	// READ FROM RESULT
											StringA <= 0;								// Reset String A
											StringB <= 0;								// Reset String B
										end
		end
	end
	
endmodule