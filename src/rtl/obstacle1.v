`timescale 1 ns / 1 ps
/*
 * PWJ: Added module for drawing obstacle. This module sends x and y coordinates to
 * module responsible for checking colision with mouse pointer.
 */
module obstacle1
    #( parameter
    TEST_TOP_LINE     = 0,
    TEST_BOTTOM_LINE   = 0,
    TEST_LEFT_LINE     = 0,
    TEST_RIGHT_LINE   = 0
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
  output reg [11:0] rgb_out,
  output reg [11:0] obstacle_x,
  output reg [11:0] obstacle_y
  );
  
reg [11:0] rgb_nxt;
reg [11:0] vcount_nxt, hcount_nxt, obstacle_x_nxt, obstacle_y_nxt;
reg vsync_nxt, vblnk_nxt, hsync_nxt, hblnk_nxt;
reg state, state_nxt;

localparam IDLE = 0,
           DRAW = 1;

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
          obstacle_x <= 0;
          obstacle_y <= 0;
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
          obstacle_x <= obstacle_x_nxt;
          obstacle_y <= obstacle_y_nxt;
      end
  end
  
  always @* begin 
      hsync_nxt = hsync_in;
      vsync_nxt = vsync_in;
      hblnk_nxt = hblnk_in;
      vblnk_nxt = vblnk_in;
      hcount_nxt = hcount_in;
      vcount_nxt = vcount_in;  
      obstacle_x_nxt = 0;
      obstacle_y_nxt = 0;
      case(state)
          IDLE: 
              begin
                  state_nxt = (game_on || play_selected) ? DRAW : IDLE;
                  rgb_nxt = rgb_in; 
              end
          DRAW:
              begin
                  state_nxt = (menu_on || !play_selected) ? IDLE : DRAW;
                  if (hcount_in <TEST_RIGHT_LINE && hcount_in >TEST_LEFT_LINE && vcount_in < TEST_TOP_LINE && vcount_in >TEST_BOTTOM_LINE) begin 
                      rgb_nxt = 12'hf_f_f;
                      obstacle_x_nxt = hcount_in;
                      obstacle_y_nxt = vcount_in;
                  end
                  else rgb_nxt = rgb_in;
              end
      endcase
  end

endmodule
