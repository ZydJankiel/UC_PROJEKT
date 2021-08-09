`timescale 1 ns / 1 ps

/*
*PWJ-created all files in this module
*
*/

module CLK (
    input wire clk,
    input wire rst,

    output wire reset_out,
    output wire pixel_clock,
    output wire mouse_clock
);
    
wire pclk, clkMouse, locked, locked_reset;

clk_wiz_0 clk_wiz_0 (
    //inputs
    .clk(clk),
    .reset(rst),
    
    //outputs
    .clk130MHz(clkMouse),
    .clk65MHz(pclk),
    .locked(locked)
);

clk_locked_menager clk_locked_menager(
    //inputs
    .pclk(pclk),
    .locked_in(locked),
    
    //outputs
    .reset_out(locked_reset)
);

assign pixel_clock = pclk;
assign mouse_clock = clkMouse;
assign reset_out = locked_reset;

endmodule