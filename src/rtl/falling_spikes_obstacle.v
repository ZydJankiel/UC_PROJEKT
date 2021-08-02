`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.07.2021 14:57:50
// Design Name: 
// Module Name: falling_spikes_obstacle
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
/MO-created module. Despite knowing how to display static triangles in all 4 directions  on screen (code at the end of file) i could not 
/ find a reasonable way to display triangles facing right and left - bec of the fact that creating slope on screen sometimes requires 
/ comparing hcount and vcount to negative number both of them (hcount and vcount) had to be transformed into "signed" form which is two's complement
/ in order to properly compare values. This resulted in problems of not meeting timing requirements in different wire across the whole program (even outside of "CORE")
/ (Total Negative slack ranged from -9ns  to -250ns in warious attempts to fix this issue in this module). In the end it was decided that it is not worth the effort
/ of rewriting code in warious modules just for the sake of this one module.
/
*/

module falling_spikes_obstacle(
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
    //input wire [11:0] mouse_ypos, Needed in horizontal spikes but unused due to problem with them.
    
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
           SPIKE_FROM_TOP       = 3'b001,
           SPIKE_FROM_BOTTOM    = 3'b010,
           BARRAGE_FROM_BOTTOM  = 3'b011,
           BARRAGE_FROM_TOP     = 3'b100,
           SPIKE_DISTRIBUTOR    = 3'b101;

           
localparam SPIKE_WIDTH          = 20;

localparam GAME_FIELD_TOP       = 317,
           GAME_FIELD_BOTTOM    = 617,
           GAME_FIELD_LEFT      = 361,
           GAME_FIELD_RIGHT     = 661,
           WARNING_BORDER       = 10;
    
reg [25:0] counter_move_x, counter_move_x_nxt, counter_move_y, counter_move_y_nxt;
reg [25:0] counter_after_fall, counter_after_fall_nxt;
reg [11:0] rgb_nxt;
reg [11:0] obstacle_x_nxt, obstacle_y_nxt;
reg [2:0] state, state_nxt;
reg done_nxt;
reg [25:0] aim_counter, aim_counter_nxt;

reg [5:0] spike_counter, spike_counter_nxt;
reg warning, warning_nxt;
reg [25:0] spike_left_or_top_slope, spike_left_or_top_slope_nxt, spike_right_or_bot_slope, spike_right_or_bot_slope_nxt;
reg [25:0] spike_center_x, spike_center_x_nxt, spike_center_y, spike_center_y_nxt;


always @(posedge clk) begin
    if (rst) begin
        state                       <= IDLE;
        rgb_out                     <= 0; 
        obstacle_x                  <= 0;
        obstacle_y                  <= 0;
        counter_move_x              <= 0;
        counter_move_y              <= 0;
        counter_after_fall          <= 0;
        spike_center_x              <= 0;
        spike_center_y              <= 0;
        spike_counter               <= 0;
        done                        <= 0;
        aim_counter                 <= 0;
        warning                     <= 0;
        spike_left_or_top_slope     <= 0;
        spike_right_or_bot_slope    <= 0;

    end
    else begin
        state                       <= state_nxt;
        rgb_out                     <= rgb_nxt;
        obstacle_x                  <= obstacle_x_nxt;
        obstacle_y                  <= obstacle_y_nxt;
        counter_move_x              <= counter_move_x_nxt;
        counter_move_y              <= counter_move_y_nxt;
        counter_after_fall          <= counter_after_fall_nxt;
        spike_center_x              <= spike_center_x_nxt;
        spike_center_y              <= spike_center_y_nxt;
        spike_counter               <= spike_counter_nxt;
        done                        <= done_nxt;
        aim_counter                 <= aim_counter_nxt;
        warning                     <= warning_nxt;
        spike_left_or_top_slope     <= spike_left_or_top_slope_nxt;
        spike_right_or_bot_slope    <= spike_right_or_bot_slope_nxt;

    end
end

always @* begin
    rgb_nxt                         = rgb_in;
    state_nxt                       = IDLE;
    counter_move_x_nxt              = counter_move_x;
    counter_move_y_nxt              = counter_move_y;
    counter_after_fall_nxt          = counter_after_fall;
    spike_counter_nxt               = spike_counter;
    obstacle_x_nxt                  = 0;
    obstacle_y_nxt                  = 0;
    done_nxt                        = 0;
    aim_counter_nxt                 = aim_counter;
    warning_nxt                     = warning;
    spike_left_or_top_slope_nxt     = spike_left_or_top_slope;
    spike_right_or_bot_slope_nxt    = spike_right_or_bot_slope;
    spike_center_x_nxt              = spike_center_x;
    spike_center_y_nxt              = spike_center_y;
    case (state)
        IDLE: begin
            if (done_in) begin
                state_nxt = ((selected == 4'b0101) && play_selected) ? SPIKE_DISTRIBUTOR : IDLE;
            end
            else
                state_nxt = IDLE;

        end //end state
        
        SPIKE_DISTRIBUTOR: begin
            //finish obstacle
            if (spike_counter >= 20) begin
                state_nxt = IDLE;
                counter_move_x_nxt = 0;
                counter_move_y_nxt = 0;
                aim_counter_nxt = 0;
                warning_nxt = 1;
                done_nxt = 1;
                end
            //SPIKE_FROM_TOP
            else if (spike_counter == 0 || spike_counter == 4 || spike_counter == 6 || spike_counter == 12 || spike_counter == 18 ) begin
                state_nxt = SPIKE_FROM_TOP;
                spike_center_y_nxt = GAME_FIELD_TOP;
                spike_center_x_nxt = 511;
                spike_left_or_top_slope_nxt = 1170;
                spike_right_or_bot_slope_nxt = 1890;
                warning_nxt = 1;
                end
            //BARRAGE_FROM_TOP
            else if (spike_counter == 3 || spike_counter == 8 || spike_counter == 9 || spike_counter == 14 || spike_counter == 16 ) begin
                state_nxt = BARRAGE_FROM_TOP;
                spike_center_y_nxt = GAME_FIELD_TOP;
                spike_center_x_nxt = 511;
                spike_left_or_top_slope_nxt = 1170;
                spike_right_or_bot_slope_nxt = 1890;
                warning_nxt = 1;
                end
            //SPIKE_FROM_BOTTOM
            else if (spike_counter == 2 || spike_counter == 5 || spike_counter == 11 || spike_counter == 15 || spike_counter == 19 ) begin
                state_nxt = SPIKE_FROM_BOTTOM;
                spike_center_y_nxt = GAME_FIELD_BOTTOM;
                spike_center_x_nxt = 511;
                spike_left_or_top_slope_nxt = 965;
                spike_right_or_bot_slope_nxt = 2100;
                warning_nxt = 1;
                end
            //BARRAGE_FROM_BOTTOM
            else if (spike_counter == 1 || spike_counter == 7 || spike_counter == 10 || spike_counter == 13 || spike_counter == 17 ) begin
                state_nxt = BARRAGE_FROM_BOTTOM;
                spike_center_y_nxt = GAME_FIELD_BOTTOM;
                spike_center_x_nxt = 511;
                spike_left_or_top_slope_nxt = 965;
                spike_right_or_bot_slope_nxt = 2100;
                warning_nxt = 1;
                end
            //if somehow none of the above is true then end obstacle    
            else begin
                state_nxt = IDLE;
                counter_move_x_nxt = 0;
                counter_move_y_nxt = 0;
                aim_counter_nxt = 0;
                warning_nxt = 1;
                done_nxt = 1;
                end


        end //end state
        
        
        SPIKE_FROM_TOP: begin
        
            if (menu_on || !play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = SPIKE_FROM_TOP; 
                
            if (warning) begin
                //in last 2 comps - more in spike_right... and less in spike_left... makes triangle bigger , multiplying hcount gives greater slope (if x>1) or smaller slope (if x<1)
                //to move spike downwards in spike_right... add difference and in spike_left... subtract
                //when moving spike sideways add (or subtract) to both spike_right... and spike_left... value of 3*x_difference 
                if (hcount_in >= spike_center_x - SPIKE_WIDTH && hcount_in <= spike_center_x + SPIKE_WIDTH && vcount_in >= spike_center_y_nxt && (vcount_in <= spike_center_y_nxt + 50) && ((3 * hcount_in) + vcount_in) <= spike_right_or_bot_slope_nxt && ((3 * hcount_in) - vcount_in) >= spike_left_or_top_slope_nxt)  begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    end
                else 
                    rgb_nxt = rgb_in;
                    
                if (aim_counter == COUNTER_AIM) begin
                    aim_counter_nxt = 0;
                    warning_nxt = 0;
                    end
                else 
                    aim_counter_nxt = aim_counter + 1;

                //spike x axis following    
                if (spike_center_x < mouse_xpos + (SPIKE_WIDTH/2)) begin              
                    if (counter_move_x >= COUNTER_FAST_MOVE) begin
                        spike_center_x_nxt = spike_center_x + 1;
                        spike_left_or_top_slope_nxt = spike_left_or_top_slope +3;
                        spike_right_or_bot_slope_nxt = spike_right_or_bot_slope +3;
                        counter_move_x_nxt = 0;
                    end
                    else
                        counter_move_x_nxt = counter_move_x + 1;
                end
                else if (spike_center_x > mouse_xpos) begin         
                    if (counter_move_x >= COUNTER_FAST_MOVE) begin
                        spike_left_or_top_slope_nxt = spike_left_or_top_slope -3;
                        spike_right_or_bot_slope_nxt = spike_right_or_bot_slope -3;
                        spike_center_x_nxt = spike_center_x - 1;  
                        counter_move_x_nxt = 0;
                    end
                    else
                        counter_move_x_nxt = counter_move_x + 1; 
                    end
                else begin                                          
                    spike_center_x_nxt = spike_center_x;
                    counter_move_x_nxt = 0;
                end

                end 
            else begin
                //in last 2 comps - more in spike_right... and less in spike_left... makes triangle bigger , multiplying hcount gives greater slope (if x>1) or smaller slope (if x<1)
                //to move spike downwards in spike_right... add difference and in spike_left... subtract
                //when moving spike sideways add (or subtract) to both spike_right... and spike_left... value of 3*x_difference 
                if (hcount_in >= spike_center_x - SPIKE_WIDTH && hcount_in <= spike_center_x + SPIKE_WIDTH && vcount_in >= spike_center_y && (vcount_in <= spike_center_y + 50) && ((3 * hcount_in) + vcount_in) <= spike_right_or_bot_slope_nxt && ((3 * hcount_in) - vcount_in) >= spike_left_or_top_slope_nxt)  begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    end
                else begin
                    rgb_nxt = rgb_in;
                    end
                
                if (spike_center_y >= GAME_FIELD_BOTTOM - SPIKE_WIDTH) begin
                    //if stuck in game field frame go to next state after delay
                    if (counter_after_fall >= COUNTER_AFTER_FALL) begin  
                        state_nxt = SPIKE_DISTRIBUTOR;
                        spike_counter_nxt = spike_counter + 1;
                        counter_after_fall_nxt = 0;
                        end
                    else begin
                        counter_after_fall_nxt = counter_after_fall + 1;
                        state_nxt =  SPIKE_FROM_TOP;
                        end
                    end
                else begin
                    state_nxt =  SPIKE_FROM_TOP;
                    //spike falling without changing x value
                    if (counter_move_y >= COUNTER_FAST_MOVE) begin  
                        spike_center_y_nxt = spike_center_y + 1;
                        spike_left_or_top_slope_nxt = spike_left_or_top_slope - 1;
                        spike_right_or_bot_slope_nxt = spike_right_or_bot_slope + 1;
                        counter_move_y_nxt = 0;
                        end
                    else begin
                        counter_move_y_nxt = counter_move_y + 1;
                        end
                    end    
                end
                
  
        end //end state
        
        SPIKE_FROM_BOTTOM: begin
        
            if (menu_on || !play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = SPIKE_FROM_BOTTOM; 
                
            if (warning) begin
                //to move spike downwards in <= subtract difference and in >= add
                //when moving spike sideways add (or subtract) to both <= and >= value of 3*x_difference  
                if (hcount_in >= spike_center_x - SPIKE_WIDTH && hcount_in <= spike_center_x + SPIKE_WIDTH && (vcount_in >= spike_center_y - 50) && (vcount_in <= spike_center_y) && ((3 * hcount_in) + vcount_in) >= spike_right_or_bot_slope_nxt && ((3 * hcount_in) - vcount_in) <= spike_left_or_top_slope_nxt)  begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    end
                else 
                    rgb_nxt = rgb_in;
                    
                if (aim_counter == COUNTER_AIM) begin
                    aim_counter_nxt = 0;
                    warning_nxt = 0;
                    end
                else 
                    aim_counter_nxt = aim_counter + 1;

                //spike x axis following    
                if (spike_center_x < mouse_xpos + (SPIKE_WIDTH/2)) begin              
                    if (counter_move_x >= COUNTER_FAST_MOVE) begin
                        spike_center_x_nxt = spike_center_x + 1;
                        spike_left_or_top_slope_nxt = spike_left_or_top_slope +3;
                        spike_right_or_bot_slope_nxt = spike_right_or_bot_slope +3;
                        counter_move_x_nxt = 0;
                    end
                    else
                        counter_move_x_nxt = counter_move_x + 1;
                end
                else if (spike_center_x > mouse_xpos) begin         
                    if (counter_move_x >= COUNTER_FAST_MOVE) begin
                        spike_left_or_top_slope_nxt = spike_left_or_top_slope -3;
                        spike_right_or_bot_slope_nxt = spike_right_or_bot_slope -3;
                        spike_center_x_nxt = spike_center_x - 1;  
                        counter_move_x_nxt = 0;
                    end
                    else
                        counter_move_x_nxt = counter_move_x + 1; 
                    end
                else begin                                          
                    spike_center_x_nxt = spike_center_x;
                    counter_move_x_nxt = 0;
                end

                end 
            else begin
                //to move spike downwards in <= subtract difference and in >= add
                //when moving spike sideways add (or subtract) to both <= and >= value of 3*x_difference 
                if (hcount_in >= spike_center_x - SPIKE_WIDTH && hcount_in <= spike_center_x + SPIKE_WIDTH && (vcount_in >= spike_center_y - 50) && (vcount_in <= spike_center_y) && ((3 * hcount_in) + vcount_in) >= spike_right_or_bot_slope_nxt && ((3 * hcount_in) - vcount_in) <= spike_left_or_top_slope_nxt)  begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    end
                else begin
                    rgb_nxt = rgb_in;
                    end

                if (counter_move_y >= COUNTER_FAST_MOVE) begin  
                    spike_center_y_nxt = spike_center_y - 1;
                    spike_left_or_top_slope_nxt = spike_left_or_top_slope + 1;
                    spike_right_or_bot_slope_nxt = spike_right_or_bot_slope - 1;
                    counter_move_y_nxt = 0;
                    end
                else begin
                    counter_move_y_nxt = counter_move_y + 1;
                    end
                
                if (spike_center_y <= GAME_FIELD_TOP + SPIKE_WIDTH) begin
                    state_nxt = SPIKE_DISTRIBUTOR;
                    spike_counter_nxt = spike_counter + 1;
                    counter_after_fall_nxt = 0;
                    end
                else
                    state_nxt =  SPIKE_FROM_BOTTOM;
                end
                
  
        end //end state
        
        BARRAGE_FROM_TOP: begin

            if (menu_on || !play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = BARRAGE_FROM_TOP; 
                
            if (warning) begin
                //in last 2 comps - more in spike_right... and less in spike_left... makes triangle bigger , multiplying hcount gives greater slope (if x>1) or smaller slope (if x<1)
                //to move spike downwards in spike_right... add difference and in spike_left... subtract
                //when moving spike sideways add (or subtract) to both spike_right... and spike_left... value of 3*x_difference 
                if (hcount_in >= spike_center_x - SPIKE_WIDTH && hcount_in <= spike_center_x + SPIKE_WIDTH && vcount_in >= spike_center_y_nxt && (vcount_in <= spike_center_y_nxt + 50) && ((3 * hcount_in) + vcount_in) <= spike_right_or_bot_slope_nxt && ((3 * hcount_in) - vcount_in) >= spike_left_or_top_slope_nxt)  begin 
                    rgb_nxt = 12'hf_0_0;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    end
                else 
                    rgb_nxt = rgb_in;
                    
                if (aim_counter == COUNTER_AIM) begin
                    aim_counter_nxt = 0;
                    warning_nxt = 0;
                    end
                else 
                    aim_counter_nxt = aim_counter + 1;

                //spike x axis following    
                if (spike_center_x < mouse_xpos + (SPIKE_WIDTH/2)) begin              
                    if (counter_move_x >= COUNTER_FASTER_MOVE) begin
                        spike_center_x_nxt = spike_center_x + 1;
                        spike_left_or_top_slope_nxt = spike_left_or_top_slope +3;
                        spike_right_or_bot_slope_nxt = spike_right_or_bot_slope +3;
                        counter_move_x_nxt = 0;
                    end
                    else
                        counter_move_x_nxt = counter_move_x + 1;
                end
                else if (spike_center_x > mouse_xpos) begin         
                    if (counter_move_x >= COUNTER_FASTER_MOVE) begin
                        spike_left_or_top_slope_nxt = spike_left_or_top_slope -3;
                        spike_right_or_bot_slope_nxt = spike_right_or_bot_slope -3;
                        spike_center_x_nxt = spike_center_x - 1;  
                        counter_move_x_nxt = 0;
                    end
                    else
                        counter_move_x_nxt = counter_move_x + 1; 
                    end
                else begin                                          
                    spike_center_x_nxt = spike_center_x;
                    counter_move_x_nxt = 0;
                end

                end 
            else begin
                //in last 2 comps - more in spike_right... and less in spike_left... makes triangle bigger , multiplying hcount gives greater slope (if x>1) or smaller slope (if x<1)
                //to move spike downwards in spike_right... add difference and in spike_left... subtract
                //when moving spike sideways add (or subtract) to both spike_right... and spike_left... value of 3*x_difference 
                if (hcount_in >= spike_center_x - SPIKE_WIDTH && hcount_in <= spike_center_x + SPIKE_WIDTH && vcount_in >= spike_center_y && (vcount_in <= spike_center_y + 50) && ((3 * hcount_in) + vcount_in) <= spike_right_or_bot_slope_nxt && ((3 * hcount_in) - vcount_in) >= spike_left_or_top_slope_nxt)  begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    end
                else begin
                    rgb_nxt = rgb_in;
                    end

                if (counter_move_y >= COUNTER_FASTER_MOVE) begin  
                    spike_center_y_nxt = spike_center_y + 1;
                    spike_left_or_top_slope_nxt = spike_left_or_top_slope - 1;
                    spike_right_or_bot_slope_nxt = spike_right_or_bot_slope + 1;
                    counter_move_y_nxt = 0;
                    end
                else begin
                    counter_move_y_nxt = counter_move_y + 1;
                    end
                
                if (spike_center_y >= GAME_FIELD_BOTTOM - SPIKE_WIDTH) begin
                    state_nxt = SPIKE_DISTRIBUTOR;
                    spike_counter_nxt = spike_counter + 1;
                    counter_after_fall_nxt = 0;
                    end
                else
                    state_nxt =  BARRAGE_FROM_TOP;
                end

        end //end state

        BARRAGE_FROM_BOTTOM: begin
        
            if (menu_on || !play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = BARRAGE_FROM_BOTTOM; 
                
            if (warning) begin
                //to move spike downwards in <= subtract difference and in >= add
                //when moving spike sideways add (or subtract) to both <= and >= value of 3*x_difference  
                if (hcount_in >= spike_center_x - SPIKE_WIDTH && hcount_in <= spike_center_x + SPIKE_WIDTH && (vcount_in >= spike_center_y - 50) && (vcount_in <= spike_center_y) && ((3 * hcount_in) + vcount_in) >= spike_right_or_bot_slope_nxt && ((3 * hcount_in) - vcount_in) <= spike_left_or_top_slope_nxt)  begin 
                    rgb_nxt = 12'hf_0_0;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    end
                else 
                    rgb_nxt = rgb_in;
                    
                if (aim_counter == COUNTER_AIM) begin
                    aim_counter_nxt = 0;
                    warning_nxt = 0;
                    end
                else 
                    aim_counter_nxt = aim_counter + 1;

                //spike x axis following    
                if (spike_center_x < mouse_xpos + (SPIKE_WIDTH/2)) begin              
                    if (counter_move_x >= COUNTER_FASTER_MOVE) begin
                        spike_center_x_nxt = spike_center_x + 1;
                        spike_left_or_top_slope_nxt = spike_left_or_top_slope +3;
                        spike_right_or_bot_slope_nxt = spike_right_or_bot_slope +3;
                        counter_move_x_nxt = 0;
                    end
                    else
                        counter_move_x_nxt = counter_move_x + 1;
                end
                else if (spike_center_x > mouse_xpos) begin         
                    if (counter_move_x >= COUNTER_FASTER_MOVE) begin
                        spike_left_or_top_slope_nxt = spike_left_or_top_slope -3;
                        spike_right_or_bot_slope_nxt = spike_right_or_bot_slope -3;
                        spike_center_x_nxt = spike_center_x - 1;  
                        counter_move_x_nxt = 0;
                    end
                    else
                        counter_move_x_nxt = counter_move_x + 1; 
                    end
                else begin                                          
                    spike_center_x_nxt = spike_center_x;
                    counter_move_x_nxt = 0;
                end

                end 
            else begin
                //to move spike downwards in <= subtract difference and in >= add
                //when moving spike sideways add (or subtract) to both <= and >= value of 3*x_difference 
                if (hcount_in >= spike_center_x - SPIKE_WIDTH && hcount_in <= spike_center_x + SPIKE_WIDTH && (vcount_in >= spike_center_y - 50) && (vcount_in <= spike_center_y) && ((3 * hcount_in) + vcount_in) >= spike_right_or_bot_slope_nxt && ((3 * hcount_in) - vcount_in) <= spike_left_or_top_slope_nxt)  begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    end
                else begin
                    rgb_nxt = rgb_in;
                    end

                if (counter_move_y >= COUNTER_FASTER_MOVE) begin  
                    spike_center_y_nxt = spike_center_y - 1;
                    spike_left_or_top_slope_nxt = spike_left_or_top_slope + 1;
                    spike_right_or_bot_slope_nxt = spike_right_or_bot_slope - 1;
                    counter_move_y_nxt = 0;
                    end
                else begin
                    counter_move_y_nxt = counter_move_y + 1;
                    end
                
                if (spike_center_y <= GAME_FIELD_TOP + SPIKE_WIDTH) begin
                    state_nxt = SPIKE_DISTRIBUTOR;
                    spike_counter_nxt = spike_counter + 1;
                    counter_after_fall_nxt = 0;
                    end
                else
                    state_nxt =  BARRAGE_FROM_BOTTOM;
                end
                

        end //end state




    endcase
end
        







endmodule




// obsolete code for dispalying and moving spike from left side of game field to right, not implemented due to reasons stated before
/*
        SPIKE_FROM_LEFT: begin
        
            if (menu_on || !play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = SPIKE_FROM_LEFT; 
            // else if (hcount_in >= 361 && hcount_in <= 411 && vcount_in >= 300 && vcount_in <= 340 && (((3 * hcount_in)/10) + vcount_in) <= 440 && (((3 * hcount_in)/10) - vcount_in) <= -200)
            spike_left_or_top_slope_nxt = -25'sb00000000000000000110000110;
            spike_right_or_bot_slope_nxt = 630;
            if (warning) begin
                //to move down add to 1st comparison and subtarct from 2nd
                // to move right add to both comparisons 0,3*x_difference
                if (signed_hcount >= spike_center_x && signed_hcount <= spike_center_x + 50 && (signed_vcount >= spike_center_y - SPIKE_WIDTH) && (signed_vcount <= spike_center_y + SPIKE_WIDTH) && (((3 * signed_hcount)/10) + signed_vcount) <= spike_right_or_bot_slope_nxt && (((3 * signed_hcount)/10) - signed_vcount) <= spike_left_or_top_slope_nxt)  begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    end
                else 
                    rgb_nxt = rgb_in;
                   
                if (warning_counter == COUNTER_WARNING) begin
                    warning_counter_nxt = 0;
                    //warning_nxt = 0;
                    end
                else 
                    warning_counter_nxt = warning_counter + 1;
                
                //spike y axis following    
                if (spike_center_y < mouse_ypos + (SPIKE_WIDTH/2)) begin              
                    if (counter_move_y >= COUNTER_FAST_MOVE) begin
                        spike_center_y_nxt = spike_center_y + 1;
                        spike_left_or_top_slope_nxt = spike_left_or_top_slope - 1;
                        spike_right_or_bot_slope_nxt = spike_right_or_bot_slope + 1;
                        counter_move_y_nxt = 0;
                    end
                    else
                        counter_move_y_nxt = counter_move_y + 1;
                end
                else if (spike_center_y > mouse_ypos) begin         
                    if (counter_move_y >= COUNTER_FAST_MOVE) begin
                        spike_center_y_nxt = spike_center_y - 1; 
                        spike_left_or_top_slope_nxt = spike_left_or_top_slope + 1;
                        spike_right_or_bot_slope_nxt = spike_right_or_bot_slope - 1;
                        counter_move_y_nxt = 0;
                    end
                    else
                        counter_move_y_nxt = counter_move_y + 1; 
                    end
                else begin                                          
                    spike_center_y_nxt = spike_center_y;
                    counter_move_y_nxt = 0;
                    end
                    
                end 
            else begin
                //to move down add to 1st comparison and subtarct from 2nd
                // to move right add to both comparisons 0,3*x_difference
                if (hcount_in >= spike_center_x  && hcount_in <= spike_center_x + SPIKE_WIDTH && (vcount_in >= spike_center_y - 50) && (vcount_in <= spike_center_y) && (((3 * hcount_in)/10) + vcount_in) <= spike_right_or_bot_slope_nxt && (((3 * hcount_in)/10) - vcount_in) <= spike_left_or_top_slope_nxt)  begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    end
                else begin
                    rgb_nxt = rgb_in;
                    end

                if (counter_move_x >= COUNTER_MOVE) begin  
                    spike_center_x_nxt = spike_center_x + 3;
                    spike_left_or_top_slope_nxt = spike_left_or_top_slope + 1;
                    spike_right_or_bot_slope_nxt = spike_right_or_bot_slope + 1;
                    counter_move_x_nxt = 0;
                    end
                else begin
                    counter_move_x_nxt = counter_move_x + 1;
                    end
                
                if (spike_center_x >= GAME_FIELD_RIGHT - SPIKE_WIDTH) begin
                    state_nxt = SPIKE_FROM_RIGHT;
                    spike_center_x_nxt = 511;
                    spike_left_or_top_slope_nxt = 1170;
                    spike_right_or_bot_slope_nxt = 1890;
                    spike_center_y_nxt = GAME_FIELD_LEFT;
                    warning_nxt = 1;
                    end
                else
                    state_nxt =  SPIKE_FROM_LEFT;
                end
                
  
        end //end state
*/ 


//examples of displaying static triangles in 4 directions
                /*
                else if (hcount_in >= 120 && hcount_in <= 160 && vcount_in >= 300 && vcount_in <= 350 && ((3 * hcount_in) + vcount_in) <= 770 && ((3 * hcount_in) - vcount_in) >= 70)   
                //in last 2 comps - more in <= and less in >= makes triangle bigger , multiplying hcount gives bigger slope     
                    rgb_nxt = 12'h0_f_f;
                else if (hcount_in >= 120 && hcount_in <= 160 && vcount_in >= 500 && vcount_in <= 550 && ((3 * hcount_in) + vcount_in) <= 970 && ((3 * hcount_in) - vcount_in) >= -130)
                    rgb_nxt = 12'h0_f_f;  
                else if (hcount_in >= 120 && hcount_in <= 160 && vcount_in >= 600 && vcount_in <= 650 && ((3 * hcount_in) + vcount_in) <= 1070 && ((3 * hcount_in) - vcount_in) >= -230)
                    rgb_nxt = 12'h0_f_f;  
                else if (hcount_in >= 420 && hcount_in <= 460 && vcount_in >= 300 && vcount_in <= 350 && ((3 * hcount_in) + vcount_in) <= 1670 && ((3 * hcount_in) - vcount_in) >= 970)
                    rgb_nxt = 12'hf_0_f;  
                else if (hcount_in >= 420 && hcount_in <= 460 && vcount_in >= 500 && vcount_in <= 550 && ((3 * hcount_in) + vcount_in) <= 1870 && ((3 * hcount_in) - vcount_in) >= 770)
                    rgb_nxt = 12'hf_0_f; 
                //in last 2 comps - more in <= and less in >= makes triangle bigger , multiplying hcount gives bigger slope     
                //to move spike downwards in <= add difference and in >= subtract
                //when moving spike sideways add (or subtract) to both <= and >= value of 3*x_difference  
                
                //rightwards spike
                else if (hcount_in >= 361 && hcount_in <= 411 && vcount_in >= 300 && vcount_in <= 340 && (((3 * hcount_in)/10) + vcount_in) <= 440 && (((3 * hcount_in)/10) - vcount_in) <= -200)
                    rgb_nxt = 12'hf_0_f; 
    
                else if (hcount_in >= 361 && hcount_in <= 411 && vcount_in >= 500 && vcount_in <= 540 && ((3 * hcount_in)/10 + vcount_in) <= 640 && ((3 * hcount_in)/10 - vcount_in) <= -400)
                    rgb_nxt = 12'hf_0_f; 
                else if (hcount_in >= 561 && hcount_in <= 611 && vcount_in >= 500 && vcount_in <= 540 && ((3 * hcount_in)/10 + vcount_in) <= 700 && ((3 * hcount_in)/10 - vcount_in) <= -340)
                    rgb_nxt = 12'hf_0_f; 
                //to move down add to 1st comparison and subtarct from 2nd
                // to move right add to both comparisons 0,3*x_difference
                
                //leftwardsspike    
                else if (hcount_in >= 611 && hcount_in <= 661 && vcount_in >= 300 && vcount_in <= 340 && (((3 * hcount_in)/10) + vcount_in) >= 505 && (((3 * hcount_in)/10) - vcount_in) >= -135)
                    rgb_nxt = 12'hf_f_0;
                    
                else if (hcount_in >= 611 && hcount_in <= 661 && vcount_in >= 400 && vcount_in <= 440 && (((3 * hcount_in)/10) + vcount_in) >= 605 && (((3 * hcount_in)/10) - vcount_in) >= -235)
                    rgb_nxt = 12'hf_f_0;
                else if (hcount_in >= 361 && hcount_in <= 411 && vcount_in >= 400 && vcount_in <= 440 && (((3 * hcount_in)/10) + vcount_in) >= 530 && (((3 * hcount_in)/10) - vcount_in) >= -310)
                        rgb_nxt = 12'hf_f_0;                
                //to move down add to 1st comparison and subtract in 2nd comparison  
                //to move left subtract from both comparisions 0,3*x_difference
                
                //upwards spike
                else if (hcount_in >= 400 && hcount_in <= 440 && vcount_in >= 567 && vcount_in <= 617 && ((3 * hcount_in) + vcount_in) >= 1830 && ((3 * hcount_in) - vcount_in) <= 690)   
                    rgb_nxt = 12'hf_0_0;
                    
                else if (hcount_in >= 400 && hcount_in <= 440 && vcount_in >= 317 && vcount_in <= 367 && ((3 * hcount_in) + vcount_in) >= 1580 && ((3 * hcount_in) - vcount_in) <= 940)   
                    rgb_nxt = 12'hf_0_0;
                else if (hcount_in >= 300 && hcount_in <= 340 && vcount_in >= 567 && vcount_in <= 617 && ((3 * hcount_in) + vcount_in) >= 1530 && ((3 * hcount_in) - vcount_in) <= 390)   
                    rgb_nxt = 12'hf_0_0;
                //to move spike downwards in <= subtract difference and in >= add
                //when moving spike sideways add (or subtract) to both <= and >= value of 3*x_difference 
                */

