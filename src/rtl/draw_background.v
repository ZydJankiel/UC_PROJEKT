`timescale 1 ns / 1 ps

module draw_background (
  input wire [11:0] vcount_in,
  input wire vsync_in,
  input wire vblnk_in,
  input wire [11:0] hcount_in,
  input wire hsync_in,
  input wire hblnk_in,
  input wire pclk,
  input wire rst,

  output reg [11:0] vcount_out,
  output reg vsync_out,
  output reg vblnk_out,
  output reg [11:0] hcount_out,
  output reg hsync_out,
  output reg hblnk_out,
  output reg [11:0] rgb_out
  
  );
reg [11:0] rgb_nxt;
reg [11:0] vcount_nxt, hcount_nxt;
reg vsync_nxt, vblnk_nxt, hsync_nxt, hblnk_nxt;
      
  always @(posedge pclk) begin
    if (rst) begin
      hsync_out <= 0;
      vsync_out <= 0;
      hblnk_out <= 0;
      vblnk_out <= 0;
      hcount_out <= 0;
      vcount_out <= 0;
      rgb_out <= 0;    
    end
    else begin
      hsync_out <= hsync_nxt;
      vsync_out <= vsync_nxt;
      hblnk_out <= hblnk_nxt;
      vblnk_out <= vblnk_nxt;
      hcount_out <= hcount_nxt;
      vcount_out <= vcount_nxt;
      rgb_out <= rgb_nxt;
    end
  end
  
  always @* begin
   // During blanking, make it it black.
    if (vblnk_in || hblnk_in) rgb_nxt = 12'h0_0_0; 
      else begin
        // Active display, top edge, make a yellow line.
        if (vcount_in == 0) rgb_nxt = 12'hf_f_0;
        // Active display, bottom edge, make a red line.
        else if (vcount_in == 599) rgb_nxt = 12'hf_0_0;
        // Active display, left edge, make a green line.
        else if (hcount_in == 0) rgb_nxt = 12'h0_f_0;
        // Active display, right edge, make a blue line.
        else if (hcount_in == 799) rgb_nxt = 12'h0_0_f;
        
        /*

         // TU będzie obszar gry  
         else if ((hcount_in >= 100 && hcount_in < 150 && vcount_in >= 100 && vcount_in < 500) || 
           (hcount_in >= 200 && hcount_in < 250 && vcount_in >= 100 && vcount_in < 250) || 
           (hcount_in >= 150 && hcount_in < 200 && vcount_in >= 100 && vcount_in < 150) || 
           (hcount_in >= 150 && hcount_in < 200 && vcount_in >= 200 && vcount_in < 250) ) rgb_nxt = 12'hf_f_f;

        */

        else rgb_nxt = 12'hF_F_F;    
      end
      hsync_nxt = hsync_in;
      vsync_nxt = vsync_in;
      hblnk_nxt = hblnk_in;
      vblnk_nxt = vblnk_in;
      hcount_nxt = hcount_in;
      vcount_nxt = vcount_in;
      
  end

endmodule
