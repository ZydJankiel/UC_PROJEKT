
module mouse_buffor (
  input wire [11:0] xpos_in,
  input wire [11:0] ypos_in,
  input wire mouse_left_in,
  output reg [11:0] ypos_out,
  output reg [11:0] xpos_out,
  output reg mouse_left_out,
  input wire pclk,
  input wire rst
  );

always @(posedge pclk) begin
   if(rst) begin
     xpos_out <= 0;
     ypos_out <= 0;
     mouse_left_out <= 0;
   end
   else begin
     mouse_left_out <= mouse_left_in;
     xpos_out <= xpos_in;
     ypos_out <= ypos_in;
   end

end

endmodule