
module nios_system (
	expansion_jp5_export,
	green_leds_export,
	hex3_hex0_HEX0,
	hex3_hex0_HEX1,
	hex3_hex0_HEX2,
	hex3_hex0_HEX3,
	hex7_hex4_HEX4,
	hex7_hex4_HEX5,
	hex7_hex4_HEX6,
	hex7_hex4_HEX7,
	pushbuttons_export,
	red_leds_export,
	sdram_addr,
	sdram_ba,
	sdram_cas_n,
	sdram_cke,
	sdram_cs_n,
	sdram_dq,
	sdram_dqm,
	sdram_ras_n,
	sdram_we_n,
	sdram_clk_clk,
	serial_port_RXD,
	serial_port_TXD,
	slider_switches_export,
	sram_DQ,
	sram_ADDR,
	sram_LB_N,
	sram_UB_N,
	sram_CE_N,
	sram_OE_N,
	sram_WE_N,
	system_pll_ref_clk_clk,
	system_pll_ref_reset_reset);	

	inout	[31:0]	expansion_jp5_export;
	output	[8:0]	green_leds_export;
	output	[6:0]	hex3_hex0_HEX0;
	output	[6:0]	hex3_hex0_HEX1;
	output	[6:0]	hex3_hex0_HEX2;
	output	[6:0]	hex3_hex0_HEX3;
	output	[6:0]	hex7_hex4_HEX4;
	output	[6:0]	hex7_hex4_HEX5;
	output	[6:0]	hex7_hex4_HEX6;
	output	[6:0]	hex7_hex4_HEX7;
	input	[3:0]	pushbuttons_export;
	output	[17:0]	red_leds_export;
	output	[12:0]	sdram_addr;
	output	[1:0]	sdram_ba;
	output		sdram_cas_n;
	output		sdram_cke;
	output		sdram_cs_n;
	inout	[31:0]	sdram_dq;
	output	[3:0]	sdram_dqm;
	output		sdram_ras_n;
	output		sdram_we_n;
	output		sdram_clk_clk;
	input		serial_port_RXD;
	output		serial_port_TXD;
	input	[17:0]	slider_switches_export;
	inout	[15:0]	sram_DQ;
	output	[19:0]	sram_ADDR;
	output		sram_LB_N;
	output		sram_UB_N;
	output		sram_CE_N;
	output		sram_OE_N;
	output		sram_WE_N;
	input		system_pll_ref_clk_clk;
	input		system_pll_ref_reset_reset;
endmodule
