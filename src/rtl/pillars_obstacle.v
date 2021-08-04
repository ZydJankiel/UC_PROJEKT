`timescale 1 ns / 1 ps

// PWJ: Added module for drawing obstacle. This module sends x and y coordinates to
// module responsible for checking colision with mouse pointer.
// Added moving pillars.

module pillars_obstacle 
    #( parameter
        SELECT_CODE = 4'b0000
    )
    (
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
        
        output reg [11:0] rgb_out,
        output reg [11:0] obstacle_x,
        output reg [11:0] obstacle_y,
        output reg done
    );
  
reg [11:0] rgb_nxt;
reg [11:0] obstacle_x_nxt, obstacle_y_nxt;
reg [2:0] state, state_nxt;
reg [32:0] count,count_nxt;
reg [9:0] pillar_left ,pillar_right ,pillar_left_nxt, pillar_right_nxt;
reg [9:0] pillar_top, pillar_top_nxt;
reg [9:0] pillar_bottom, pillar_bottom_nxt;
reg done_nxt;
reg [3:0] cycles_counter, cycles_counter_nxt;


localparam PILLAR_RIGHT_T    = 417,
           PILLAR_RIGHT_B = 617,
           PILLAR_LEFT_T    = 317,
           PILLAR_LEFT_B = 517,
           PILLAR_TOP_L = 361,
           PILLAR_TOP_R = 561,
           PILLAR_BOTTOM_L = 461,
           PILLAR_BOTTOM_R = 661;
           
localparam DX = 1;
localparam MAX_COUNT = 600;
localparam CYCLES_MAX_NUMBER = 3;

localparam IDLE        = 3'b000,
           DRAW_TOP    = 3'b001,
           DRAW_BOTTOM = 3'b010,
           DRAW_LEFT   = 3'b011,
           DRAW_RIGHT  = 3'b100;

always @(posedge clk) begin
    if (rst) begin
        state           <= IDLE;
        rgb_out         <= 0; 
        obstacle_x      <= 0;
        obstacle_y      <= 0;
        count           <= 0;
        pillar_left     <= 651;
        pillar_right    <= 671;
        pillar_top      <= PILLAR_RIGHT_T;
        pillar_bottom   <= PILLAR_RIGHT_B;
        done            <= 0;
        cycles_counter  <= 0;
    end
    else begin
        state           <= state_nxt;
        rgb_out         <= rgb_nxt;
        obstacle_x      <= obstacle_x_nxt;
        obstacle_y      <= obstacle_y_nxt;
        count           <= count_nxt;
        pillar_left     <= pillar_left_nxt;
        pillar_right    <= pillar_right_nxt;
        pillar_bottom   <= pillar_bottom_nxt;
        pillar_top      <= pillar_top_nxt;
        done            <= done_nxt;
        cycles_counter  <= cycles_counter_nxt;
    end
end

always @* begin 
    count_nxt           = count;
    obstacle_x_nxt      = 0;
    obstacle_y_nxt      = 0;
    pillar_right_nxt    = pillar_right;
    pillar_left_nxt     = pillar_left;
    rgb_nxt             = rgb_in; 
    state_nxt           = state;
    pillar_top_nxt      = pillar_top;
    pillar_bottom_nxt   = pillar_bottom;
    done_nxt            = 0;
    cycles_counter_nxt  = cycles_counter;
    
    case(state)
        IDLE: begin
            //state_nxt = (game_on || play_selected) ? DRAW : IDLE;
            if (done_in)
                state_nxt = ((selected == SELECT_CODE) && play_selected) ? DRAW_RIGHT : IDLE;
            else
                state_nxt = IDLE;
            
            count_nxt = 0;
            cycles_counter_nxt = 0;
            pillar_left_nxt     <= 651;
            pillar_right_nxt    <= 671;
            pillar_top_nxt      <= PILLAR_RIGHT_T;
            pillar_bottom_nxt   <= PILLAR_RIGHT_B;
               
        end
        
        DRAW_BOTTOM: begin
            if (count <= MAX_COUNT) begin
                if (hcount_in <= pillar_right && hcount_in >= pillar_left && vcount_in >= pillar_top && vcount_in <= pillar_bottom) begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    pillar_top_nxt = pillar_top;
                    pillar_bottom_nxt = pillar_bottom;   
                end
                else 
                    rgb_nxt = rgb_in;
                count_nxt = count + 1;
            end
            else begin
                count_nxt = 0;
                if (pillar_top <= 307) begin
                    pillar_left_nxt = 651;
                    pillar_right_nxt = 671;
                    pillar_top_nxt = PILLAR_RIGHT_T;
                    pillar_bottom_nxt = PILLAR_RIGHT_B;
                    cycles_counter_nxt = cycles_counter + 1;
                    state_nxt = DRAW_RIGHT;
                end
                else begin
                    pillar_top_nxt = pillar_top;
                    pillar_bottom_nxt = pillar_bottom;
                    cycles_counter_nxt = cycles_counter;
                end
                
                if (hcount_in <= pillar_right && hcount_in >= pillar_left && vcount_in >= pillar_top && vcount_in <= pillar_bottom) begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    pillar_top_nxt = pillar_top - DX;
                    pillar_bottom_nxt = pillar_bottom - DX;   
                end
                else 
                    rgb_nxt = rgb_in;
            end             
            
        end
        
        DRAW_TOP: begin
            if (count <= MAX_COUNT) begin
                if (hcount_in <= pillar_right && hcount_in >= pillar_left && vcount_in >= pillar_top && vcount_in <= pillar_bottom) begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    pillar_top_nxt = pillar_top;
                    pillar_bottom_nxt = pillar_bottom;   
                end
                else 
                    rgb_nxt = rgb_in;
                count_nxt = count + 1;
            end
            else begin
                count_nxt = 0;
                if (pillar_bottom >= 627) begin
                    pillar_left_nxt = 351;
                    pillar_right_nxt = 371;
                    pillar_top_nxt = PILLAR_LEFT_T;
                    pillar_bottom_nxt = PILLAR_LEFT_B;
                    state_nxt = DRAW_LEFT;
                end
                else begin
                    pillar_top_nxt = pillar_top;
                    pillar_bottom_nxt = pillar_bottom;
                    cycles_counter_nxt = cycles_counter;
                end
                
                if (hcount_in <= pillar_right && hcount_in >= pillar_left && vcount_in >= pillar_top && vcount_in <= pillar_bottom) begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    pillar_top_nxt = pillar_top + DX;
                    pillar_bottom_nxt = pillar_bottom + DX;   
                end
                else 
                    rgb_nxt = rgb_in;
            end             
        end
        
        DRAW_LEFT: begin
            if (count <= MAX_COUNT) begin
                if (hcount_in <= pillar_right && hcount_in >= pillar_left && vcount_in >= pillar_top && vcount_in <= pillar_bottom) begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    pillar_right_nxt = pillar_right;
                    pillar_left_nxt = pillar_left;   
                end
                else 
                    rgb_nxt = rgb_in;
                count_nxt = count + 1;
            end
            else begin
                count_nxt = 0;
                if (pillar_right >= 671) begin
                    pillar_left_nxt = PILLAR_BOTTOM_L;          
                    pillar_right_nxt = PILLAR_BOTTOM_R;
                    pillar_top_nxt = 651;
                    pillar_bottom_nxt = 671;
                    state_nxt = DRAW_BOTTOM;
                end
                else begin
                    pillar_right_nxt = pillar_right;
                    pillar_left_nxt = pillar_left;
                    cycles_counter_nxt = cycles_counter;
                end
                
                if (hcount_in <= pillar_right && hcount_in >= pillar_left && vcount_in >= pillar_top && vcount_in <= pillar_bottom) begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    pillar_left_nxt = pillar_left + DX;
                    pillar_right_nxt = pillar_right + DX;   
                end
                else 
                    rgb_nxt = rgb_in;
            end 
        end    
        
        DRAW_RIGHT: begin
            if (cycles_counter >= CYCLES_MAX_NUMBER) begin
                done_nxt = 1;
                state_nxt = IDLE;
            end
            else begin
                state_nxt = (menu_on || !play_selected) ? IDLE : DRAW_RIGHT;
                done_nxt = 0;
            end

            if (count <= MAX_COUNT) begin
                if (hcount_in <= pillar_right && hcount_in >= pillar_left && vcount_in >= pillar_top && vcount_in <= pillar_bottom) begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    pillar_right_nxt = pillar_right;
                    pillar_left_nxt = pillar_left;   
                end
                else 
                    rgb_nxt = rgb_in;
                count_nxt = count + 1;
            end
            else begin
                count_nxt = 0;
                if (pillar_left <= 351) begin
                    pillar_left_nxt = PILLAR_TOP_L;    
                    pillar_right_nxt = PILLAR_TOP_R;
                    pillar_top_nxt = 307;
                    pillar_bottom_nxt = 317;
                    state_nxt = DRAW_TOP;
                end
                else begin
                    pillar_right_nxt = pillar_right;
                    pillar_left_nxt = pillar_left;
                end
                
                if (hcount_in <= pillar_right && hcount_in >= pillar_left && vcount_in >= pillar_top && vcount_in <= pillar_bottom) begin 
                    rgb_nxt = 12'hf_f_f;
                    obstacle_x_nxt = hcount_in;
                    obstacle_y_nxt = vcount_in;
                    pillar_left_nxt = pillar_left - DX;
                    pillar_right_nxt = pillar_right - DX;
                end
                else 
                    rgb_nxt = rgb_in;
            end 
        end
    endcase 
end

endmodule
