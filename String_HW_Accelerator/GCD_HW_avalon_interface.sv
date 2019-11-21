/* 
 * ###############################################################################
 * CPE423
 * Greatest Common Divisor AVALON HW Interface
 * David Tougaw 
 * 10/15/2019
 * --------------------------------------
 * 32 bit integer inputs A and B
 * --------------------------------------
 * Dev BOARD => Altera DE2-115
 * ------------------------------------------------------------------------------
 * -----------AVALON INTERFACE--------------------
 * ============== 32 bit GCD HW ==================
 *   	   32 bit registers
 *	|----Register 0 (A)---------|
 *	|----Register 1 (B)---------|
 *	|----Register 2 (Control)---|
 *	|----Register 3 (GCD)-------|
 * ------------------------------------------------------------------------------
 * 0) LoadA => load 32 bit A
 * 1) LoadB => load 32 bit B and start calculation
 * 2) Output result and done signal
 * ###############################################################################
 */

module GCD_HW_avalon_interface (clock, resetn, writedata, address, readdata, write, read, chipselect);
   // signals for connecting to the Avalon fabric
   input logic clock, resetn, read, write, chipselect;
   input logic [2:0] address;
   input logic [31:0] writedata;
   output logic [31:0] readdata;
   // signal for exporting register contents outside of the embedded system
   //output logic [31:0] Q_export;
   
	logic loadA,loadB,done, resultRead;
   
   logic [31:0] inputOp, result, read_mux_out,control_register;

   assign inputOp = writedata;
	
	
	// load operands signals
	assign loadA = chipselect && write && (address == 0);
	assign loadB = chipselect && write && (address == 1);
	
   GCD_HW U1 ( .clock(clock), .resetn(resetn), .opIn(inputOp), .loadA(loadA),.loadB(loadB), .outGCD(result),.outDone(done));
	

	// READING control_register and result_register
	always_ff@(posedge clock or negedge resetn)
		begin
			if (resetn == 0)
				 readdata <= 0;
			else if (address == 2)
				readdata <= control_register;
			else if (address == 3)
				readdata <= result;
		 end

		// change control_register status when done 
		always_ff @(posedge clock or negedge resetn)
		begin
			if (resetn == 0) begin
				control_register<=0;
			end
			else if(done)
				control_register<=1;
			// clear done bit when result read
			else if(control_register & (address==3))
				control_register<=0;
		end
	
endmodule