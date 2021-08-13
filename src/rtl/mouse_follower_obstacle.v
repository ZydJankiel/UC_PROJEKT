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

/*
*MO-created module
*
*/

module mouse_follower_obstacle
    #( parameter
        SELECT_CODE = 3'b100
    )
    (
        input wire [11:0] vcount_in,
        input wire [11:0] hcount_in,
        input wire clk,
        input wire rst,
        input wire menu_on,
        input wire [11:0] rgb_in,
        input wire play_selected,
        input wire [2:0] selected,
        input wire done_in,
        input wire [11:0] mouse_xpos,
        input wire [11:0] mouse_ypos,
        
        output reg [11:0] rgb_out,
        output reg [11:0] obstacle_x,
        output reg [11:0] obstacle_y,
        output reg done
    );
        
localparam COUNTER_GROWTH           = 3200000,
           COUNTER_MOVE             = 600000,
           COUNTER_FAST_MOVE        = COUNTER_MOVE/2,
           OBSTACLE_TIME_COUNTER    = 650000000;   //10 seconds
           
localparam IDLE         = 2'b00,
           ENEMY_SPAWN  = 2'b01,
           ENEMY_CHASE  = 2'b10,
           ENEMY_DEATH  = 2'b11;
           
localparam ENEMY_SIZE_MAX   = 15,
           ENEMY_CENTER     = ENEMY_SIZE_MAX/2;

localparam GAME_FIELD_TOP       = 317,
           GAME_FIELD_BOTTOM    = 617,
           GAME_FIELD_LEFT      = 361,
           GAME_FIELD_RIGHT     = 661;
    
reg [25:0] counter_move_x, counter_move_x_nxt, counter_move_y, counter_move_y_nxt, counter_growth, counter_growth_nxt;
reg [25:0] counter2_move_x, counter2_move_x_nxt, counter2_move_y, counter2_move_y_nxt;
reg [11:0] rgb_nxt;
reg [11:0] obstacle_x_nxt, obstacle_y_nxt;
reg [1:0] state, state_nxt;
reg done_nxt;
reg [30:0] obstacle_time_counter, obstacle_time_counter_nxt;

//reg [6:0] enemy_size, enemy_size_nxt;         //for circle
reg [6:0] enemy_border, enemy_border_nxt;
reg [11:0] enemy_center_x, enemy_center_x_nxt, enemy_center_y, enemy_center_y_nxt;
reg [11:0] enemy2_center_x, enemy2_center_x_nxt, enemy2_center_y, enemy2_center_y_nxt;

always @(posedge clk) begin
    if (rst) begin
        state                   <= IDLE;
        rgb_out                 <= 0; 
        obstacle_x              <= 0;
        obstacle_y              <= 0;
        counter_move_x          <= 0;
        counter_move_y          <= 0;
        counter2_move_x         <= 0;
        counter2_move_y         <= 0;      
        counter_growth          <= 0;
        done                    <= 0;
        //enemy_size              <= 0;
        enemy_center_x          <= 0;
        enemy_center_y          <= 0;
        enemy_border            <= 0;
        enemy2_center_x         <= 0;
        enemy2_center_y         <= 0;
        obstacle_time_counter   <= 0;
    end
    else begin
        state                   <= state_nxt;
        rgb_out                 <= rgb_nxt;
        obstacle_x              <= obstacle_x_nxt;
        obstacle_y              <= obstacle_y_nxt;
        counter_move_x          <= counter_move_x_nxt;
        counter_move_y          <= counter_move_y_nxt;
        counter2_move_x         <= counter2_move_x_nxt;
        counter2_move_y         <= counter2_move_y_nxt;
        counter_growth          <= counter_growth_nxt;
        done                    <= done_nxt;
        //enemy_size              <= enemy_size_nxt;
        enemy_center_x          <= enemy_center_x_nxt;
        enemy_center_y          <= enemy_center_y_nxt;
        enemy_border            <= enemy_border_nxt;
        enemy2_center_x         <= enemy2_center_x_nxt;
        enemy2_center_y         <= enemy2_center_y_nxt;
        obstacle_time_counter   <= obstacle_time_counter_nxt;
    end
end

always @* begin
    rgb_nxt                     = rgb_in;
    state_nxt                   = IDLE;
    counter_move_x_nxt          = counter_move_x;
    counter_move_y_nxt          = counter_move_y;
    counter_growth_nxt          = counter_growth;
    obstacle_x_nxt              = 0;
    obstacle_y_nxt              = 0;
    done_nxt                    = 0;
    //enemy_size_nxt              = enemy_size;
    enemy_center_x_nxt          = enemy_center_x;
    enemy_center_y_nxt          = enemy_center_y;
    enemy_border_nxt            = enemy_border;
    enemy2_center_x_nxt         = enemy2_center_x;
    enemy2_center_y_nxt         = enemy2_center_y;
    counter2_move_x_nxt         = counter2_move_x;
    counter2_move_y_nxt         = counter2_move_y;
    obstacle_time_counter_nxt   = obstacle_time_counter;
    
    case (state)
        IDLE: begin

            if (done_in) begin
                state_nxt = ((selected == SELECT_CODE) && play_selected) ? ENEMY_SPAWN : IDLE;
                counter_move_x_nxt = 0;
                counter_move_y_nxt = 0;
                obstacle_time_counter_nxt = 0;
                //enemy_size_nxt = 0;
                
                enemy_center_x_nxt = 380;
                enemy_center_y_nxt = 340;
                enemy2_center_x_nxt = 640;
                enemy2_center_y_nxt = 600;
                enemy_border_nxt = 0;
            end
            else
                state_nxt = IDLE;

        end//end state
        
        ENEMY_SPAWN: begin
            if (menu_on || !play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = ENEMY_SPAWN;
  
            //WARNING THIS GENERATES "PIPELINE WARNING - Input ... is not piplined " , also generates " output ... is not pipelined" 
            //if ( (hcount_in >= 200 && (hcount_in - 500)*(hcount_in - 500) + (vcount_in - 500)*(vcount_in - 500) < 10*10 && (hcount_in - 200) + (vcount_in - 200)*(vcount_in - 200) >= 25*25) ) rgb_nxt = 12'hf_f_0;
            
            // top left enemy, yellow, slower    
            if ( (hcount_in >= enemy_center_x - enemy_border) && (hcount_in <= enemy_center_x + enemy_border) && (vcount_in >= enemy_center_y - enemy_border) && (vcount_in <= enemy_center_y + enemy_border ) ) 
                rgb_nxt = 12'hf_f_0;
            //bottom right enemy, blue, faster    
            else if ( (hcount_in >= enemy2_center_x - enemy_border) && (hcount_in <= enemy2_center_x + enemy_border) && (vcount_in >= enemy2_center_y - enemy_border) && (vcount_in <= enemy2_center_y + enemy_border ) ) 
                rgb_nxt = 12'h0_0_f;
            else
                rgb_nxt = rgb_in;
                
            if (enemy_border == ENEMY_SIZE_MAX)       //move to next state  when reached set size                      
                state_nxt = ENEMY_CHASE;
            else begin                                      
                if (counter_growth >= COUNTER_GROWTH) begin
                    enemy_border_nxt = enemy_border + 1;  
                    counter_growth_nxt = 0;
                end
                else
                    counter_growth_nxt = counter_growth + 1;
            end  
             
        end //end state
        
        ENEMY_CHASE : begin
            if (menu_on || !play_selected)
                state_nxt = IDLE;          
            else if (obstacle_time_counter_nxt >= OBSTACLE_TIME_COUNTER)
                state_nxt = ENEMY_DEATH;
            else begin
                state_nxt = ENEMY_CHASE; 
                obstacle_time_counter_nxt = obstacle_time_counter + 1;  
            end
                
            // top left enemy, yellow, slower    
            if ( (hcount_in >= enemy_center_x - enemy_border) && (hcount_in <= enemy_center_x + enemy_border) && (vcount_in >= enemy_center_y - enemy_border) && (vcount_in <= enemy_center_y + enemy_border ) ) begin 
                rgb_nxt = 12'hf_f_0;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
            end
            //bottom right enemy, blue, faster    
            else if ( (hcount_in >= enemy2_center_x - enemy_border) && (hcount_in <= enemy2_center_x + enemy_border) && (vcount_in >= enemy2_center_y - enemy_border) && (vcount_in <= enemy2_center_y + enemy_border ) ) begin 
                rgb_nxt = 12'h0_0_f;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
            end
            else
                rgb_nxt = rgb_in;

            //slow enemy x axis following    
            if (enemy_center_x < mouse_xpos + ENEMY_CENTER) begin              // if true then move center to the right
                if (counter_move_x >= COUNTER_MOVE) begin
                    enemy_center_x_nxt = enemy_center_x + 1;  
                    counter_move_x_nxt = 0;
                end
                else
                    counter_move_x_nxt = counter_move_x + 1;
            end
            else if (enemy_center_x > mouse_xpos + ENEMY_CENTER ) begin         // if true then move center to the left
                if (counter_move_x >= COUNTER_MOVE) begin
                    enemy_center_x_nxt = enemy_center_x - 1;  
                    counter_move_x_nxt = 0;
                end
                else
                    counter_move_x_nxt = counter_move_x + 1; 
                end
            else begin                                          // if none true then stay in place on x axis
                enemy_center_x_nxt = enemy_center_x;
                counter_move_x_nxt = 0;
            end
            
            //slow enemy y axis following 
            if (enemy_center_y < mouse_ypos + ENEMY_CENTER) begin              // if true then move center downwords
                if (counter_move_y >= COUNTER_MOVE) begin
                    enemy_center_y_nxt = enemy_center_y + 1;  
                    counter_move_y_nxt = 0;
                end
                else
                    counter_move_y_nxt = counter_move_y + 1; 
            end
            else if (enemy_center_y > mouse_ypos + ENEMY_CENTER) begin         // if true then move center upwords
                if (counter_move_y >= COUNTER_MOVE) begin
                    enemy_center_y_nxt = enemy_center_y - 1;  
                    counter_move_y_nxt = 0;
                    end
                else
                    counter_move_y_nxt = counter_move_y + 1;  
            end
            else begin                                          // if none true then stay in place on y axis
                enemy_center_y_nxt = enemy_center_y;
                counter_move_y_nxt = 0;
            end

            //fast enemy x axis following    
            if (enemy2_center_x < mouse_xpos + ENEMY_CENTER) begin              // if true then move center to the right
                if (counter2_move_x >= COUNTER_FAST_MOVE) begin
                    enemy2_center_x_nxt = enemy2_center_x + 1;  
                    counter2_move_x_nxt = 0;
                end
                else
                    counter2_move_x_nxt = counter2_move_x + 1;
            end
            else if (enemy2_center_x > mouse_xpos + ENEMY_CENTER) begin         // if true then move center to the left
                if (counter2_move_x >= COUNTER_FAST_MOVE) begin
                    enemy2_center_x_nxt = enemy2_center_x - 1;  
                    counter2_move_x_nxt = 0;
                end
                else
                    counter2_move_x_nxt = counter2_move_x + 1; 
            end
            else begin                                          // if none true then stay in place on x axis
                enemy2_center_x_nxt = enemy2_center_x;
                counter2_move_x_nxt = 0;
            end
            
            //fast enemy y axis following 
            if (enemy2_center_y < mouse_ypos + ENEMY_CENTER) begin              // if true then move center downwords
                if (counter2_move_y >= COUNTER_FAST_MOVE) begin
                    enemy2_center_y_nxt = enemy2_center_y + 1;  
                    counter2_move_y_nxt = 0;
                end
                else
                    counter2_move_y_nxt = counter2_move_y + 1; 
            end
            else if (enemy2_center_y > mouse_ypos + ENEMY_CENTER) begin         // if true then move center upwords
                if (counter2_move_y >= COUNTER_FAST_MOVE) begin
                    enemy2_center_y_nxt = enemy2_center_y - 1;  
                    counter2_move_y_nxt = 0;
                    end
                else
                    counter2_move_y_nxt = counter2_move_y + 1;
            end
            else begin                                          // if none true then stay in place on y axis
                enemy2_center_y_nxt = enemy2_center_y;
                counter2_move_y_nxt = 0;
            end 
            
        end //end state
        
        ENEMY_DEATH: begin
            if (menu_on || !play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = ENEMY_DEATH;

            // top left enemy, yellow, slower    
            if ( (hcount_in >= enemy_center_x - enemy_border) && (hcount_in <= enemy_center_x + enemy_border) && (vcount_in >= enemy_center_y - enemy_border) && (vcount_in <= enemy_center_y + enemy_border ) ) 
                rgb_nxt = 12'hf_f_0;
            //bottom right enemy, blue, faster    
            else if ( (hcount_in >= enemy2_center_x - enemy_border) && (hcount_in <= enemy2_center_x + enemy_border) && (vcount_in >= enemy2_center_y - enemy_border) && (vcount_in <= enemy2_center_y + enemy_border ) ) 
                rgb_nxt = 12'h0_0_f;
            else
                rgb_nxt = rgb_in;

            if (enemy_border == 0) begin         //move to next state when reached set size                      
                state_nxt = IDLE;
                done_nxt = 1;
            end
            else begin                                      
                if (counter_growth >= COUNTER_GROWTH) begin
                    enemy_border_nxt = enemy_border - 1;  
                    counter_growth_nxt = 0;
                end
                else
                    counter_growth_nxt = counter_growth + 1;
            end   

        end //end state
    endcase
end
     
endmodule
