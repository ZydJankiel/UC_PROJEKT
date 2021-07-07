module comparator (
  input clk,
  input rst,
  input wire [7:0] curr_char,
  output reg victory,
  output reg opponent_ready
);
    reg victory_nxt;
    reg opponent_ready_nxt;
    reg [1:0] state, state_nxt;
    
    localparam IDLE = 2'b00,
               VICTORY = 2'b01,
               OPPONENT_READY = 2'b10;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            victory <= 0;
            opponent_ready <= 0;
        end
        else begin
            state <= state_nxt;
            victory <= victory_nxt;
            opponent_ready <= 0;
        end
    end

    always @* begin
        victory_nxt = 0;
        opponent_ready_nxt = 0;
        state_nxt = state;
        case(state)
            IDLE:
                begin
                    if (curr_char == 8'h4C)
                        state_nxt = VICTORY;
                    else if (curr_char == 8'h57)
                        state_nxt = OPPONENT_READY;
                    else
                        state_nxt = IDLE;                
                end
            VICTORY:
                begin
                    state_nxt = IDLE;
                    victory_nxt = 1;
                end
            OPPONENT_READY:
                begin
                    state_nxt = (curr_char == 8'h4C) ? VICTORY : OPPONENT_READY;
                    opponent_ready_nxt = 1;
                end
        endcase
    end
endmodule