`timescale 1 ns / 1 ps
/*
 * PWJ: Added module for drawing obstacle. This module sends x and y coordinates to
 * module responsible for checking colision with mouse pointer.
 */
module obstacle1
    #( parameter
        TEST_TOP_LINE      = 0,
        TEST_BOTTOM_LINE   = 0,
        TEST_LEFT_LINE     = 0,
        TEST_RIGHT_LINE    = 0,
        COLOR              = 12'hf_f_f,
        SELECT_CODE        = 4'b0000
    )
    (
        input wire [11:0] vcount_in,
        input wire [11:0] hcount_in,
        input wire pclk,
        input wire rst,
        input wire game_on,
        input wire menu_on,
        input wire [11:0] rgb_in,
        input wire play_selected,
        input wire [3:0] selected,
        input wire done_in,
        
        output reg working,
        output reg [11:0] rgb_out,
        output reg [11:0] obstacle_x,
        output reg [11:0] obstacle_y,
        output reg done
    );
  
reg [11:0] rgb_nxt;
reg [11:0] obstacle_x_nxt, obstacle_y_nxt;
reg state, state_nxt;
reg [29:0] elapsed_time, elapsed_time_nxt, done_nxt;
reg working_nxt;

localparam IDLE = 2'b00,
           DRAW = 2'b01;
           
localparam MAX_TIME = 3; //seconds
localparam MAX_ELAPSED_TIME = 65000000 * MAX_TIME;

always @(posedge pclk) begin
    if (rst) begin
        state        <= IDLE;
        rgb_out      <= 0; 
        obstacle_x   <= 0;
        obstacle_y   <= 0;
        done         <= 0;
        elapsed_time <= 0;
        working      <= 0;
    end
    else begin
        state        <= state_nxt;
        rgb_out      <= rgb_nxt;
        obstacle_x   <= obstacle_x_nxt;
        obstacle_y   <= obstacle_y_nxt;
        done         <= done_nxt;
        elapsed_time <= elapsed_time_nxt;
        working      <= working_nxt;
    end 
end 
  
always @* begin 
    obstacle_x_nxt   = 0;
    obstacle_y_nxt   = 0;
    done_nxt         = 0;
    elapsed_time_nxt = 0;
    working_nxt      = 0;
    
    case(state)
        IDLE: begin
        
            if (done_in)
                state_nxt = ((selected == SELECT_CODE) && play_selected) ? DRAW : IDLE;
            else
                state_nxt = IDLE;
            
            rgb_nxt = rgb_in; 
            
        end
        
        DRAW: begin
            
            working_nxt = 1;
            
            if (hcount_in <TEST_RIGHT_LINE && hcount_in >TEST_LEFT_LINE && vcount_in < TEST_TOP_LINE && vcount_in >TEST_BOTTOM_LINE) begin 
                rgb_nxt = COLOR;
                obstacle_x_nxt = hcount_in;
                obstacle_y_nxt = vcount_in;
            end
            else 
                rgb_nxt = rgb_in;
            
            if (elapsed_time >= MAX_ELAPSED_TIME) begin
                done_nxt = 1;
                elapsed_time_nxt = 0;
                state_nxt = IDLE;
            end
            else begin
                state_nxt = (menu_on || !play_selected) ? IDLE : DRAW;
                done_nxt = 0;
                elapsed_time_nxt = elapsed_time + 1;
            end
            
        end
    endcase
end 

endmodule
