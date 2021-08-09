`timescale 1 ns / 1 ps
/*
 * PWJ: Added comparator for comparing messages from uart
 * this module is working only in multiplayer
*/

module comparator (
    input wire clk,
    input wire rst,
    input wire multiplayer,
    input wire rx_done_tick,
    input wire [7:0] curr_char,
    
    output reg victory,
    output reg opponent_ready,
    output reg opponent_hit
);
reg victory_nxt;
reg opponent_ready_nxt;
reg opponent_hit_nxt;
reg [1:0] state, state_nxt;

localparam IDLE           = 2'b00,
           VICTORY        = 2'b01,
           OPPONENT_READY = 2'b10,
           OPPONENT_HIT   = 2'b11;

always @(posedge clk) begin
    if (rst) begin
        state          <= IDLE;
        victory        <= 0;
        opponent_ready <= 0;
        opponent_hit   <= 0;
    end
    else begin
        state          <= state_nxt;
        victory        <= victory_nxt;
        opponent_ready <= opponent_ready_nxt;
        opponent_hit   <= opponent_hit_nxt;
    end
end

always @* begin
    victory_nxt        = 0;
    opponent_ready_nxt = 0;
    opponent_hit_nxt   = 0;
    state_nxt          = state;
    
    case(state)
        IDLE: begin
            if (multiplayer) begin
                if (rx_done_tick) begin
                    if (curr_char == 8'h4C)
                        state_nxt = VICTORY;
                    else if (curr_char == 8'h48)
                        state_nxt = OPPONENT_HIT;
                    else if (curr_char == 8'h52)
                        state_nxt = OPPONENT_READY;
                    else
                        state_nxt = IDLE;    
                end
                else
                    state_nxt = IDLE;
            end
            else
                state_nxt = IDLE;  
                                 
        end
            
        VICTORY: begin
            state_nxt = IDLE;
            victory_nxt = 1;
        end
            
        OPPONENT_READY: begin 
            opponent_ready_nxt = 1;
            state_nxt = IDLE;
        end
            
        OPPONENT_HIT: begin
            opponent_hit_nxt = 1;
            state_nxt = IDLE;
        end
        
        default: begin
            state_nxt = IDLE;
        end
    endcase
end

endmodule