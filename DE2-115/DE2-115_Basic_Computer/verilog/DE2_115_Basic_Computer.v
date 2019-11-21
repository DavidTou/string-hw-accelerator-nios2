
module DE2_115_Basic_Computer (
	// Inputs
	CLOCK_50,
	KEY,
	SW,

	//  Communication
	UART_RXD,
	
/*****************************************************************************/
	// Bidirectionals
	GPIO,

	// Memory (SRAM)
	SRAM_DQ,
	
	// Memory (SDRAM)
	DRAM_DQ,

/*****************************************************************************/
	// Outputs
	// 	Simple
	LEDG,
	LEDR,

	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7,
	
	// 	Memory (SRAM)
	SRAM_ADDR,

	SRAM_CE_N,
	SRAM_WE_N,
	SRAM_OE_N,
	SRAM_UB_N,
	SRAM_LB_N,
	
	//  Communication
	UART_TXD,
	
	// Memory (SDRAM)
	DRAM_ADDR,
	
	DRAM_BA,
	DRAM_CAS_N,
	DRAM_RAS_N,
	DRAM_CLK,
	DRAM_CKE,
	DRAM_CS_N,
	DRAM_WE_N,
	DRAM_DQM
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input		[ 3: 0]	KEY;
input		[17: 0]	SW;


//  Communication
input				UART_RXD;

// Bidirectionals
inout		[35: 0]	GPIO;

// 	Memory (SRAM)
inout		[15: 0]	SRAM_DQ;

//  Memory (SDRAM)
inout		[31: 0]	DRAM_DQ;

// Outputs
// 	Simple
output		[ 8: 0]	LEDG;
output		[17: 0]	LEDR;

output		[ 6: 0]	HEX0;
output		[ 6: 0]	HEX1;
output		[ 6: 0]	HEX2;
output		[ 6: 0]	HEX3;
output		[ 6: 0]	HEX4;
output		[ 6: 0]	HEX5;
output		[ 6: 0]	HEX6;
output		[ 6: 0]	HEX7;

// 	Memory (SRAM)
output		[19: 0]	SRAM_ADDR;

output				SRAM_CE_N;
output				SRAM_WE_N;
output				SRAM_OE_N;
output				SRAM_UB_N;
output				SRAM_LB_N;

//  Communication
output				UART_TXD;

//  Memory (SDRAM)
output		[12: 0]	DRAM_ADDR;

output		[ 1: 0]	DRAM_BA;
output				DRAM_CAS_N;
output				DRAM_RAS_N;
output				DRAM_CLK;
output				DRAM_CKE;
output				DRAM_CS_N;
output				DRAM_WE_N;
output		[ 3: 0]	DRAM_DQM;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires

// Internal Registers

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/


/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

// Output Assignments
assign GPIO[ 0]		= 1'bZ;
assign GPIO[ 2]		= 1'bZ;
assign GPIO[16]		= 1'bZ;
assign GPIO[18]		= 1'bZ;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
nios_system NiosII (
	// 1) global signals:
	.system_pll_ref_clk_clk			(CLOCK_50),
	.system_pll_ref_reset_reset	(~KEY[0]),
	.sdram_clk_clk						(DRAM_CLK),

	// SDRAM
	.sdram_addr							(DRAM_ADDR),
	.sdram_ba							(DRAM_BA),
	.sdram_cas_n						(DRAM_CAS_N),
	.sdram_cke							(DRAM_CKE),
	.sdram_cs_n							(DRAM_CS_N),
	.sdram_dq							(DRAM_DQ),
	.sdram_dqm							(DRAM_DQM),
	.sdram_ras_n						(DRAM_RAS_N),
	.sdram_we_n							(DRAM_WE_N),
	
	// SRAM
	.sram_DQ								(SRAM_DQ),
	.sram_ADDR							(SRAM_ADDR),
	.sram_LB_N							(SRAM_LB_N),
	.sram_UB_N							(SRAM_UB_N),
	.sram_CE_N							(SRAM_CE_N),
	.sram_OE_N							(SRAM_OE_N),
	.sram_WE_N							(SRAM_WE_N),

	// Red LEDs
	.red_leds_export					(LEDR),
	
	// Green LEDs
	.green_leds_export				(LEDG),

	// HEX3 HEX0
	.hex3_hex0_HEX0					(HEX0),
	.hex3_hex0_HEX1					(HEX1),
	.hex3_hex0_HEX2					(HEX2),
	.hex3_hex0_HEX3					(HEX3),
	
	// HEX7 HEX4
	.hex7_hex4_HEX4					(HEX4),
	.hex7_hex4_HEX5					(HEX5),
	.hex7_hex4_HEX6					(HEX6),
	.hex7_hex4_HEX7					(HEX7),

	// Slider switches
	.slider_switches_export			(SW),

	// Pushbuttons
	.pushbuttons_export				({KEY[3:1], 1'b1}),

	// Expansion JP5
	.expansion_jp5_export			({GPIO[35:19], GPIO[17], GPIO[15:3], GPIO[1]}),

	// Serial port
	.serial_port_RXD					(UART_RXD),
	.serial_port_TXD					(UART_TXD)
);

endmodule

