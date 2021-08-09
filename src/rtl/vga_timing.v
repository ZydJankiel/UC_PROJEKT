// File: vga_timing.v
// This is the vga timing design for EE178 Lab #4.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).
/*
*PWJ-created module
*
*/
`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.

module vga_timing (
    input wire clk,
    input wire rst,
    
    output reg [11:0] vcount,
    output reg vsync,
    output reg vblnk,
    output reg [11:0] hcount,
    output reg hsync,
    output reg hblnk
);
  
reg [11:0] vcount_nxt;
reg vsync_nxt;
reg vblnk_nxt;
reg [11:0] hcount_nxt;
reg hsync_nxt;
reg hblnk_nxt;
  
  // Describe the actual circuit for the assignment.
  // Video timing controller set for 1024x768@60fps
  // using a 65 MHz pixel clock per VESA spec.

localparam HOR_TOTAL_TIME  = 1343,
           HOR_SYNC_START  = 1047,
           HOR_BLANC_START = 1023,
           VER_TOTAL_TIME  = 805,
           VER_SYNC_START  = 770,
           VER_BLANC_START = 767;

localparam HOR_SYNC_TIME  = 136,
           HOR_BLANC_TIME = 320,
           VER_SYNC_TIME  = 6,
           VER_BLANC_TIME = 38;

always@ (posedge clk) begin
    if (rst) begin
        vcount <= 0;
        vsync  <= 0;
        vblnk  <= 0;
        hcount <= 0;
        hsync  <= 0;
        hblnk  <= 0;
    end 
    else begin
        vcount <= vcount_nxt;
        vsync  <= vsync_nxt;
        vblnk  <= vblnk_nxt;
        hcount <= hcount_nxt;
        hsync  <= hsync_nxt;
        hblnk  <= hblnk_nxt;
    end 
end

always @* begin
    vblnk_nxt = vblnk;
    vsync_nxt = vsync;

    if (hcount == HOR_TOTAL_TIME) begin
        hcount_nxt = 0;
        vcount_nxt = ((vcount == VER_TOTAL_TIME) ? 0 : vcount + 1);
        vsync_nxt = ((vcount >= VER_SYNC_START) && (vcount < (VER_SYNC_START + VER_SYNC_TIME)));
        vblnk_nxt = ((vcount >= VER_BLANC_START) && (vcount < (VER_BLANC_START + VER_BLANC_TIME))) ;
    end
    else begin
        hcount_nxt = hcount + 1;
        vcount_nxt = vcount ;
    end
        
    hsync_nxt = ((hcount >= HOR_SYNC_START) && (hcount < (HOR_SYNC_START + HOR_SYNC_TIME)));
    hblnk_nxt = ((hcount >= HOR_BLANC_START) && (hcount < (HOR_BLANC_START + HOR_BLANC_TIME)));
    
end  
endmodule
