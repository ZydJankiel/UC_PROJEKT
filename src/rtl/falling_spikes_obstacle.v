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


module falling_spikes_obstacle(
    input wire [11:0] vcount_in,
    input wire [11:0] hcount_in,
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

localparam COUNTER_WARNING          = 65000000,     //1 sec
           COUNTER_MOVE             = 600000,
           COUNTER_FAST_MOVE        = COUNTER_MOVE/2,
           OBSTACLE_TIME_COUNTER    = 650000000;   //10 seconds
           
localparam IDLE                 = 3'b000,
           SPIKE_FROM_TOP       = 3'b001,
           SPIKE_FROM_BOTTOM    = 3'b010,
           SPIKE_FROM_LEFT      = 3'b011,
           SPIKE_FROM_RIGHT     = 3'b100;
           
localparam SPIKE_WIDTH          = 20;

localparam GAME_FIELD_TOP       = 317,
           GAME_FIELD_BOTTOM    = 617,
           GAME_FIELD_LEFT      = 361,
           GAME_FIELD_RIGHT     = 661,
           WARNING_BORDER       = 10;
    
reg [25:0] counter_move_x, counter_move_x_nxt, counter_move_y, counter_move_y_nxt, counter_growth, counter_growth_nxt;
reg [11:0] rgb_nxt;
reg [11:0] obstacle_x_nxt, obstacle_y_nxt;
reg [1:0] state, state_nxt;
reg done_nxt;
reg [25:0] warning_counter, warning_counter_nxt;

reg warning, warning_nxt;
reg [11:0] spike_left_or_top_slope, spike_left_or_top_slope_nxt, spike_right_or_bot_slope, spike_right_or_bot_slope_nxt;
reg [6:0] enemy_border, enemy_border_nxt;
reg [11:0] spike_center_x, spike_center_x_nxt, spike_center_y, spike_center_y_nxt;


always @(posedge clk) begin
    if (rst) begin
        state                       <= IDLE;
        rgb_out                     <= 0; 
        obstacle_x                  <= 0;
        obstacle_y                  <= 0;
        counter_move_x              <= 0;
        counter_move_y              <= 0;
        spike_center_x              <= 0;
        spike_center_y              <= 0;
        counter_growth              <= 0;
        done                        <= 0;
        warning_counter             <= 0;
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
        spike_center_x              <= spike_center_x_nxt;
        spike_center_y              <= spike_center_y_nxt;
        counter_growth              <= counter_growth_nxt;
        done                        <= done_nxt;
        warning_counter             <= warning_counter_nxt;
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
    counter_growth_nxt              = counter_growth;
    obstacle_x_nxt                  = 0;
    obstacle_y_nxt                  = 0;
    done_nxt                        = 0;
    warning_counter_nxt             = warning_counter;
    warning_nxt                     = warning;
    spike_left_or_top_slope_nxt     = spike_left_or_top_slope;
    spike_right_or_bot_slope_nxt    = spike_right_or_bot_slope;
    spike_center_x_nxt              = spike_center_x;
    case (state)
        IDLE: begin
            if (done_in) begin
                state_nxt = ((selected == 4'b0101) && play_selected) ? SPIKE_FROM_TOP : IDLE;
                counter_move_x_nxt = 0;
                counter_move_y_nxt = 0;
                warning_counter_nxt = 0;
                spike_center_x_nxt = 511;
                spike_left_or_top_slope_nxt = 1170;
                spike_right_or_bot_slope_nxt = 1890;
                warning_nxt = 1;
            end
            else
                state_nxt = IDLE;

        end //end state
        
        SPIKE_FROM_TOP: begin
        
            if (menu_on || !play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = SPIKE_FROM_TOP; 
                
            if (warning) begin
                //in last 2 comps - more in <= and less in >= makes triangle bigger , multiplying hcount gives greater slope (if x>1) or smaller slope (if x<1)
                //to move spike downwards in <= add difference and in >= subtract
                //when moving spike sideways add (or subtract) to both <= and >= value of 3*x_difference 
                if (hcount_in >= spike_center_x - SPIKE_WIDTH && hcount_in <= spike_center_x + SPIKE_WIDTH && vcount_in >= GAME_FIELD_TOP && (vcount_in <= GAME_FIELD_TOP + 50) && ((3 * hcount_in) + vcount_in) <= spike_right_or_bot_slope_nxt && ((3 * hcount_in) - vcount_in) >= spike_left_or_top_slope_nxt)  begin 
                    rgb_nxt = 12'hf_f_f;
                    end
                else 
                    rgb_nxt = rgb_in;
                    
                if (warning_counter == COUNTER_WARNING) begin
                    warning_counter_nxt = 0;
                    //warning_nxt = 0;
                    end
                else 
                    warning_counter_nxt = warning_counter + 1;
                end 
            else
                rgb_nxt = rgb_in;

            //spike x axis following    
            if (spike_center_x < mouse_xpos + (SPIKE_WIDTH/2)) begin              
                if (counter_move_x >= COUNTER_FAST_MOVE) begin
                    spike_center_x_nxt = spike_center_x + 1;
                    spike_left_or_top_slope_nxt = spike_left_or_top_slope_nxt +3;
                    spike_right_or_bot_slope_nxt = spike_right_or_bot_slope_nxt +3;
                    counter_move_x_nxt = 0;
                end
                else
                    counter_move_x_nxt = counter_move_x + 1;
            end
            else if (spike_center_x > mouse_xpos) begin         
                if (counter_move_x >= COUNTER_FAST_MOVE) begin
                    spike_left_or_top_slope_nxt = spike_left_or_top_slope_nxt -3;
                    spike_right_or_bot_slope_nxt = spike_right_or_bot_slope_nxt -3;
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


                      
        end //end state
        
    endcase
end
        




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


endmodule
