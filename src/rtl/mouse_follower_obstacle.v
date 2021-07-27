`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2021 13:16:38
// Design Name: 
// Module Name: mouse_follower_obstacle
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


module mouse_follower_obstacle(
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
    input wire [11:0] mouse_x_pos,
    input wire [11:0] mouse_y_pos,
    
    output reg working,
    output reg [11:0] rgb_out,
    output reg [11:0] obstacle_x,
    output reg [11:0] obstacle_y,
    output reg done
    );
localparam COUNTER_MOVE             = 3200000,
           COUNTER_BETWEEN_STATES   = 32000000,
           COUNTER_FAST_MOVE        = COUNTER_MOVE/2 ;   
           
localparam IDLE         = 2'b00,
           ENEMY_SPAWN  = 2'b01,
           ENEMY_CHASE  = 2'b10,
           ENEMY_DEATH  = 2'b11;
           
localparam ENEMY_SIZE_MAX = 15;
    
reg [25:0] counter_between_lasers, counter_between_lasers_nxt, counter_on_laser, counter_on_laser_nxt;
reg [11:0] rgb_nxt;
reg [11:0] obstacle_x_nxt, obstacle_y_nxt;
reg [1:0] state, state_nxt;
reg done_nxt, working_nxt; 


reg [6:0] enemy_size, enemy_size_nxt;

always @(posedge pclk) begin
    if (rst) begin
        state                   <= IDLE;
        rgb_out                 <= 0; 
        obstacle_x              <= 0;
        obstacle_y              <= 0;
        counter_between_lasers  <= 0;
        counter_on_laser        <= 0;
        done                    <= 0;
        working                 <= 0;
        enemy_size              <= 0;
    end
    else begin
        state                   <= state_nxt;
        rgb_out                 <= rgb_nxt;
        obstacle_x              <= obstacle_x_nxt;
        obstacle_y              <= obstacle_y_nxt;
        counter_between_lasers  <= counter_between_lasers_nxt;
        counter_on_laser        <= counter_on_laser_nxt;
        done                    <= done_nxt;
        working                 <= working_nxt;
        enemy_size              <= enemy_size_nxt;
    end
end

always @* begin
    rgb_nxt                     = rgb_in;
    state_nxt                   = IDLE;
    counter_between_lasers_nxt  = counter_between_lasers;
    counter_on_laser_nxt        = 0;
    obstacle_x_nxt              = 0;
    obstacle_y_nxt              = 0;
    done_nxt                    = 0;
    working_nxt                 = 1;
    enemy_size_nxt              = enemy_size;
    case (state)
        IDLE: begin
            working_nxt = 0;

            if (done_control) begin
                state_nxt = ((selected == 4'b0100) && play_selected) ? ENEMY_SPAWN : IDLE;
                counter_between_lasers_nxt = 0;
                enemy_size_nxt = 0;
            end
            else begin
                state_nxt = IDLE;
            end
        end
        
        ENEMY_SPAWN: begin
            if (menu_on || !play_selected) begin
                state_nxt = IDLE;
                end
            else 
                state_nxt = ENEMY_SPAWN;
                
            if ((hcount_in >= 200) && ((hcount_in - 500)*(hcount_in - 500) + (vcount_in - 500)*(vcount_in - 500) < 15*15) ) rgb_nxt = 12'hf_f_0;
        end
        
    endcase
end
     
endmodule
