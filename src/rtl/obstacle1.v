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
    TEST_RIGHT_LINE   = 0,
    COLOR = 12'hf_f_f,
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
  output reg [11:0] obstacle_y
  );
  
reg [11:0] rgb_nxt;
reg [11:0] obstacle_x_nxt, obstacle_y_nxt;
reg state, state_nxt;

localparam IDLE = 0,
           DRAW = 1;

  always @(posedge pclk) begin
      if (rst) begin
          state <= IDLE;
          rgb_out <= 0; 
          obstacle_x <= 0;
          obstacle_y <= 0;
      end
      else begin
          state <= state_nxt;
          rgb_out <= rgb_nxt;
          obstacle_x <= obstacle_x_nxt;
          obstacle_y <= obstacle_y_nxt;
      end
  end
  
  always @* begin 
      obstacle_x_nxt = 0;
      obstacle_y_nxt = 0;
      case(state)
          IDLE: 
              begin
                  //state_nxt = (game_on || play_selected) ? DRAW : IDLE;
                  state_nxt = (selected == SELECT_CODE) ? DRAW : IDLE;
                  rgb_nxt = rgb_in; 
              end
          DRAW:
              begin
                  state_nxt = (menu_on || !play_selected) ? IDLE : DRAW;
                  if (hcount_in <TEST_RIGHT_LINE && hcount_in >TEST_LEFT_LINE && vcount_in < TEST_TOP_LINE && vcount_in >TEST_BOTTOM_LINE) begin 
                      rgb_nxt = COLOR;
                      obstacle_x_nxt = hcount_in;
                      obstacle_y_nxt = vcount_in;
                  end
                  else rgb_nxt = rgb_in;
              end
      endcase
  end

endmodule
