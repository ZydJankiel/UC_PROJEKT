`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2021 13:49:48
// Design Name: 
// Module Name: vertical_lasers_obstacle
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

module horizontal_lasers_obstacle(
  input wire [11:0] vcount_in,
  input wire [11:0] hcount_in,
  input wire pclk,
  input wire rst,
  input wire game_on,
  input wire menu_on,
  input wire [11:0] rgb_in,
  input wire play_selected,
  input wire [3:0] selected,
  input wire done_control,
  
  output reg working,
  output reg [11:0] rgb_out,
  output reg [11:0] obstacle_x,
  output reg [11:0] obstacle_y,
  output reg done
  );
  
localparam COUNTER_ON_LASER_VALUE       = 3200000,
           COUNTER_BETWEEN_LASERS_VALUE = 32000000;

localparam LASER_LEFT           = 361,
           LASER_RIGHT          = 661;
           
localparam TOP_LASER_TOP        = 367,
           TOP_LASER_BOTTOM     = 368,
           MIDDLE_LASER_TOP     = 467,
           MIDDLE_LASER_BOTTOM  = 468,
           BOTTOM_LASER_TOP     = 567,
           BOTTOM_LASER_BOTTOM  = 568;
           
localparam DX                   = 1;

localparam IDLE                 = 2'b00,
           DRAW_TOP             = 2'b01,
           DRAW_MIDDLE          = 2'b10,
           DRAW_BOTTOM          = 2'b11;
           

reg [11:0] rgb_nxt;
reg [11:0] obstacle_x_nxt, obstacle_y_nxt;
reg [1:0] state, state_nxt;
reg [10:0] laser_top, laser_bottom, laser_top_nxt, laser_bottom_nxt;
reg [24:0] counter_between_lasers, counter_between_lasers_nxt, counter_on_laser, counter_on_laser_nxt;
reg [5:0] obstacle_counter, obstacle_counter_nxt;
reg done_nxt, working_nxt;

always @(posedge pclk) begin
    if (rst) begin
        state                   <= IDLE;
        rgb_out                 <= 0; 
        obstacle_x              <= 0;
        obstacle_y              <= 0;
        laser_top               <= 0;
        laser_bottom            <= 0;
        counter_between_lasers  <= 0;
        counter_on_laser        <= 0;
        done                    <= 0;
        working                 <= 0;
        obstacle_counter        <= 0;
    end
    else begin
        state                   <= state_nxt;
        rgb_out                 <= rgb_nxt;
        obstacle_x              <= obstacle_x_nxt;
        obstacle_y              <= obstacle_y_nxt;
        laser_top               <= laser_top_nxt;
        laser_bottom            <= laser_bottom_nxt;
        counter_between_lasers  <= counter_between_lasers_nxt;
        counter_on_laser        <= counter_on_laser_nxt;
        done                    <= done_nxt;
        working                 <= working_nxt;
        obstacle_counter        <= obstacle_counter_nxt;
    end
end

always @* begin
    rgb_nxt = rgb_in;
    state_nxt = IDLE;
    counter_between_lasers_nxt = 0;
    counter_on_laser_nxt = 0;
    laser_top_nxt  = laser_top;
    laser_bottom_nxt  = laser_bottom;
    obstacle_x_nxt = 0;
    obstacle_y_nxt = 0;
    done_nxt = 0;
    obstacle_counter_nxt = obstacle_counter;
    case (state)
        IDLE: begin
            working_nxt = 0;
            done_nxt = 0;
            obstacle_counter_nxt = 0;
            if (done_control) begin
                state_nxt = ((selected == 4'b0010) && play_selected) ? DRAW_TOP : IDLE;
                laser_top_nxt = TOP_LASER_TOP;
                laser_bottom_nxt = TOP_LASER_BOTTOM;
            end
            else begin
                state_nxt = IDLE;
            end
        end
            
        DRAW_TOP: begin
            done_nxt = 0;
            working_nxt = 1;
            if (menu_on || !play_selected) begin
                state_nxt = IDLE;
                end
            else 
                state_nxt = DRAW_TOP;
                
            //draw top laser
            if (hcount_in <= LASER_RIGHT && hcount_in >= LASER_LEFT && vcount_in >= laser_top && vcount_in <= laser_bottom) begin
                rgb_nxt = 12'hf_f_f;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
                end
            else
                rgb_nxt = rgb_in;
                            
            if ((laser_top <= TOP_LASER_TOP - 30 ) && (laser_bottom >= TOP_LASER_BOTTOM + 30)) begin         //move to next laser after delay and when reached set size (border +- 30)
                if (counter_between_lasers == COUNTER_BETWEEN_LASERS_VALUE) begin               
                    if (obstacle_counter >= 15) begin                         
                        state_nxt = IDLE;
                        done_nxt = 1;
                        end
                    else begin
                        state_nxt = DRAW_MIDDLE;
                        laser_top_nxt = MIDDLE_LASER_TOP;
                        laser_bottom_nxt = MIDDLE_LASER_BOTTOM;
                        obstacle_counter_nxt = obstacle_counter + 1;
                        end
                    end
                else
                    counter_between_lasers_nxt = counter_between_lasers + 1;
                end
            else begin                                      
                if ((laser_top == TOP_LASER_TOP) && (laser_bottom == TOP_LASER_BOTTOM)) begin //after spawning laser wait 
                    if (counter_on_laser >= COUNTER_BETWEEN_LASERS_VALUE) begin  
                        laser_top_nxt = laser_top - 1;
                        laser_bottom_nxt = laser_bottom + 1;
                        counter_on_laser_nxt = 0;
                        end
                    else begin
                        counter_on_laser_nxt = counter_on_laser + 1;
                        laser_top_nxt  = laser_top;
                        laser_bottom_nxt  = laser_bottom;
                        end
                    end
                else begin              //expand top and bottom borders of laser with delay between expansions to slow down
                    if (counter_on_laser >= COUNTER_ON_LASER_VALUE) begin  
                        laser_top_nxt = laser_top - 1;
                        laser_bottom_nxt = laser_bottom + 1;
                        counter_on_laser_nxt = 0;
                        end
                    else begin
                        counter_on_laser_nxt = counter_on_laser + 1;
                        laser_top_nxt  = laser_top;
                        laser_bottom_nxt  = laser_bottom;
                        end
                    end

            end       
        end   
        
        DRAW_MIDDLE: begin
            working_nxt = 1;
            if (menu_on || !play_selected) begin
                state_nxt = IDLE;
                end
            else 
                state_nxt = DRAW_MIDDLE;
            
            //draw middle laser
            if (hcount_in <= LASER_RIGHT && hcount_in >= LASER_LEFT && vcount_in >= laser_top && vcount_in <= laser_bottom)begin
                rgb_nxt = 12'hf_f_f;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
                end
            else
                rgb_nxt = rgb_in;
                
            if ((laser_top <= MIDDLE_LASER_TOP - 30 ) && (laser_bottom >= MIDDLE_LASER_BOTTOM + 30)) begin     //move to next laser after delay and when reached set size (border +- 30)
                if (counter_between_lasers == COUNTER_BETWEEN_LASERS_VALUE) begin
                    if (obstacle_counter == 9) begin                        
                        state_nxt = DRAW_TOP;
                        laser_top_nxt = TOP_LASER_TOP;
                        laser_bottom_nxt = TOP_LASER_BOTTOM;
                        obstacle_counter_nxt = obstacle_counter_nxt + 1;
                        end
                    if (obstacle_counter == 12) begin                        
                        state_nxt = DRAW_MIDDLE;
                        laser_top_nxt = MIDDLE_LASER_TOP;
                        laser_bottom_nxt = MIDDLE_LASER_BOTTOM;
                        obstacle_counter_nxt = obstacle_counter_nxt + 1;
                        end
                    else begin
                        laser_top_nxt = BOTTOM_LASER_TOP;
                        laser_bottom_nxt = BOTTOM_LASER_BOTTOM;
                        state_nxt = DRAW_BOTTOM;
                        obstacle_counter_nxt = obstacle_counter_nxt + 1;
                        end
                    end  
                else
                    counter_between_lasers_nxt = counter_between_lasers + 1;
                end
            else begin                                                      
                if ((laser_top == MIDDLE_LASER_TOP) && (laser_bottom == MIDDLE_LASER_BOTTOM)) begin //after spawning laser wait 
                    if (counter_on_laser >= COUNTER_BETWEEN_LASERS_VALUE) begin  
                        laser_top_nxt = laser_top - 1;
                        laser_bottom_nxt = laser_bottom + 1;
                        counter_on_laser_nxt = 0;
                        end
                    else begin
                        counter_on_laser_nxt = counter_on_laser + 1;
                        laser_top_nxt  = laser_top;
                        laser_bottom_nxt  = laser_bottom;
                        end
                    end
                else begin              //expand top and bottom borders of laser with delay between expansions to slow down
                    if (counter_on_laser >= COUNTER_ON_LASER_VALUE) begin  
                        laser_top_nxt = laser_top - 1;
                        laser_bottom_nxt = laser_bottom + 1;
                        counter_on_laser_nxt = 0;
                        end
                    else begin
                        counter_on_laser_nxt = counter_on_laser + 1;
                        laser_top_nxt  = laser_top;
                        laser_bottom_nxt  = laser_bottom;
                        end
                    end      
            end 
        end
        
        DRAW_BOTTOM: begin
            working_nxt = 1;
            if (menu_on || !play_selected) begin
                state_nxt = IDLE;
                end
            else 
                state_nxt = DRAW_BOTTOM;
            
            //draw right laser
            if (hcount_in <= LASER_RIGHT && hcount_in >= LASER_LEFT && vcount_in >= laser_top && vcount_in <= laser_bottom)begin
                rgb_nxt = 12'hf_f_f;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
                end
            else
                rgb_nxt = rgb_in;
                
            if ((laser_top <= BOTTOM_LASER_TOP - 30 ) && (laser_bottom >= BOTTOM_LASER_BOTTOM + 30 )) begin         //move to next laser after delay and when reached set size (border +- 30)
                if (counter_between_lasers == COUNTER_BETWEEN_LASERS_VALUE) begin               
                    if (obstacle_counter == 8) begin                             
                        state_nxt = DRAW_MIDDLE;                               
                        laser_top_nxt = MIDDLE_LASER_TOP;
                        laser_bottom_nxt = MIDDLE_LASER_BOTTOM;
                        obstacle_counter_nxt = obstacle_counter + 1;                                
                        end
                    else if (obstacle_counter > 9) begin
                        laser_top_nxt = TOP_LASER_TOP;
                        laser_bottom_nxt = TOP_LASER_BOTTOM;
                        obstacle_counter_nxt = obstacle_counter + 1;            
                        state_nxt = DRAW_TOP;
                        end                    
                    else if (obstacle_counter > 4) begin
                        laser_top_nxt = MIDDLE_LASER_TOP;
                        laser_bottom_nxt = MIDDLE_LASER_BOTTOM;
                        obstacle_counter_nxt = obstacle_counter + 1;            
                        state_nxt = DRAW_MIDDLE;
                        end
                    else begin
                        laser_top_nxt = TOP_LASER_TOP;
                        laser_bottom_nxt = TOP_LASER_BOTTOM;
                        obstacle_counter_nxt = obstacle_counter + 1;            
                        state_nxt = DRAW_TOP;
                        end                   
                    end
                else
                    counter_between_lasers_nxt = counter_between_lasers + 1;
                end
            else begin                                                      
                if ((laser_top == BOTTOM_LASER_TOP) && (laser_bottom == BOTTOM_LASER_BOTTOM)) begin //after spawning laser wait 
                    if (counter_on_laser >= COUNTER_BETWEEN_LASERS_VALUE) begin  
                        laser_top_nxt = laser_top - 1;
                        laser_bottom_nxt = laser_bottom + 1;
                        counter_on_laser_nxt = 0;
                        end
                    else begin
                        counter_on_laser_nxt = counter_on_laser + 1;
                        laser_top_nxt  = laser_top;
                        laser_bottom_nxt  = laser_bottom;
                        end
                    end
                else begin              //expand top and bottom borders of laser with delay between expansions to slow down
                    if (counter_on_laser >= COUNTER_ON_LASER_VALUE) begin  
                        laser_top_nxt = laser_top - 1;
                        laser_bottom_nxt = laser_bottom + 1;
                        counter_on_laser_nxt = 0;
                        end
                    else begin
                        counter_on_laser_nxt = counter_on_laser + 1;
                        laser_top_nxt  = laser_top;
                        laser_bottom_nxt  = laser_bottom;
                        end
                    end      
            end
        end        
            
    endcase        
end

endmodule