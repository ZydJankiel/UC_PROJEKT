`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.08.2021 14:35:07
// Design Name: 
// Module Name: splitting_obstacle
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
/MO-created module. 
/
*/

module splitting_obstacle(
    input wire  [11:0] vcount_in,
    input wire  [11:0] hcount_in,
    input wire clk,
    input wire rst,
    input wire game_on,
    input wire menu_on,
    input wire [11:0] rgb_in,
    input wire play_selected,
    input wire [3:0] selected,
    input wire done_in,
    input wire [11:0] mouse_xpos,
    input wire [11:0] mouse_ypos,
    
    output reg [11:0] rgb_out,
    output reg [11:0] obstacle_x,
    output reg [11:0] obstacle_y,
    output reg done
    );

localparam COUNTER_AIM              = 65000000,     //1 sec
           COUNTER_FASTER_MOVE      = 150000,
           COUNTER_FAST_MOVE        = 300000,
           COUNTER_AFTER_FALL       = 32500000;   //0,5 sec
           
localparam IDLE                 = 3'b000,
           THROW_FROM_TOP       = 3'b001,
           THROW_FROM_BOTTOM    = 3'b010,
           THROW_FROM_LEFT      = 3'b011,
           THROW_FROM_RIGHT     = 3'b100,
           THROW_DISTRIBUTOR    = 3'b101;

localparam AIMING   = 2'b00,
           FALLING  = 2'b01,
           SPLIT    = 2'b10;

localparam BIG_SQUARE_WIDTH     = 20,
           SMALL_SQUARE_WIDTH   = 15;

localparam GAME_FIELD_TOP       = 317,
           GAME_FIELD_BOTTOM    = 617,
           GAME_FIELD_LEFT      = 361,
           GAME_FIELD_RIGHT     = 661,
           MAX_DIST_FROM_BORDER = 90;

//basic regs           
reg [2:0] state, state_nxt;
reg [1:0] obstacle_state, obstacle_state_nxt;           
reg [11:0] rgb_nxt;
reg done_nxt;
    
//waiting counters
reg [25:0] aim_counter, aim_counter_nxt;
reg [25:0] counter_move_x, counter_move_x_nxt, counter_move_y, counter_move_y_nxt;
reg [25:0] counter_after_fall, counter_after_fall_nxt;

//dmg field of obstacle
reg [11:0] obstacle_x_nxt, obstacle_y_nxt;

//regs for moving the obstacle
reg [25:0] obstacle_center_x, obstacle_center_x_nxt, obstacle_center_y, obstacle_center_y_nxt; //main obstacle before split, also center obstacle after split
reg [25:0] obstacle_left_x, obstacle_left_x_nxt, obstacle_left_y, obstacle_left_y_nxt;     //left is also top obstacle after split
reg [25:0] obstacle_right_x, obstacle_right_x_nxt, obstacle_right_y ,obstacle_right_y_nxt;   //right is also bot obstacle after split

//specialist regs
reg [5:0] throw_counter, throw_counter_nxt;
reg aiming, aiming_nxt, joined, joined_nxt;



always @(posedge clk) begin
    if (rst) begin
        state                       <= IDLE;
        obstacle_state              <= AIMING;
        rgb_out                     <= 0; 
        obstacle_x                  <= 0;
        obstacle_y                  <= 0;
        counter_move_x              <= 0;
        counter_move_y              <= 0;
        counter_after_fall          <= 0;
        throw_counter               <= 0;
        done                        <= 0;
        aim_counter                 <= 0;
        aiming                      <= 0;
        joined                      <= 0;


    end
    else begin
        state                       <= state_nxt;
        obstacle_state              <= obstacle_state_nxt;
        rgb_out                     <= rgb_nxt;
        
        obstacle_center_x           <= obstacle_center_x_nxt;
        obstacle_center_y           <= obstacle_center_y_nxt;
        
        obstacle_left_x             <= obstacle_left_x_nxt;
        obstacle_left_y             <= obstacle_left_y_nxt;
        
        obstacle_right_x            <= obstacle_right_x_nxt;
        obstacle_right_y            <= obstacle_right_y_nxt;
        
        counter_move_x              <= counter_move_x_nxt;
        counter_move_y              <= counter_move_y_nxt;
        
        counter_after_fall          <= counter_after_fall_nxt;
        throw_counter               <= throw_counter_nxt;
        done                        <= done_nxt;
        aim_counter                 <= aim_counter_nxt;
        aiming                      <= aiming_nxt;
        joined                      <= joined_nxt;

    end
end

always @* begin
    rgb_nxt                         = rgb_in;
    state_nxt                       = IDLE;
    obstacle_state_nxt              = obstacle_state;
    counter_move_x_nxt              = counter_move_x;
    counter_move_y_nxt              = counter_move_y;
    counter_after_fall_nxt          = counter_after_fall;
    throw_counter_nxt               = throw_counter;
    obstacle_x_nxt                  = 0;
    obstacle_y_nxt                  = 0;
    done_nxt                        = 0;
    aim_counter_nxt                 = aim_counter;
    aiming_nxt                      = aiming;
    joined_nxt                      = joined;
    
    obstacle_center_x_nxt           = obstacle_center_x;
    obstacle_center_y_nxt           = obstacle_center_y;
    
    obstacle_left_x_nxt             = obstacle_left_x;
    obstacle_left_y_nxt             = obstacle_left_y;
    
    obstacle_right_x_nxt            = obstacle_right_x;
    obstacle_right_y_nxt            = obstacle_right_y;
    
    case (state)
        IDLE: begin
            if (done_in) begin
                //state_nxt = ((selected == 4'b0110) && play_selected) ? THROW_DISTRIBUTOR : IDLE;
                state_nxt = ((selected == 4'b0110) && play_selected) ? THROW_DISTRIBUTOR : IDLE;
            end
            else
                state_nxt = IDLE;

        end //end state
        
        THROW_DISTRIBUTOR: begin
            //finish obstacle
            if (throw_counter >= 20) begin

                end
            //THROW_FROM_TOP
            else if (throw_counter == 0 || throw_counter == 4 || throw_counter == 6 || throw_counter == 12 || throw_counter == 18 ) begin
                state_nxt = THROW_FROM_TOP;
                obstacle_center_x_nxt = 511;
                obstacle_center_y_nxt = GAME_FIELD_TOP + BIG_SQUARE_WIDTH;
                obstacle_left_x_nxt = 511;
                obstacle_left_y_nxt = GAME_FIELD_TOP + SMALL_SQUARE_WIDTH;
                obstacle_right_x_nxt = 511;
                obstacle_right_y_nxt = GAME_FIELD_TOP + SMALL_SQUARE_WIDTH;
                obstacle_state_nxt = AIMING;
                end
            //BARRAGE_FROM_TOP
            else if (throw_counter == 3 || throw_counter == 8 || throw_counter == 9 || throw_counter == 14 || throw_counter == 16 ) begin

                end
            //THROW_FROM_LEFT
            else if (throw_counter == 2 || throw_counter == 5 || throw_counter == 11 || throw_counter == 15 || throw_counter == 19 ) begin
                state_nxt = THROW_FROM_LEFT;
                obstacle_center_x_nxt = GAME_FIELD_LEFT + BIG_SQUARE_WIDTH;
                obstacle_center_y_nxt = 511;
                obstacle_left_x_nxt = GAME_FIELD_LEFT + SMALL_SQUARE_WIDTH;
                obstacle_left_y_nxt = 511;
                obstacle_right_x_nxt = GAME_FIELD_LEFT + SMALL_SQUARE_WIDTH;
                obstacle_right_y_nxt = 511;
                obstacle_state_nxt = AIMING;
                end
            //THROW_FROM_BOTTOM
            else if (throw_counter == 1 || throw_counter == 7 || throw_counter == 10 || throw_counter == 13 || throw_counter == 17 ) begin
                state_nxt = THROW_FROM_BOTTOM;
                obstacle_center_x_nxt = 511;
                obstacle_center_y_nxt = GAME_FIELD_BOTTOM - BIG_SQUARE_WIDTH;
                obstacle_left_x_nxt = 511;
                obstacle_left_y_nxt = GAME_FIELD_BOTTOM - SMALL_SQUARE_WIDTH;
                obstacle_right_x_nxt = 511;
                obstacle_right_y_nxt = GAME_FIELD_BOTTOM - SMALL_SQUARE_WIDTH;
                obstacle_state_nxt = AIMING;
                end
            //if somehow none of the above is true then end obstacle    
            else begin

                end


        end //end state
        
        THROW_FROM_TOP: begin
        
            if (menu_on || !play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = THROW_FROM_TOP; 
                
            case (obstacle_state)     
                AIMING: begin

                    if (hcount_in >= obstacle_center_x - BIG_SQUARE_WIDTH && hcount_in <= obstacle_center_x + BIG_SQUARE_WIDTH && vcount_in >= obstacle_center_y - BIG_SQUARE_WIDTH && vcount_in <= obstacle_center_y + BIG_SQUARE_WIDTH )  begin 
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else if (hcount_in >= obstacle_left_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_left_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_left_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_left_y + SMALL_SQUARE_WIDTH ) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else  if (hcount_in >= obstacle_right_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_right_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_right_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_right_y + SMALL_SQUARE_WIDTH ) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else 
                        rgb_nxt = rgb_in;
                        
                    if (aim_counter == COUNTER_AIM) begin
                        aim_counter_nxt = 0;
                        obstacle_state_nxt = FALLING;
                        end
                    else begin
                        aim_counter_nxt = aim_counter + 1;
                        obstacle_state_nxt = AIMING;
                    end
                    
                    //spike x axis following , all 3 squares are moving together  
                    if (obstacle_center_x < mouse_xpos + (BIG_SQUARE_WIDTH/2)) begin              
                        if (counter_move_x >= COUNTER_FAST_MOVE) begin
                            obstacle_center_x_nxt = obstacle_center_x + 1;
                            obstacle_left_x_nxt = obstacle_left_x + 1;
                            obstacle_right_x_nxt = obstacle_right_x + 1;
                            counter_move_x_nxt = 0;
                            end
                        else
                            counter_move_x_nxt = counter_move_x + 1;
                        end
                    else if (obstacle_center_x > mouse_xpos) begin         
                        if (counter_move_x >= COUNTER_FAST_MOVE) begin
                            obstacle_center_x_nxt = obstacle_center_x - 1;
                            obstacle_left_x_nxt = obstacle_left_x - 1;
                            obstacle_right_x_nxt = obstacle_right_x - 1;
                            counter_move_x_nxt = 0;
                            end
                        else
                            counter_move_x_nxt = counter_move_x + 1; 
                        end
                    else begin                                          
                        obstacle_center_x_nxt = obstacle_center_x;
                        counter_move_x_nxt = 0;
                        end
                end //end obstacle_state

                //all 3 of the squares falling together
                FALLING: begin
    
                    if (hcount_in >= obstacle_center_x - BIG_SQUARE_WIDTH && hcount_in <= obstacle_center_x + BIG_SQUARE_WIDTH && vcount_in >= obstacle_center_y - BIG_SQUARE_WIDTH && vcount_in <= obstacle_center_y + BIG_SQUARE_WIDTH )  begin 
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                   else if (hcount_in >= obstacle_left_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_left_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_left_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_left_y + SMALL_SQUARE_WIDTH ) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else if (hcount_in >= obstacle_right_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_right_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_right_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_right_y + SMALL_SQUARE_WIDTH ) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else 
                        rgb_nxt = rgb_in;
                        
                        
                    if (obstacle_center_y >= GAME_FIELD_TOP + MAX_DIST_FROM_BORDER) begin
                        obstacle_state_nxt = SPLIT;
                        end
                    else begin
                        obstacle_state_nxt =  FALLING;
                        //spike falling without changing x value
                        if (counter_move_y >= COUNTER_FAST_MOVE) begin  
                            obstacle_center_y_nxt = obstacle_center_y + 1;
                            obstacle_left_y_nxt = obstacle_left_y + 1;
                            obstacle_right_y_nxt = obstacle_right_y + 1;
                            counter_move_y_nxt = 0;
                            end
                        else begin
                            counter_move_y_nxt = counter_move_y + 1;
                            end
                        end    
                end //end obstacle_state
                
                //"left" and "right" square are starting to go in 45 degree angle towards opposite border
                SPLIT: begin

                    if ((hcount_in >= GAME_FIELD_LEFT && hcount_in <= GAME_FIELD_RIGHT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) &&         //squares are visible only inside the game_field
                    (hcount_in >= obstacle_center_x - BIG_SQUARE_WIDTH && hcount_in <= obstacle_center_x + BIG_SQUARE_WIDTH && vcount_in >= obstacle_center_y - BIG_SQUARE_WIDTH && vcount_in <= obstacle_center_y + BIG_SQUARE_WIDTH ))  begin 
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else if ( (hcount_in >= GAME_FIELD_LEFT && hcount_in <= GAME_FIELD_RIGHT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) &&   //squares are visible only inside the game_field
                    (hcount_in >= obstacle_left_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_left_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_left_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_left_y + SMALL_SQUARE_WIDTH) ) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else if ((hcount_in >= GAME_FIELD_LEFT && hcount_in <= GAME_FIELD_RIGHT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) &&    //squares are visible only inside the game_field
                    (hcount_in >= obstacle_right_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_right_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_right_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_right_y + SMALL_SQUARE_WIDTH )) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else 
                        rgb_nxt = rgb_in;
                        
                    //since all squares are movving towards opposite border with same speed, only need to check if one of them touched bottom    
                    if (obstacle_center_y >= GAME_FIELD_BOTTOM + BIG_SQUARE_WIDTH) begin
                        state_nxt = THROW_DISTRIBUTOR;
                        throw_counter_nxt = throw_counter + 1;
                        end
                    else begin
                        state_nxt =  THROW_FROM_TOP;
                        if (counter_move_y >= COUNTER_FAST_MOVE) begin  
                            obstacle_center_y_nxt = obstacle_center_y + 1;
                            obstacle_left_x_nxt = obstacle_left_x - 1;
                            obstacle_left_y_nxt = obstacle_left_y + 1;
                            obstacle_right_x_nxt = obstacle_right_x + 1;
                            obstacle_right_y_nxt = obstacle_right_y + 1;
                            counter_move_y_nxt = 0;
                            end
                        else begin
                            counter_move_y_nxt = counter_move_y + 1;
                            end
                        end   
                end //end obstacle_state
            endcase //end obstacle_state case

        end //end state

        THROW_FROM_BOTTOM: begin
        
            if (menu_on || !play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = THROW_FROM_BOTTOM; 
                
            case (obstacle_state)     
                AIMING: begin

                    if (hcount_in >= obstacle_center_x - BIG_SQUARE_WIDTH && hcount_in <= obstacle_center_x + BIG_SQUARE_WIDTH && vcount_in >= obstacle_center_y - BIG_SQUARE_WIDTH && vcount_in <= obstacle_center_y + BIG_SQUARE_WIDTH )  begin 
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else if (hcount_in >= obstacle_left_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_left_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_left_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_left_y + SMALL_SQUARE_WIDTH ) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else  if (hcount_in >= obstacle_right_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_right_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_right_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_right_y + SMALL_SQUARE_WIDTH ) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else 
                        rgb_nxt = rgb_in;
                        
                    if (aim_counter == COUNTER_AIM) begin
                        aim_counter_nxt = 0;
                        obstacle_state_nxt = FALLING;
                        end
                    else begin
                        aim_counter_nxt = aim_counter + 1;
                        obstacle_state_nxt = AIMING;
                    end
                    
                    // x axis following , all 3 squares are moving together  
                    if (obstacle_center_x < mouse_xpos + (BIG_SQUARE_WIDTH/2)) begin              
                        if (counter_move_x >= COUNTER_FAST_MOVE) begin
                            obstacle_center_x_nxt = obstacle_center_x + 1;
                            obstacle_left_x_nxt = obstacle_left_x + 1;
                            obstacle_right_x_nxt = obstacle_right_x + 1;
                            counter_move_x_nxt = 0;
                            end
                        else
                            counter_move_x_nxt = counter_move_x + 1;
                        end
                    else if (obstacle_center_x > mouse_xpos) begin         
                        if (counter_move_x >= COUNTER_FAST_MOVE) begin
                            obstacle_center_x_nxt = obstacle_center_x - 1;
                            obstacle_left_x_nxt = obstacle_left_x - 1;
                            obstacle_right_x_nxt = obstacle_right_x - 1;
                            counter_move_x_nxt = 0;
                            end
                        else
                            counter_move_x_nxt = counter_move_x + 1; 
                        end
                    else begin                                          
                        obstacle_center_x_nxt = obstacle_center_x;
                        counter_move_x_nxt = 0;
                        end
                end //end obstacle_state

                //all 3 of the squares falling together
                FALLING: begin
    
                    if (hcount_in >= obstacle_center_x - BIG_SQUARE_WIDTH && hcount_in <= obstacle_center_x + BIG_SQUARE_WIDTH && vcount_in >= obstacle_center_y - BIG_SQUARE_WIDTH && vcount_in <= obstacle_center_y + BIG_SQUARE_WIDTH )  begin 
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                   else if (hcount_in >= obstacle_left_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_left_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_left_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_left_y + SMALL_SQUARE_WIDTH ) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else if (hcount_in >= obstacle_right_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_right_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_right_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_right_y + SMALL_SQUARE_WIDTH ) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else 
                        rgb_nxt = rgb_in;
                        
                        
                    if (obstacle_center_y <= GAME_FIELD_BOTTOM - MAX_DIST_FROM_BORDER) begin
                        obstacle_state_nxt = SPLIT;
                        end
                    else begin
                        obstacle_state_nxt =  FALLING;

                        if (counter_move_y >= COUNTER_FAST_MOVE) begin  
                            obstacle_center_y_nxt = obstacle_center_y - 1;
                            obstacle_left_y_nxt = obstacle_left_y - 1;
                            obstacle_right_y_nxt = obstacle_right_y - 1;
                            counter_move_y_nxt = 0;
                            end
                        else begin
                            counter_move_y_nxt = counter_move_y + 1;
                            end
                        end    
                end //end obstacle_state
                
                //"left" and "right" square are starting to go in 45 degree angle towards opposite border
                SPLIT: begin
                    
                    if ((hcount_in >= GAME_FIELD_LEFT && hcount_in <= GAME_FIELD_RIGHT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) &&         //squares are visible only inside the game_field
                    (hcount_in >= obstacle_center_x - BIG_SQUARE_WIDTH && hcount_in <= obstacle_center_x + BIG_SQUARE_WIDTH && vcount_in >= obstacle_center_y - BIG_SQUARE_WIDTH && vcount_in <= obstacle_center_y + BIG_SQUARE_WIDTH ))  begin 
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else if ( (hcount_in >= GAME_FIELD_LEFT && hcount_in <= GAME_FIELD_RIGHT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) &&   //squares are visible only inside the game_field
                    (hcount_in >= obstacle_left_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_left_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_left_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_left_y + SMALL_SQUARE_WIDTH) ) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else if ((hcount_in >= GAME_FIELD_LEFT && hcount_in <= GAME_FIELD_RIGHT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) &&    //squares are visible only inside the game_field
                    (hcount_in >= obstacle_right_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_right_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_right_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_right_y + SMALL_SQUARE_WIDTH )) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else 
                        rgb_nxt = rgb_in;
                        
                    //since all squares are movving towards opposite border with same speed, only need to check if one of them touched bottom    
                    if (obstacle_center_y <= GAME_FIELD_TOP - BIG_SQUARE_WIDTH) begin
                        state_nxt = THROW_DISTRIBUTOR;
                        throw_counter_nxt = throw_counter + 1;
                        end
                    else begin
                        state_nxt =  THROW_FROM_BOTTOM;
                        if (counter_move_y >= COUNTER_FAST_MOVE) begin  
                            obstacle_center_y_nxt = obstacle_center_y - 1;
                            obstacle_left_x_nxt = obstacle_left_x - 1;
                            obstacle_left_y_nxt = obstacle_left_y - 1;
                            obstacle_right_x_nxt = obstacle_right_x + 1;
                            obstacle_right_y_nxt = obstacle_right_y - 1;
                            counter_move_y_nxt = 0;
                            end
                        else begin
                            counter_move_y_nxt = counter_move_y + 1;
                            end
                        end   
                end //end obstacle_state
            endcase //end obstacle_state case

        end //end state

        THROW_FROM_LEFT: begin
        
            if (menu_on || !play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = THROW_FROM_LEFT; 
                
            case (obstacle_state)     
                AIMING: begin

                    if (hcount_in >= obstacle_center_x - BIG_SQUARE_WIDTH && hcount_in <= obstacle_center_x + BIG_SQUARE_WIDTH && vcount_in >= obstacle_center_y - BIG_SQUARE_WIDTH && vcount_in <= obstacle_center_y + BIG_SQUARE_WIDTH )  begin 
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else if (hcount_in >= obstacle_left_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_left_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_left_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_left_y + SMALL_SQUARE_WIDTH ) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else  if (hcount_in >= obstacle_right_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_right_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_right_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_right_y + SMALL_SQUARE_WIDTH ) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else 
                        rgb_nxt = rgb_in;
                        
                    if (aim_counter == COUNTER_AIM) begin
                        aim_counter_nxt = 0;
                        obstacle_state_nxt = FALLING;
                        end
                    else begin
                        aim_counter_nxt = aim_counter + 1;
                        obstacle_state_nxt = AIMING;
                    end
                    
                    // x axis following , all 3 squares are moving together  
                    if (obstacle_center_y < mouse_ypos + (BIG_SQUARE_WIDTH/2)) begin              
                        if (counter_move_y >= COUNTER_FAST_MOVE) begin
                            obstacle_center_y_nxt = obstacle_center_y + 1;
                            obstacle_left_y_nxt = obstacle_left_y + 1;
                            obstacle_right_y_nxt = obstacle_right_y + 1;
                            counter_move_y_nxt = 0;
                            end
                        else
                            counter_move_y_nxt = counter_move_y + 1;
                        end
                    else if (obstacle_center_y > mouse_ypos) begin         
                        if (counter_move_y >= COUNTER_FAST_MOVE) begin
                            obstacle_center_y_nxt = obstacle_center_y - 1;
                            obstacle_left_y_nxt = obstacle_left_y - 1;
                            obstacle_right_y_nxt = obstacle_right_y - 1;
                            counter_move_y_nxt = 0;
                            end
                        else
                            counter_move_y_nxt = counter_move_y + 1; 
                        end
                    else begin                                          
                        obstacle_center_y_nxt = obstacle_center_y;
                        counter_move_y_nxt = 0;
                        end
                end //end obstacle_state

                //all 3 of the squares falling together
                FALLING: begin
    
                    if (hcount_in >= obstacle_center_x - BIG_SQUARE_WIDTH && hcount_in <= obstacle_center_x + BIG_SQUARE_WIDTH && vcount_in >= obstacle_center_y - BIG_SQUARE_WIDTH && vcount_in <= obstacle_center_y + BIG_SQUARE_WIDTH )  begin 
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                   else if (hcount_in >= obstacle_left_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_left_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_left_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_left_y + SMALL_SQUARE_WIDTH ) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else if (hcount_in >= obstacle_right_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_right_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_right_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_right_y + SMALL_SQUARE_WIDTH ) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else 
                        rgb_nxt = rgb_in;
                        
                        
                    if (obstacle_center_x >= GAME_FIELD_LEFT + MAX_DIST_FROM_BORDER) begin
                        obstacle_state_nxt = SPLIT;
                        end
                    else begin
                        obstacle_state_nxt =  FALLING;

                        if (counter_move_x >= COUNTER_FAST_MOVE) begin  
                            obstacle_center_x_nxt = obstacle_center_x + 1;
                            obstacle_left_x_nxt = obstacle_left_x + 1;
                            obstacle_right_x_nxt = obstacle_right_x + 1;
                            counter_move_x_nxt = 0;
                            end
                        else begin
                            counter_move_x_nxt = counter_move_x + 1;
                            end
                        end    
                end //end obstacle_state
                
                //"left" and "right" square are starting to go in 45 degree angle towards opposite border
                SPLIT: begin
                    
                    if ((hcount_in >= GAME_FIELD_LEFT && hcount_in <= GAME_FIELD_RIGHT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) &&         //squares are visible only inside the game_field
                    (hcount_in >= obstacle_center_x - BIG_SQUARE_WIDTH && hcount_in <= obstacle_center_x + BIG_SQUARE_WIDTH && vcount_in >= obstacle_center_y - BIG_SQUARE_WIDTH && vcount_in <= obstacle_center_y + BIG_SQUARE_WIDTH ))  begin 
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else if ( (hcount_in >= GAME_FIELD_LEFT && hcount_in <= GAME_FIELD_RIGHT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) &&   //squares are visible only inside the game_field
                    (hcount_in >= obstacle_left_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_left_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_left_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_left_y + SMALL_SQUARE_WIDTH) ) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else if ((hcount_in >= GAME_FIELD_LEFT && hcount_in <= GAME_FIELD_RIGHT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) &&    //squares are visible only inside the game_field
                    (hcount_in >= obstacle_right_x - SMALL_SQUARE_WIDTH && hcount_in <= obstacle_right_x + SMALL_SQUARE_WIDTH && vcount_in >= obstacle_right_y - SMALL_SQUARE_WIDTH && vcount_in <= obstacle_right_y + SMALL_SQUARE_WIDTH )) begin
                        rgb_nxt = 12'hf_f_f;
                        obstacle_x_nxt = hcount_in;
                        obstacle_y_nxt = vcount_in;
                        end
                    else 
                        rgb_nxt = rgb_in;
                        
                    //since all squares are movving towards opposite border with same speed, only need to check if one of them touched bottom    
                    if (obstacle_center_x >= GAME_FIELD_RIGHT + BIG_SQUARE_WIDTH) begin
                        state_nxt = THROW_DISTRIBUTOR;
                        throw_counter_nxt = throw_counter + 1;
                        end
                    else begin
                        state_nxt =  THROW_FROM_LEFT;
                        if (counter_move_x >= COUNTER_FAST_MOVE) begin  
                            obstacle_center_x_nxt = obstacle_center_x + 1;
                            obstacle_left_x_nxt = obstacle_left_x + 1;
                            obstacle_left_y_nxt = obstacle_left_y - 1;
                            obstacle_right_x_nxt = obstacle_right_x + 1;
                            obstacle_right_y_nxt = obstacle_right_y + 1;
                            counter_move_x_nxt = 0;
                            end
                        else begin
                            counter_move_x_nxt = counter_move_x + 1;
                            end
                        end   
                end //end obstacle_state
            endcase //end obstacle_state case

        end //end state

        
    endcase //end state case
end 
   
endmodule
