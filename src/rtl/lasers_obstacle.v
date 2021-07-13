`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2021 13:12:45
// Design Name: 
// Module Name: lasers_obstacle
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
/*
*MO-created module
*
*/

module lasers_obstacle(
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
localparam LASER_TOP    = 317,
           LASER_BOTTOM = 617;

localparam IDLE         = 2'b00,
           DRAW_LEFT    = 2'b01,
           DRAW_MIDDLE  = 2'b10,
           DRAW_RIGHT   = 2'b11;
           

reg [11:0] rgb_nxt;
reg [11:0] obstacle_x_nxt, obstacle_y_nxt;
reg [1:0] state, state_nxt;
reg [10:0] laser_right, laser_left, laser_right_nxt, laser_left_nxt;


always @(posedge pclk) begin
    if (rst) begin
        state       <= IDLE;
        rgb_out     <= 0; 
        obstacle_x  <= 0;
        obstacle_y  <= 0;
        laser_right <= 371;
        laser_left  <= 341;

    end
    else begin
        state       <= state_nxt;
        rgb_out     <= rgb_nxt;
        obstacle_x  <= obstacle_x_nxt;
        obstacle_y  <= obstacle_y_nxt;
        laser_right <= laser_right_nxt;
        laser_left  <= laser_left_nxt;
    end
end

always @* begin
    rgb_nxt = rgb_in;
    state_nxt = IDLE;
    laser_right_nxt = 371;
    laser_left_nxt = 341;
    case (state)
        IDLE: begin
            if ((selected == 4'b0011) || (game_on == 1))
                state_nxt = DRAW_LEFT;
            else
                state_nxt = IDLE;
        end
            
        DRAW_LEFT: begin
            //state_nxt = (menu_on || !play_selected) ? IDLE : DRAW_LEFT;
            state_nxt = DRAW_LEFT;
            if (hcount_in <= laser_right && hcount_in >= laser_left && vcount_in >= LASER_TOP && vcount_in <= LASER_BOTTOM)begin
                rgb_nxt = 12'hf_f_f;
                end
            else
                rgb_nxt = rgb_in;
        end   
            
            
    endcase        
end





endmodule
