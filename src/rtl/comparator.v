module comparator (
  input clk,
  input rst,
  input wire [7:0] curr_char,
  output reg equal
);
    reg equal_nxt;

    always @(posedge clk) begin
        if (rst)
            equal <= 0;
        else
            equal <= equal_nxt;
    end

    always @* begin
        if (curr_char == 8'h4C)
            equal_nxt = 1;
        else
            equal_nxt = 0;
    end
endmodule