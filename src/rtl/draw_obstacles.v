`timescale 1 ns / 1 ps
/*
 * PWJ: Added module
 */
module draw_obstacles
    #( parameter
    TOP_V_LINE     = 367,
    BOTTOM_V_LINE  = 667,
    LEFT_H_LINE    = 361,
    RIGHT_H_LINE   = 661,
    BORDER = 10
  )
  (
  input wire [11:0] vcount_in,
  input wire vsync_in,
  input wire vblnk_in,
  input wire [11:0] hcount_in,
  input wire hsync_in,
  input wire hblnk_in,
  input wire pclk,
  input wire rst,
  input wire game_on,
  input wire menu_on,
  input wire [11:0] rgb_in,
  input wire play_selected,

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
reg state, state_nxt;

localparam IDLE = 2'b00,
           DRAW = 2'b01;

  always @(posedge pclk) begin
      if (rst) begin
          state <= IDLE;
          hsync_out <= 0;
          vsync_out <= 0;
          hblnk_out <= 0;
          vblnk_out <= 0;
          hcount_out <= 0;
          vcount_out <= 0;
          rgb_out <= 0; 
      end
      else begin
          state <= state_nxt;
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
      hsync_nxt = hsync_in;
      vsync_nxt = vsync_in;
      hblnk_nxt = hblnk_in;
      vblnk_nxt = vblnk_in;
      hcount_nxt = hcount_in;
      vcount_nxt = vcount_in;  
      case(state)
          IDLE: 
              begin
                  state_nxt = (game_on || play_selected) ? DRAW : IDLE;
                  rgb_nxt = rgb_in; 
              end
          DRAW:
              begin
                  state_nxt = menu_on ? IDLE : DRAW;
                  if (hcount_in <1000 && hcount_in >900 && vcount_in <500 && vcount_in >400) rgb_nxt = 12'h0_f_0; // test
                  else rgb_nxt = rgb_in;
              end
      endcase
  end

endmodule
