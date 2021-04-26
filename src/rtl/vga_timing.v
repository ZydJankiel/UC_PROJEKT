// File: vga_timing.v
// This is the vga timing design for EE178 Lab #4.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.

module vga_timing (
  output reg [11:0] vcount,
  output reg vsync,
  output reg vblnk,
  output reg [11:0] hcount,
  output reg hsync,
  output reg hblnk,
  input wire pclk,
  input wire rst
  );
  
reg [11:0] vcount_nxt;
reg vsync_nxt;
reg vblnk_nxt;
reg [11:0] hcount_nxt;
reg hsync_nxt;
reg hblnk_nxt;
  
  // Describe the actual circuit for the assignment.
  // Video timing controller set for 800x600@60fps
  // using a 40 MHz pixel clock per VESA spec.

// Chcemy 1024x768
localparam HOR_TOTAL_TIME = 1343;
localparam HOR_SYNC_START = 1047;
localparam HOR_BLANC_START = 1023;
localparam VER_TOTAL_TIME = 805;
localparam VER_SYNC_START = 770;
localparam VER_BLANC_START = 767;
// Te warto�ci nie zosta�y pomniejszone, poniewa� to jest czas trwania
localparam HOR_SYNC_TIME = 136;
localparam HOR_BLANC_TIME = 320;
localparam VER_SYNC_TIME = 6;
localparam VER_BLANC_TIME = 38;
/*
// Te warto�ci s� mniejsze o 1 poniewa� liczymy od 0
localparam HOR_TOTAL_TIME = 1055;
localparam HOR_SYNC_START = 839;
localparam HOR_BLANC_START = 799;
localparam VER_TOTAL_TIME = 627;
localparam VER_SYNC_START = 600;
localparam VER_BLANC_START = 599;
// Te warto�ci nie zosta�y pomniejszone, poniewa� to jest czas trwania
localparam HOR_SYNC_TIME = 128;
localparam HOR_BLANC_TIME = 256;
localparam VER_SYNC_TIME = 4;
localparam VER_BLANC_TIME = 28;
*/
//Przypisanie nast��pnych warto�ci
always@ (posedge pclk) begin
  if (rst) begin
      vcount <= 0;
      vsync <= 0;
      vblnk <= 0;
      hcount <= 0;
      hsync <= 0;
      hblnk <= 0;
  end 
  else begin
      vcount <= vcount_nxt;
      vsync <= vsync_nxt;
      vblnk <= vblnk_nxt;
      hcount <= hcount_nxt;
      hsync <= hsync_nxt;
      hblnk <= hblnk_nxt;
  end
end

// logika 
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
