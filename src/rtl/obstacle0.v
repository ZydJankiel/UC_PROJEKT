`timescale 1 ns / 1 ps
/*
 * PWJ: Added module for drawing obstacle. This module sends x and y coordinates to
 * module responsible for checking colision with mouse pointer.
 * Added moving pillars.
 */
module obstacle0 
 #( parameter
     SELECT_CODE = 4'b0000
 )
 (
  input wire [11:0] vcount_in,
  input wire [11:0] hcount_in,
  input wire pclk,
  input wire rst,
  input wire game_on,
  input wire menu_on,
  input wire [11:0] rgb_in,
  input wire play_selected,
  input wire [3:0] selected,

  output reg [11:0] rgb_out,
  output reg [11:0] obstacle_x,
  output reg [11:0] obstacle_y,
  output reg done
  );
  
reg [11:0] rgb_nxt;
reg [11:0] obstacle_x_nxt, obstacle_y_nxt;
reg [1:0] state, state_nxt;
reg [32:0] count,count_nxt;
reg [10:0] pillar_left = 1003 ,pillar_right = 1023 ,pillar_left_nxt, pillar_right_nxt;
reg flip,flip_nxt;
reg [10:0] pillar_top, pillar_bottom, pillar_top_nxt, pillar_bottom_nxt;
reg done_nxt;
reg [29:0] elapsed_time, elapsed_time_nxt;

localparam PILLAR_TOP1 = 417 ,
           PILLAR_BOTTOM1 = 617,
           PILLAR_TOP2 = 317,
           PILLAR_BOTTOM2 = 517;
           
localparam DX = 1;
localparam MAX_COUNT = 600;
localparam MAX_TIME = 10; //seconds
localparam MAX_ELAPSED_TIME = 65000000 * 10;



localparam IDLE  = 2'b00,
           DRAW  = 2'b01;

  always @(posedge pclk) begin
      if (rst) begin
          state <= IDLE;
          rgb_out <= 0; 
          obstacle_x <= 0;
          obstacle_y <= 0;
          count <= 0;
          pillar_left <= 661;
          pillar_right <= 681;
          pillar_top <= PILLAR_TOP1;
          pillar_bottom <= PILLAR_BOTTOM1;
          flip <= 0;
          done <= 0;
          elapsed_time <= 0;
      end
      else begin
          state <= state_nxt;
          rgb_out <= rgb_nxt;
          obstacle_x <= obstacle_x_nxt;
          obstacle_y <= obstacle_y_nxt;
          count <= count_nxt;
          pillar_left <= pillar_left_nxt;
          pillar_right <= pillar_right_nxt;
          flip <= flip_nxt;
          pillar_bottom <=  pillar_bottom_nxt;
          pillar_top <= pillar_top_nxt;
          done <= done_nxt;
          elapsed_time <= elapsed_time_nxt;
      end
  end
  
  always @* begin 
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
      done_nxt = 0;
      case(state)
          IDLE: 
              begin
                  //state_nxt = (game_on || play_selected) ? DRAW : IDLE;
                  state_nxt = ((selected == SELECT_CODE) && play_selected) ? DRAW : IDLE;
                  count_nxt = 0;
              end

          DRAW:
              begin
                  rgb_nxt = rgb_in;
                  if (count <= MAX_COUNT) begin
                      if (hcount_in <= pillar_right && hcount_in >= pillar_left && vcount_in >= pillar_top && vcount_in <= pillar_bottom) begin 
                          rgb_nxt = 12'hf_f_f;
                          obstacle_x_nxt = hcount_in;
                          obstacle_y_nxt = vcount_in;
                          pillar_right_nxt = pillar_right;
                          pillar_left_nxt = pillar_left;   
                      end
                      else rgb_nxt = rgb_in;
                      count_nxt = count + 1;
                  end
                  else begin
                      count_nxt = 0;
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
                      if (hcount_in <= pillar_right && hcount_in >= pillar_left && vcount_in >= pillar_top && vcount_in <= pillar_bottom) begin 
                          rgb_nxt = 12'hf_f_f;
                          obstacle_x_nxt = hcount_in;
                          obstacle_y_nxt = vcount_in;
                          pillar_right_nxt = pillar_right - DX;
                          pillar_left_nxt = pillar_left - DX;   
                      end
                      else rgb_nxt = rgb_in;
                  end     
                  if (elapsed_time >= MAX_ELAPSED_TIME) begin
                      done_nxt = 1;
                      elapsed_time_nxt = 0;
                      state_nxt = IDLE;
                  end
                  else begin
                      state_nxt = (menu_on || !play_selected) ? IDLE : DRAW;
                      done_nxt = 0;
                      elapsed_time_nxt = elapsed_time + 1;
                  end
              end
      endcase
  end

endmodule
