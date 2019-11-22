 /*
 * ###############################################################################
 * CPE423
 * Assignment 3 - Greatest Common Divisor (TESTBENCH)
 * David Tougaw 
 * --------------------------------------
 * Greatest Common Calculator TESTBENCH
 * 64 bit integer inputs A and B
 * ------------------------------------------------------------------------------
 * After initial Reset, FSM will follow these steps: 
 * 0) LoadHA => load HIGH 32 bits of A
 * 1) LoadLA => load LOW 32 bits of A
 * 2) LoadHB => load HIGH 32 bits of B
 * 3) LoadLB => load LOW 32 bits of B, starts calculation
 * 4) Ouput result and done signal
 * ###############################################################################
 */

`timescale 1ns / 1ps

module GCD_HW_tb(); 

logic resetn,loadHA,loadHB, loadLA, loadLB, done, clock;
logic [63:0] R,A,B;	
logic [31:0] to_reg;

logic [2:0] state;	

GCD_HW_64 U1 ( .clock(clock), .resetn(resetn), .opIn(to_reg), .loadHA(loadHA),.loadHB(loadHB),
 .loadLA(loadLA),.loadLB(loadLB),.outGCD(R),.outDone(done),.state(state),.AA(A),.BB(B));


// Clock & TIme Unit Set-up
// Start Time = 0 ns
// End Time = 1 us
// T = 40 ns
always
   begin
	clock  = 1'b1  ; #20;
	clock  = 1'b0  ; #20; 
		// 1 us, repeat pattern in loop.
end

initial begin
	/*INITIALIZE INPUT & CONTROLS*/
	
	loadHA = 1'b0;
	loadLA = 1'b0;
	loadHB = 1'b0;
	loadLB = 1'b0;
	done = 1'b0;
	resetn = 1'b1;
	#80;
	/* Reset */
	
	#80; resetn = 1'b0;				// Reset
	#80; resetn = 1'b1;
	// ############ TEST 1 (odd,odd) GCD(9,27) == 9 #################

	// LOAD A

	#80 to_reg = 32'd999999;  		// Load HIGH A

	#80; loadHA = 1'b1;		

	#80; loadHA = 1'b0;	

	#80 to_reg = 32'd999999;  		// Load low A

	#80; loadLA = 1'b1;		

	#80; loadLA = 1'b0;							

	// LOAD B

	#80 to_reg = 32'd0;  		// Load HIGH B

	#80; loadHB = 1'b1;		

	#80; loadHB = 1'b0;	

	#80 to_reg = 32'd13;  		// Load low B

	#80; loadLB = 1'b1;		

	#80; loadLB = 1'b0;							
	
	
	#3000;
	
	assert (R == 13) $display("GCD(999999_999999,13) == 13");
	else 
		$display("Case GCD a=99999999 b=13 failed");
	$stop;
	// ##############################################################
		
end
	
	
endmodule

