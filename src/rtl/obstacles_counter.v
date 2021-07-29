module obstacles_counter (
    input wire clk,
    input wire rst,
    input wire start,
    input wire done_in,

    output reg done_out
);

reg done_out_nxt;
reg [1:0] state, state_nxt;
reg [25:0] counter, counter_nxt;

localparam MAX_TIME = 65000000;

localparam IDLE  = 2'b00,
           COUNT = 2'b01,
           DONE  = 2'b10;

always @(posedge clk) begin
    if (rst) begin
        state    <= IDLE;
        done_out <= 0;
        counter  <= 0;
    end
    else begin
        state    <= state_nxt;
        done_out <= done_out_nxt;
        counter  <= counter_nxt;
    end
end

always @* begin
    done_out_nxt = 0;
    counter_nxt  = counter;
    state_nxt    = state;
    
    case(state)
        IDLE: begin
            if (start && done_in)
                state_nxt = COUNT;
            else
                state_nxt = IDLE;
            
            counter_nxt = 0;
        end
            
        COUNT: begin
            if (counter == MAX_TIME)
                state_nxt = DONE;
            else begin
                counter_nxt = counter + 1;
                state_nxt = COUNT;
            end
        end

        DONE: begin
            state_nxt = IDLE;
            done_out_nxt = 1;
        end
            
    endcase
end

endmodule