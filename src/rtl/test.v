`timescale 1 ns / 1 ps

module test 
    (
        input wire clk,
        input wire rst,
        input wire opponent_hit,

        output reg [15:0] leds
    );

reg [15:0] leds_nxt;

always @(posedge clk) begin
    if (rst) begin
        leds <= 0;
    end
    else begin
        leds <= leds_nxt;
    end 
end
    
always @* begin 
    if (opponent_hit) begin
        leds_nxt = leds + 1;
    end
    else leds_nxt = leds;
end

endmodule