`timescale 1 ns / 1 ps

// PWJ: Used locke signal from clk_wiz_0 to generate correct reset

module clk_locked_menager (
    input wire locked_in,
    input wire pclk,
    output reg reset_out
  );
  
  always@(negedge pclk or negedge locked_in) begin
    if(locked_in==0) 
        reset_out <= 1;
    else
        reset_out <= 0;
  end
  
endmodule
