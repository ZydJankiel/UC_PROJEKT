module obstacles_counter (
    input wire clk,
    input wire rst,
    input wire start,
    input wire done_in,

    output reg done_out,
    output reg [15:0] obstacles_counted
);

reg done_out_nxt;
reg [15:0] obstacles_counted_nxt;
reg [3:0] thousands, hundreds, tens, ones, thousands_nxt, hundreds_nxt, tens_nxt, ones_nxt;
reg [1:0] state, state_nxt;
reg [25:0] counter, counter_nxt;

localparam MAX_TIME = 65000000;

localparam IDLE  = 2'b00,
           COUNT = 2'b01,
           DONE  = 2'b10,
           MENU  = 2'b11;

always @(posedge clk) begin
    if (rst) begin
        state             <= IDLE;
        done_out          <= 0;
        counter           <= 0;
        obstacles_counted <= 0;
        thousands         <= 0;
        hundreds          <= 0;
        tens              <= 0;
        ones              <= 0;
    end
    else begin
        state             <= state_nxt;
        done_out          <= done_out_nxt;
        counter           <= counter_nxt;
        obstacles_counted <= obstacles_counted_nxt;
        thousands         <= thousands_nxt;
        hundreds          <= hundreds_nxt;
        tens              <= tens_nxt;
        ones              <= ones_nxt;
    end
end

always @* begin
    done_out_nxt = 0;
    counter_nxt  = counter;
    state_nxt    = state;
    thousands_nxt = thousands;
    hundreds_nxt = hundreds;
    tens_nxt = tens;
    ones_nxt = ones;
    
    case(state)
        IDLE: begin
            if (!start)
                state_nxt = MENU;
            else if (start && done_in)
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
            ones_nxt = ones + 1;
            
            if (ones_nxt >= 10) begin
                ones_nxt = 0;
                tens_nxt = tens + 1;
            end
            
            if (tens_nxt >= 10) begin
                tens_nxt = 0;
                hundreds_nxt = hundreds + 1;
            end
            
            if (hundreds_nxt >= 10) begin
                hundreds_nxt = 0;
                thousands_nxt = thousands + 1;
            end
        end
        
        MENU: begin
            if (start) begin
                obstacles_counted_nxt = 0;
                thousands_nxt = 0;
                hundreds_nxt = 0;
                tens_nxt = 0;
                ones_nxt = 0;
                state_nxt = COUNT;
            end
            else begin
                obstacles_counted_nxt = obstacles_counted;
                thousands_nxt = thousands;
                hundreds_nxt = hundreds;
                tens_nxt = tens;
                ones_nxt = ones;
                state_nxt = MENU;
            end
        end
            
    endcase
    
    obstacles_counted_nxt = {thousands,hundreds,tens,ones};
end

endmodule