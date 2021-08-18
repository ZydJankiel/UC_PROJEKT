`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.07.2021 13:04:21
// Design Name: 
// Module Name: square_follow_obstacle
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


module square_follow_obstacle
    #( parameter
        SELECT_CODE = 3'b011
    )
    (
        input wire [11:0] vcount_in,
        input wire [11:0] hcount_in,
        input wire clk,
        input wire rst,
        input wire [11:0] rgb_in,
        input wire play_selected,
        input wire [2:0] selected,
        input wire done_in,
        
        output reg [11:0] rgb_out,
        output reg [11:0] obstacle_x,
        output reg [11:0] obstacle_y,
        output reg done
    );
      
localparam COUNTER_MOVE             = 3200000,
           COUNTER_BETWEEN_STATES   = 32000000,
           COUNTER_FAST_MOVE        = COUNTER_MOVE/2 ;  

localparam GAME_FIELD_TOP       = 317,
           GAME_FIELD_BOTTOM    = 617,
           GAME_FIELD_LEFT      = 361,
           GAME_FIELD_RIGHT     = 661;
          

localparam IDLE                 = 3'b000,
           CLOSE_IN             = 3'b001,
           MOVE_TO_RIGHT_TOP    = 3'b010,
           MOVE_TO_RIGHT_BOTTOM = 3'b011,
           MOVE_TO_LEFT_TOP     = 3'b100,
           CLOSE_IN_MORE        = 3'b101,
           MOVE_TO_LEFT_MIDDLE  = 3'b110,
           MOVE_TO_CENTER       = 3'b111;
           
reg [25:0] counter_between_lasers, counter_between_lasers_nxt, counter_on_laser, counter_on_laser_nxt;
reg [11:0] rgb_nxt;
reg [11:0] obstacle_x_nxt, obstacle_y_nxt;
reg [2:0] state, state_nxt;
reg done_nxt;


reg [10:0] square_hole_top, square_hole_bottom, square_hole_left, square_hole_right, square_hole_top_nxt, square_hole_bottom_nxt, square_hole_left_nxt, square_hole_right_nxt;

always @(posedge clk) begin
    if (rst) begin
        state                   <= IDLE;
        rgb_out                 <= 0; 
        obstacle_x              <= 0;
        obstacle_y              <= 0;
        square_hole_top         <= 0;
        square_hole_bottom      <= 0;
        square_hole_left        <= 0;
        square_hole_right       <= 0;
        counter_between_lasers  <= 0;
        counter_on_laser        <= 0;
        done                    <= 0;
    end
    else begin
        state                   <= state_nxt;
        rgb_out                 <= rgb_nxt;
        obstacle_x              <= obstacle_x_nxt;
        obstacle_y              <= obstacle_y_nxt;   
        square_hole_top         <= square_hole_top_nxt;
        square_hole_bottom      <= square_hole_bottom_nxt;
        square_hole_left        <= square_hole_left_nxt;
        square_hole_right       <= square_hole_right_nxt;
        counter_between_lasers  <= counter_between_lasers_nxt;
        counter_on_laser        <= counter_on_laser_nxt;
        done                    <= done_nxt;
    end
end

always @* begin
    rgb_nxt                     = rgb_in;
    state_nxt                   = IDLE;
    counter_between_lasers_nxt  = counter_between_lasers;
    counter_on_laser_nxt        = 0;
    square_hole_top_nxt         = square_hole_top;
    square_hole_bottom_nxt      = square_hole_bottom;
    square_hole_left_nxt        = square_hole_left;
    square_hole_right_nxt       = square_hole_right;
    obstacle_x_nxt              = 0;
    obstacle_y_nxt              = 0;
    done_nxt                    = 0;
    
    case (state)
        IDLE: begin

            if (done_in) begin
                state_nxt = ((selected == SELECT_CODE) && play_selected) ? CLOSE_IN : IDLE;
                square_hole_top_nxt = GAME_FIELD_TOP + 1;
                square_hole_bottom_nxt = GAME_FIELD_BOTTOM - 1;
                square_hole_left_nxt = GAME_FIELD_LEFT + 1;
                square_hole_right_nxt = GAME_FIELD_RIGHT - 1;
                counter_between_lasers_nxt = 0;
            end
            else
                state_nxt = IDLE;
        end
        
        CLOSE_IN: begin
            if (!play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = CLOSE_IN;
            
            if ((hcount_in <= GAME_FIELD_RIGHT && hcount_in >= GAME_FIELD_LEFT && vcount_in >= GAME_FIELD_TOP && vcount_in <= square_hole_top)  ||
                (hcount_in <= GAME_FIELD_RIGHT && hcount_in >= GAME_FIELD_LEFT && vcount_in >= square_hole_bottom && vcount_in <= GAME_FIELD_BOTTOM) ||
                (hcount_in <= GAME_FIELD_RIGHT && hcount_in >= square_hole_right && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) ||
                (hcount_in <= square_hole_left && hcount_in >= GAME_FIELD_LEFT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM)) begin
                //begin
                rgb_nxt = 12'hf_f_f;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
            end
            else
                rgb_nxt = rgb_in;
                                 
            if (square_hole_top >= GAME_FIELD_TOP + 125 ) begin         //move to next state after delay when size conditions are met 
                if (counter_between_lasers == COUNTER_BETWEEN_STATES)               
                    state_nxt = MOVE_TO_RIGHT_TOP;
                else
                    counter_between_lasers_nxt = counter_between_lasers + 1;   
            end
            else begin          //expand borders with delay between expansions to slow down   
                if (counter_on_laser >= COUNTER_MOVE) begin  
                    square_hole_top_nxt = square_hole_top + 1;          // "-" to go up, "+" to go down 
                    square_hole_bottom_nxt = square_hole_bottom - 1;    // "-" to go up, "+" to go down 
                    square_hole_left_nxt = square_hole_left + 1;        // "-" to go left, "+" to go right
                    square_hole_right_nxt = square_hole_right - 1;      // "-" to go left, "+" to go right
                    counter_on_laser_nxt = 0;
                end
                else begin
                    counter_on_laser_nxt = counter_on_laser + 1;
                    square_hole_top_nxt = square_hole_top;
                    square_hole_bottom_nxt = square_hole_bottom;
                    square_hole_left_nxt = square_hole_left;
                    square_hole_right_nxt = square_hole_right;
                end
            end
             
         end
         
         MOVE_TO_RIGHT_TOP: begin
         
            if (!play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = MOVE_TO_RIGHT_TOP;
            
            if ((hcount_in <= GAME_FIELD_RIGHT && hcount_in >= GAME_FIELD_LEFT && vcount_in >= GAME_FIELD_TOP && vcount_in <= square_hole_top)  ||
                (hcount_in <= GAME_FIELD_RIGHT && hcount_in >= GAME_FIELD_LEFT && vcount_in >= square_hole_bottom && vcount_in <= GAME_FIELD_BOTTOM) ||
                (hcount_in <= GAME_FIELD_RIGHT && hcount_in >= square_hole_right && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) ||
                (hcount_in <= square_hole_left && hcount_in >= GAME_FIELD_LEFT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM)) begin
                //begin
                rgb_nxt = 12'hf_f_f;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
            end
            else
                rgb_nxt = rgb_in;
                
                
            if (square_hole_right >= GAME_FIELD_RIGHT ) begin         //move to next state after delay when size conditions are met 
                if (counter_between_lasers == COUNTER_BETWEEN_STATES)               
                    state_nxt = MOVE_TO_RIGHT_BOTTOM;
                else
                    counter_between_lasers_nxt = counter_between_lasers + 1;
            end
            else begin          //expand borders with delay between expansions to slow down   
                if (counter_on_laser >= COUNTER_MOVE) begin  
                    square_hole_top_nxt = square_hole_top -1;            // "-" to go up, "+" to go down 
                    square_hole_bottom_nxt = square_hole_bottom - 1;     // "-" to go up, "+" to go down
                    square_hole_left_nxt = square_hole_left + 1;         // "-" to go left, "+" to go right
                    square_hole_right_nxt = square_hole_right + 1;       // "-" to go left, "+" to go right
                    counter_on_laser_nxt = 0;
                end
                else begin
                    counter_on_laser_nxt = counter_on_laser + 1;
                    square_hole_top_nxt = square_hole_top;
                    square_hole_bottom_nxt = square_hole_bottom;
                    square_hole_left_nxt = square_hole_left;
                    square_hole_right_nxt = square_hole_right;
                end
            end 
            
        end
        
        MOVE_TO_RIGHT_BOTTOM: begin
        
            if (!play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = MOVE_TO_RIGHT_BOTTOM;
            
            if ((hcount_in <= GAME_FIELD_RIGHT && hcount_in >= GAME_FIELD_LEFT && vcount_in >= GAME_FIELD_TOP && vcount_in <= square_hole_top)  ||
                (hcount_in <= GAME_FIELD_RIGHT && hcount_in >= GAME_FIELD_LEFT && vcount_in >= square_hole_bottom && vcount_in <= GAME_FIELD_BOTTOM) ||
                (hcount_in <= GAME_FIELD_RIGHT && hcount_in >= square_hole_right && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) ||
                (hcount_in <= square_hole_left && hcount_in >= GAME_FIELD_LEFT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM)) begin
                //begin
                rgb_nxt = 12'hf_f_f;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
            end
            else
                rgb_nxt = rgb_in;
                
                
            if (square_hole_bottom >= GAME_FIELD_BOTTOM ) begin         //move to next state after delay when size conditions are met 
                if (counter_between_lasers == COUNTER_BETWEEN_STATES)              
                    state_nxt = MOVE_TO_LEFT_TOP;
                else
                    counter_between_lasers_nxt = counter_between_lasers + 1;
            end
            else begin          //expand borders with delay between expansions to slow down   
                if (counter_on_laser >= COUNTER_MOVE) begin  
                    square_hole_top_nxt = square_hole_top + 1;            // "-" to go up, "+" to go down 
                    square_hole_bottom_nxt = square_hole_bottom + 1;     // "-" to go up, "+" to go down
                    square_hole_left_nxt = square_hole_left ;         // "-" to go left, "+" to go right
                    square_hole_right_nxt = square_hole_right ;       // "-" to go left, "+" to go right
                    counter_on_laser_nxt = 0;
                end
                else begin
                    counter_on_laser_nxt = counter_on_laser + 1;
                    square_hole_top_nxt = square_hole_top;
                    square_hole_bottom_nxt = square_hole_bottom;
                    square_hole_left_nxt = square_hole_left;
                    square_hole_right_nxt = square_hole_right;
                end
            end
            
        end
        
        MOVE_TO_LEFT_TOP: begin
        
            if (!play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = MOVE_TO_LEFT_TOP;
            
            if ((hcount_in <= GAME_FIELD_RIGHT && hcount_in >= GAME_FIELD_LEFT && vcount_in >= GAME_FIELD_TOP && vcount_in <= square_hole_top)  ||
                (hcount_in <= GAME_FIELD_RIGHT && hcount_in >= GAME_FIELD_LEFT && vcount_in >= square_hole_bottom && vcount_in <= GAME_FIELD_BOTTOM) ||
                (hcount_in <= GAME_FIELD_RIGHT && hcount_in >= square_hole_right && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) ||
                (hcount_in <= square_hole_left && hcount_in >= GAME_FIELD_LEFT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM)) begin
                //begin
                rgb_nxt = 12'hf_f_f;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
            end
            else
                rgb_nxt = rgb_in;
                
                
            if (square_hole_top <= GAME_FIELD_TOP ) begin         //move to next state after delay when size conditions are met 
                if (counter_between_lasers == COUNTER_BETWEEN_STATES)              
                    state_nxt = CLOSE_IN_MORE;
                else
                    counter_between_lasers_nxt = counter_between_lasers + 1;
            end
            else begin          //expand borders with delay between expansions to slow down   
                if (counter_on_laser >= COUNTER_FAST_MOVE) begin  
                    square_hole_top_nxt = square_hole_top - 1;            // "-" to go up, "+" to go down 
                    square_hole_bottom_nxt = square_hole_bottom - 1;     // "-" to go up, "+" to go down
                    square_hole_left_nxt = square_hole_left - 1;         // "-" to go left, "+" to go right
                    square_hole_right_nxt = square_hole_right - 1;       // "-" to go left, "+" to go right
                    counter_on_laser_nxt = 0;
                end
                else begin
                    counter_on_laser_nxt = counter_on_laser + 1;
                    square_hole_top_nxt = square_hole_top;
                    square_hole_bottom_nxt = square_hole_bottom;
                    square_hole_left_nxt = square_hole_left;
                    square_hole_right_nxt = square_hole_right;
                end
            end
            
        end
        
        CLOSE_IN_MORE: begin
        
            if (!play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = CLOSE_IN_MORE;
            
            if ((hcount_in <= GAME_FIELD_RIGHT && hcount_in >= GAME_FIELD_LEFT && vcount_in >= GAME_FIELD_TOP && vcount_in <= square_hole_top)  ||
                (hcount_in <= GAME_FIELD_RIGHT && hcount_in >= GAME_FIELD_LEFT && vcount_in >= square_hole_bottom && vcount_in <= GAME_FIELD_BOTTOM) ||
                (hcount_in <= GAME_FIELD_RIGHT && hcount_in >= square_hole_right && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) ||
                (hcount_in <= square_hole_left && hcount_in >= GAME_FIELD_LEFT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM)) begin
                //begin
                rgb_nxt = 12'hf_f_f;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
            end
            else
                rgb_nxt = rgb_in;
                                 
            if (square_hole_right <= GAME_FIELD_LEFT + 40 ) begin         //move to next state after delay when size conditions are met 
                if (counter_between_lasers == COUNTER_BETWEEN_STATES)               
                    state_nxt = MOVE_TO_LEFT_MIDDLE;
                else
                    counter_between_lasers_nxt = counter_between_lasers + 1;       
            end
            else begin          //expand borders with delay between expansions to slow down   
                if (counter_on_laser >= COUNTER_MOVE) begin  
                    square_hole_top_nxt = square_hole_top;          // "-" to go up, "+" to go down 
                    square_hole_bottom_nxt = square_hole_bottom - 1;    // "-" to go up, "+" to go down 
                    square_hole_left_nxt = square_hole_left;        // "-" to go left, "+" to go right
                    square_hole_right_nxt = square_hole_right - 1;      // "-" to go left, "+" to go right
                    counter_on_laser_nxt = 0;
                end
                else begin
                    counter_on_laser_nxt = counter_on_laser + 1;
                    square_hole_top_nxt = square_hole_top;
                    square_hole_bottom_nxt = square_hole_bottom;
                    square_hole_left_nxt = square_hole_left;
                    square_hole_right_nxt = square_hole_right;
                end
            end 
            
        end
        
        MOVE_TO_LEFT_MIDDLE: begin
        
            if (!play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = MOVE_TO_LEFT_MIDDLE;
            
            if ((hcount_in <= GAME_FIELD_RIGHT && hcount_in >= GAME_FIELD_LEFT && vcount_in >= GAME_FIELD_TOP && vcount_in <= square_hole_top)  ||
                (hcount_in <= GAME_FIELD_RIGHT && hcount_in >= GAME_FIELD_LEFT && vcount_in >= square_hole_bottom && vcount_in <= GAME_FIELD_BOTTOM) ||
                (hcount_in <= GAME_FIELD_RIGHT && hcount_in >= square_hole_right && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) ||
                (hcount_in <= square_hole_left && hcount_in >= GAME_FIELD_LEFT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM)) begin
                //begin
                rgb_nxt = 12'hf_f_f;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
            end
            else
                rgb_nxt = rgb_in;
                
                
            if (square_hole_top >= GAME_FIELD_TOP + 130 ) begin         //move to next state after delay when size conditions are met 
                if (counter_between_lasers == COUNTER_BETWEEN_STATES)               
                    state_nxt = MOVE_TO_CENTER;
                else
                    counter_between_lasers_nxt = counter_between_lasers + 1;
            end
            else begin          //expand borders with delay between expansions to slow down   
                if (counter_on_laser >= COUNTER_FAST_MOVE) begin  
                    square_hole_top_nxt = square_hole_top + 1;            // "-" to go up, "+" to go down 
                    square_hole_bottom_nxt = square_hole_bottom + 1;     // "-" to go up, "+" to go down
                    square_hole_left_nxt = square_hole_left ;         // "-" to go left, "+" to go right
                    square_hole_right_nxt = square_hole_right ;       // "-" to go left, "+" to go right
                    counter_on_laser_nxt = 0;
                end
                else begin
                    counter_on_laser_nxt = counter_on_laser + 1;
                    square_hole_top_nxt = square_hole_top;
                    square_hole_bottom_nxt = square_hole_bottom;
                    square_hole_left_nxt = square_hole_left;
                    square_hole_right_nxt = square_hole_right;
                end
            end
            
        end
        
        MOVE_TO_CENTER: begin  
        
            if (!play_selected)
                state_nxt = IDLE;
            else 
                state_nxt = MOVE_TO_CENTER;
            
            if ((hcount_in <= GAME_FIELD_RIGHT && hcount_in >= GAME_FIELD_LEFT && vcount_in >= GAME_FIELD_TOP && vcount_in <= square_hole_top)  ||
                (hcount_in <= GAME_FIELD_RIGHT && hcount_in >= GAME_FIELD_LEFT && vcount_in >= square_hole_bottom && vcount_in <= GAME_FIELD_BOTTOM) ||
                (hcount_in <= GAME_FIELD_RIGHT && hcount_in >= square_hole_right && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM) ||
                (hcount_in <= square_hole_left && hcount_in >= GAME_FIELD_LEFT && vcount_in >= GAME_FIELD_TOP && vcount_in <= GAME_FIELD_BOTTOM)) begin
                //begin
                rgb_nxt = 12'hf_f_f;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
            end
            else
                rgb_nxt = rgb_in;
                
                
            if (square_hole_left >= GAME_FIELD_LEFT + 130 ) begin         //move to next state after delay when size conditions are met 
                if (counter_between_lasers == COUNTER_BETWEEN_STATES) begin               
                    state_nxt = IDLE;
                    done_nxt = 1;
                end
                else
                    counter_between_lasers_nxt = counter_between_lasers + 1;
            end
            else begin          //expand borders with delay between expansions to slow down   
                if (counter_on_laser >= COUNTER_FAST_MOVE) begin  
                   square_hole_top_nxt = square_hole_top;            // "-" to go up, "+" to go down 
                   square_hole_bottom_nxt = square_hole_bottom ;     // "-" to go up, "+" to go down
                   square_hole_left_nxt = square_hole_left + 1;         // "-" to go left, "+" to go right
                   square_hole_right_nxt = square_hole_right + 1;       // "-" to go left, "+" to go right
                   counter_on_laser_nxt = 0;
                end
                else begin
                   counter_on_laser_nxt = counter_on_laser + 1;
                   square_hole_top_nxt = square_hole_top;
                   square_hole_bottom_nxt = square_hole_bottom;
                   square_hole_left_nxt = square_hole_left;
                   square_hole_right_nxt = square_hole_right;
                end
            end
            
        end 
    endcase
end  

endmodule
