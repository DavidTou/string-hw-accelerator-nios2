	component nios_system is
		port (
			expansion_jp5_export       : inout std_logic_vector(31 downto 0) := (others => 'X'); -- export
			green_leds_export          : out   std_logic_vector(8 downto 0);                     -- export
			hex3_hex0_HEX0             : out   std_logic_vector(6 downto 0);                     -- HEX0
			hex3_hex0_HEX1             : out   std_logic_vector(6 downto 0);                     -- HEX1
			hex3_hex0_HEX2             : out   std_logic_vector(6 downto 0);                     -- HEX2
			hex3_hex0_HEX3             : out   std_logic_vector(6 downto 0);                     -- HEX3
			hex7_hex4_HEX4             : out   std_logic_vector(6 downto 0);                     -- HEX4
			hex7_hex4_HEX5             : out   std_logic_vector(6 downto 0);                     -- HEX5
			hex7_hex4_HEX6             : out   std_logic_vector(6 downto 0);                     -- HEX6
			hex7_hex4_HEX7             : out   std_logic_vector(6 downto 0);                     -- HEX7
			pushbuttons_export         : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
			red_leds_export            : out   std_logic_vector(17 downto 0);                    -- export
			sdram_addr                 : out   std_logic_vector(12 downto 0);                    -- addr
			sdram_ba                   : out   std_logic_vector(1 downto 0);                     -- ba
			sdram_cas_n                : out   std_logic;                                        -- cas_n
			sdram_cke                  : out   std_logic;                                        -- cke
			sdram_cs_n                 : out   std_logic;                                        -- cs_n
			sdram_dq                   : inout std_logic_vector(31 downto 0) := (others => 'X'); -- dq
			sdram_dqm                  : out   std_logic_vector(3 downto 0);                     -- dqm
			sdram_ras_n                : out   std_logic;                                        -- ras_n
			sdram_we_n                 : out   std_logic;                                        -- we_n
			sdram_clk_clk              : out   std_logic;                                        -- clk
			serial_port_RXD            : in    std_logic                     := 'X';             -- RXD
			serial_port_TXD            : out   std_logic;                                        -- TXD
			slider_switches_export     : in    std_logic_vector(17 downto 0) := (others => 'X'); -- export
			sram_DQ                    : inout std_logic_vector(15 downto 0) := (others => 'X'); -- DQ
			sram_ADDR                  : out   std_logic_vector(19 downto 0);                    -- ADDR
			sram_LB_N                  : out   std_logic;                                        -- LB_N
			sram_UB_N                  : out   std_logic;                                        -- UB_N
			sram_CE_N                  : out   std_logic;                                        -- CE_N
			sram_OE_N                  : out   std_logic;                                        -- OE_N
			sram_WE_N                  : out   std_logic;                                        -- WE_N
			system_pll_ref_clk_clk     : in    std_logic                     := 'X';             -- clk
			system_pll_ref_reset_reset : in    std_logic                     := 'X'              -- reset
		);
	end component nios_system;

	u0 : component nios_system
		port map (
			expansion_jp5_export       => CONNECTED_TO_expansion_jp5_export,       --        expansion_jp5.export
			green_leds_export          => CONNECTED_TO_green_leds_export,          --           green_leds.export
			hex3_hex0_HEX0             => CONNECTED_TO_hex3_hex0_HEX0,             --            hex3_hex0.HEX0
			hex3_hex0_HEX1             => CONNECTED_TO_hex3_hex0_HEX1,             --                     .HEX1
			hex3_hex0_HEX2             => CONNECTED_TO_hex3_hex0_HEX2,             --                     .HEX2
			hex3_hex0_HEX3             => CONNECTED_TO_hex3_hex0_HEX3,             --                     .HEX3
			hex7_hex4_HEX4             => CONNECTED_TO_hex7_hex4_HEX4,             --            hex7_hex4.HEX4
			hex7_hex4_HEX5             => CONNECTED_TO_hex7_hex4_HEX5,             --                     .HEX5
			hex7_hex4_HEX6             => CONNECTED_TO_hex7_hex4_HEX6,             --                     .HEX6
			hex7_hex4_HEX7             => CONNECTED_TO_hex7_hex4_HEX7,             --                     .HEX7
			pushbuttons_export         => CONNECTED_TO_pushbuttons_export,         --          pushbuttons.export
			red_leds_export            => CONNECTED_TO_red_leds_export,            --             red_leds.export
			sdram_addr                 => CONNECTED_TO_sdram_addr,                 --                sdram.addr
			sdram_ba                   => CONNECTED_TO_sdram_ba,                   --                     .ba
			sdram_cas_n                => CONNECTED_TO_sdram_cas_n,                --                     .cas_n
			sdram_cke                  => CONNECTED_TO_sdram_cke,                  --                     .cke
			sdram_cs_n                 => CONNECTED_TO_sdram_cs_n,                 --                     .cs_n
			sdram_dq                   => CONNECTED_TO_sdram_dq,                   --                     .dq
			sdram_dqm                  => CONNECTED_TO_sdram_dqm,                  --                     .dqm
			sdram_ras_n                => CONNECTED_TO_sdram_ras_n,                --                     .ras_n
			sdram_we_n                 => CONNECTED_TO_sdram_we_n,                 --                     .we_n
			sdram_clk_clk              => CONNECTED_TO_sdram_clk_clk,              --            sdram_clk.clk
			serial_port_RXD            => CONNECTED_TO_serial_port_RXD,            --          serial_port.RXD
			serial_port_TXD            => CONNECTED_TO_serial_port_TXD,            --                     .TXD
			slider_switches_export     => CONNECTED_TO_slider_switches_export,     --      slider_switches.export
			sram_DQ                    => CONNECTED_TO_sram_DQ,                    --                 sram.DQ
			sram_ADDR                  => CONNECTED_TO_sram_ADDR,                  --                     .ADDR
			sram_LB_N                  => CONNECTED_TO_sram_LB_N,                  --                     .LB_N
			sram_UB_N                  => CONNECTED_TO_sram_UB_N,                  --                     .UB_N
			sram_CE_N                  => CONNECTED_TO_sram_CE_N,                  --                     .CE_N
			sram_OE_N                  => CONNECTED_TO_sram_OE_N,                  --                     .OE_N
			sram_WE_N                  => CONNECTED_TO_sram_WE_N,                  --                     .WE_N
			system_pll_ref_clk_clk     => CONNECTED_TO_system_pll_ref_clk_clk,     --   system_pll_ref_clk.clk
			system_pll_ref_reset_reset => CONNECTED_TO_system_pll_ref_reset_reset  -- system_pll_ref_reset.reset
		);

