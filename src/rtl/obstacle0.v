`timescale 1 ns / 1 ps
/*
 * PWJ: Added module for drawing obstacle. This module sends x and y coordinates to
 * module responsible for checking colision with mouse pointer.
 * Added moving pillars.
 */
module obstacle0
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
reg [1:0] state, state_nxt;
reg [32:0] count,count_nxt;
reg [10:0] pillar_left = 1003 ,pillar_right = 1023 ,pillar_left_nxt, pillar_right_nxt;
reg flip,flip_nxt;
reg [10:0] pillar_top, pillar_bottom, pillar_top_nxt, pillar_bottom_nxt;

localparam PILLAR_TOP1 = 417 ,
           PILLAR_BOTTOM1 = 617,
           PILLAR_TOP2 = 317,
           PILLAR_BOTTOM2 = 517;
           
localparam DX = 1;
localparam MAX_TIME = 600;


localparam IDLE  = 2'b00,
           DRAW  = 2'b01,
           COUNT = 2'b10;

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
          count <= 0;
          pillar_left <= 661;
          pillar_right <= 681;
          pillar_top <= PILLAR_TOP1;
          pillar_bottom <= PILLAR_BOTTOM1;
          flip <= 0;
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
          count <= count_nxt;
          pillar_left <= pillar_left_nxt;
          pillar_right <= pillar_right_nxt;
          flip <= flip_nxt;
          pillar_bottom <=  pillar_bottom_nxt;
          pillar_top <= pillar_top_nxt;
      end
  end
  
  always @* begin 
      hsync_nxt = hsync_in;
      vsync_nxt = vsync_in;
      hblnk_nxt = hblnk_in;
      vblnk_nxt = vblnk_in;
      hcount_nxt = hcount_in;
      vcount_nxt = vcount_in;  
      count_nxt = count;
      obstacle_x_nxt = 0;
      obstacle_y_nxt = 0;
      pillar_right_nxt = pillar_right;
      pillar_left_nxt = pillar_left;
      rgb_nxt = rgb_in; 
      state_nxt = state;
      flip_nxt = flip;
      pillar_top_nxt = pillar_top;
      pillar_bottom_nxt = pillar_bottom;
      case(state)
          IDLE: 
              begin
                  state_nxt = (game_on || play_selected) ? DRAW : IDLE;
                  count_nxt = 0;
              end
          DRAW:
              begin
                  if (pillar_left <= 341) begin
                      pillar_right_nxt = 682;
                      pillar_left_nxt = 662;
                      flip_nxt = !flip;
                  end
                  if (flip) begin
                      pillar_top_nxt = PILLAR_TOP2;
                      pillar_bottom_nxt = PILLAR_BOTTOM2;
                  end
                  else begin
                      pillar_top_nxt = PILLAR_TOP1;
                      pillar_bottom_nxt = PILLAR_BOTTOM1;
                  end
                  if (hcount_in < pillar_right && hcount_in > pillar_left && vcount_in > pillar_top && vcount_in < pillar_bottom) begin 
                      rgb_nxt = 12'hf_f_f;
                      obstacle_x_nxt = hcount_in;
                      obstacle_y_nxt = vcount_in;
                      pillar_right_nxt = pillar_right - DX;
                      pillar_left_nxt = pillar_left - DX;   
                  end
                  else rgb_nxt = rgb_in;
                  state_nxt = (menu_on || !play_selected) ? IDLE : COUNT;
              end
          COUNT:
              begin
                  rgb_nxt = rgb_in;
                  if (count == MAX_TIME) begin
                      state_nxt = DRAW;
                      count_nxt = 0;
                  end
                  else begin
                      if (hcount_in < pillar_right && hcount_in > pillar_left && vcount_in > pillar_top && vcount_in < pillar_bottom) begin 
                          rgb_nxt = 12'hf_f_f;
                          obstacle_x_nxt = hcount_in;
                          obstacle_y_nxt = vcount_in;
                      end
                      state_nxt = COUNT;
                      count_nxt = count + 1; 
                  end     
              end
      endcase
  end

endmodule
