
module DE2_115_Basic_Computer (
	// Inputs
	CLOCK_50,
	KEY,
	SW,

	//  Communication
	UART_RXD,
	
/*****************************************************************************/

	// Memory (SRAM)
	SRAM_DQ,
	
	// Memory (SDRAM)
	DRAM_DQ,

/*****************************************************************************/
	
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


// 	Memory (SRAM)
inout		[15: 0]	SRAM_DQ;

//  Memory (SDRAM)
inout		[31: 0]	DRAM_DQ;


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

);

endmodule

