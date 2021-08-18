`timescale 1 ns / 1 ps

// PWJ implemented module 

module obstacles_control (
    input wire clk,
    input wire rst,
    input wire done,
    input wire play_selected,

    output reg [2:0] obstacle_code,
    output reg done_out
);

reg [2:0] code_nxt;
reg done_out_nxt;
reg state, state_nxt;

localparam IDLE = 0,
           CONTROL = 1;

always @(posedge clk) begin
    if (rst) begin
        state         <= IDLE;
        obstacle_code <= 0;
        done_out      <= 0;
    end
    else begin
        state         <= state_nxt;
        obstacle_code <= code_nxt;
        done_out      <= done_out_nxt;
    end
end

always @* begin
    done_out_nxt = 0;
    code_nxt     = obstacle_code;
    state_nxt    = state;
    
    case(state)
        IDLE: begin
            if (play_selected) begin
                state_nxt = CONTROL;
                done_out_nxt = 1;
            end
            else begin
                state_nxt = IDLE;
                done_out_nxt = 0;
            end
                
        end
        
        CONTROL: begin
            if (done) begin
                if (obstacle_code == 3'b110) begin
                    code_nxt = 0;
                    done_out_nxt = 1;
                end
                else begin
                    code_nxt = obstacle_code + 1;
                    done_out_nxt = 1;
                end
            end
            else begin
                code_nxt = obstacle_code;
                done_out_nxt = 0;
            end
            
            if (!play_selected) begin
                code_nxt = 0;
                done_out_nxt = 0;
                state_nxt = IDLE;
            end
            else
                state_nxt = CONTROL;
        end
    endcase

end

endmodule
