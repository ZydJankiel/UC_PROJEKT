module obstacles_control #(parameter NUM_BITS = 3)
    (
        input wire clk,
        input wire rst,
        input wire done,
        input wire play_selected,

        output reg [NUM_BITS-1:0] obstacle_code,
        output reg done_out
    );

    reg [NUM_BITS-1:0] code_nxt;
    reg done_out_nxt;

    always @(posedge clk) begin
        if (rst) begin
            obstacle_code <= 0;
            done_out <= 0;
        end
        else begin
            obstacle_code <= code_nxt;
            done_out <= done_out_nxt;
        end
    end

    always @* begin
        if (done) begin
            //if (obstacle_code == {NUM_BITS{1'b1}}) begin
            if (obstacle_code == 4'b0111) begin
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
        end
    end

endmodule
