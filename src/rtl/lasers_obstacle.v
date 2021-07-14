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

localparam DX           = 1;

localparam IDLE         = 2'b00,
           DRAW_LEFT    = 2'b01,
           DRAW_MIDDLE  = 2'b10,
           DRAW_RIGHT   = 2'b11;
           

reg [11:0] rgb_nxt;
reg [11:0] obstacle_x_nxt, obstacle_y_nxt;
reg [1:0] state, state_nxt;
reg [10:0] laser_right, laser_left, laser_right_nxt, laser_left_nxt;
reg [24:0] counter_between_lasers, counter_between_lasers_nxt, counter_on_laser, counter_on_laser_nxt;
reg bounce_back, bounce_back_nxt;

always @(posedge pclk) begin
    if (rst) begin
        state                   <= IDLE;
        rgb_out                 <= 0; 
        obstacle_x              <= 0;
        obstacle_y              <= 0;
        laser_right             <= 0;
        laser_left              <= 0;
        counter_between_lasers  <= 0;
        counter_on_laser        <= 0;
        bounce_back             <= 0;
    end
    else begin
        state                   <= state_nxt;
        rgb_out                 <= rgb_nxt;
        obstacle_x              <= obstacle_x_nxt;
        obstacle_y              <= obstacle_y_nxt;
        laser_right             <= laser_right_nxt;
        laser_left              <= laser_left_nxt;
        counter_between_lasers  <= counter_between_lasers_nxt;
        counter_on_laser        <= counter_on_laser_nxt;
        bounce_back             <= bounce_back_nxt;
    end
end

always @* begin
    rgb_nxt = rgb_in;
    state_nxt = IDLE;
    counter_between_lasers_nxt = 0;
    counter_on_laser_nxt = 0;
    laser_left_nxt  = laser_left;
    laser_right_nxt  = laser_right;
    obstacle_x_nxt = 0;
    obstacle_y_nxt = 0;
    case (state)
        IDLE: begin
            if ((play_selected == 1) || (game_on == 1)) begin
                state_nxt = DRAW_LEFT;
                laser_left_nxt = 411;
                laser_right_nxt = 412;
                bounce_back_nxt = 0;
                end
            else
                state_nxt = IDLE;
        end
            
        DRAW_LEFT: begin
            if (menu_on || !play_selected) begin
                state_nxt = IDLE;
                end
            else 
                state_nxt = DRAW_LEFT;

            if (hcount_in <= laser_right && hcount_in >= laser_left && vcount_in >= LASER_TOP && vcount_in <= LASER_BOTTOM)begin
                rgb_nxt = 12'hf_f_f;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
                end
            else
                rgb_nxt = rgb_in;
                
            if ((laser_left <= 386 ) && (laser_right >= 437)) begin
                if (counter_between_lasers == 32500000) begin
                    if (bounce_back == 1)
                        state_nxt = IDLE;
                    else begin
                        state_nxt = DRAW_MIDDLE;
                        laser_left_nxt = 511;
                        laser_right_nxt = 512;
                        end
                    end
                else
                    counter_between_lasers_nxt = counter_between_lasers + 1;
                end
            else begin
                if (counter_on_laser >= 3250000) begin
                    laser_left_nxt = laser_left - 1;
                    laser_right_nxt = laser_right + 1;
                    counter_on_laser_nxt = 0;
                    end
                else begin
                    counter_on_laser_nxt = counter_on_laser + 1;
                    laser_left_nxt  = laser_left;
                    laser_right_nxt  = laser_right;
                    end       
            end       
        end   
        
        DRAW_MIDDLE: begin
            if (menu_on || !play_selected) begin
                state_nxt = IDLE;
                end
            else 
                state_nxt = DRAW_MIDDLE;
    
            if (hcount_in <= laser_right && hcount_in >= laser_left && vcount_in >= LASER_TOP && vcount_in <= LASER_BOTTOM)begin
                rgb_nxt = 12'hf_f_f;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
                end
            else
                rgb_nxt = rgb_in;
                
            if ((laser_left <= 486 ) && (laser_right >= 537)) begin
                if (counter_between_lasers == 32500000) begin
                    if (bounce_back == 1) begin
                        state_nxt = DRAW_LEFT;
                        laser_left_nxt = 411;
                        laser_right_nxt = 412;
                        end
                    else begin
                        laser_left_nxt = 611;
                        laser_right_nxt = 612;
                        state_nxt = DRAW_RIGHT;
                        end
                    end  
                else
                    counter_between_lasers_nxt = counter_between_lasers + 1;
                end
            else begin
                if (counter_on_laser >= 3250000) begin
                    laser_left_nxt = laser_left - 1;
                    laser_right_nxt = laser_right + 1;
                    counter_on_laser_nxt = 0;
                    end
                else begin
                    counter_on_laser_nxt = counter_on_laser + 1;
                    laser_left_nxt  = laser_left;
                    laser_right_nxt  = laser_right;
                    end       
            end 
        end
        
        DRAW_RIGHT: begin
            if (menu_on || !play_selected) begin
                state_nxt = IDLE;
                end
            else 
                state_nxt = DRAW_RIGHT;
    
            if (hcount_in <= laser_right && hcount_in >= laser_left && vcount_in >= LASER_TOP && vcount_in <= LASER_BOTTOM)begin
                rgb_nxt = 12'hf_f_f;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
                end
            else
                rgb_nxt = rgb_in;
                
            if ((laser_left <= 586 ) && (laser_right >= 637)) begin
                if (counter_between_lasers == 32500000) begin
                    if (bounce_back == 1) begin
                        state_nxt = DRAW_MIDDLE;
                        laser_left_nxt = 511;
                        laser_right_nxt = 512;
                        end
                    else begin
                        laser_left_nxt = 611;
                        laser_right_nxt = 612;
                        bounce_back_nxt = 1;
                        state_nxt = DRAW_RIGHT;
                        end                   
                    end
                else
                    counter_between_lasers_nxt = counter_between_lasers + 1;
                end
            else begin
                if (counter_on_laser >= 3250000) begin
                    laser_left_nxt = laser_left - 1;
                    laser_right_nxt = laser_right + 1;
                    counter_on_laser_nxt = 0;
                    end
                else begin
                    counter_on_laser_nxt = counter_on_laser + 1;
                    laser_left_nxt  = laser_left;
                    laser_right_nxt  = laser_right;
                    end       
            end
        end        
            
    endcase        
end





endmodule
