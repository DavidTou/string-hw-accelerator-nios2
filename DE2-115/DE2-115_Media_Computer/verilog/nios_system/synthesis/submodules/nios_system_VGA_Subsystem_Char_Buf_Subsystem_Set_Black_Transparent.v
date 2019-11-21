// THIS FILE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THIS FILE OR THE USE OR OTHER DEALINGS
// IN THIS FILE.

/******************************************************************************
 *                                                                            *
 * This module changes the alpha value of every pixel of a specific color.    *
 *                                                                            *
 ******************************************************************************/

module nios_system_VGA_Subsystem_Char_Buf_Subsystem_Set_Black_Transparent (
	// Global Signals
	clk,
	reset,

	// Input Stream
	stream_in_data,
	stream_in_startofpacket,
	stream_in_endofpacket,
	stream_in_valid,
	stream_in_ready,

	// Output Stream
	stream_out_ready,
	stream_out_data,
	stream_out_startofpacket,
	stream_out_endofpacket,
	stream_out_valid
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter CW		= 29;			// Frame's Data Width (color portion only)
parameter DW		= 39;			// Frame's Data Width

parameter COLOR	= 30'd0;		// Color to apply alpha value
parameter ALPHA	= 10'd0;		// The alpha value to apply

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Global Signals
input						clk;
input						reset;

// Input Stream
input			[DW: 0]	stream_in_data;
input						stream_in_startofpacket;
input						stream_in_endofpacket;
input						stream_in_valid;
output					stream_in_ready;

// Output Stream
input						stream_out_ready;
output reg	[DW: 0]	stream_out_data;
output reg				stream_out_startofpacket;
output reg				stream_out_endofpacket;
output reg				stream_out_valid;

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire			[DW: 0]	converted_data;

// Internal Registers

// State Machine Registers

// Integers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

// Output Registers
always @(posedge clk)
begin
	if (reset)
	begin
		stream_out_data				<=  'b0;
		stream_out_startofpacket	<= 1'b0;
		stream_out_endofpacket		<= 1'b0;
		stream_out_valid				<= 1'b0;
	end
	else if (stream_out_ready | ~stream_out_valid)
	begin
		stream_out_data				<= converted_data;
		stream_out_startofpacket	<= stream_in_startofpacket;
		stream_out_endofpacket		<= stream_in_endofpacket;
		stream_out_valid				<= stream_in_valid;
	end
end

// Internal Registers

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

// Output Assignments
assign stream_in_ready = stream_out_ready | ~stream_out_valid;

// Internal Assignments
assign converted_data = (stream_in_data[CW:0] == COLOR) ?
									{ALPHA, stream_in_data[CW:0]} :
									stream_in_data;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule

