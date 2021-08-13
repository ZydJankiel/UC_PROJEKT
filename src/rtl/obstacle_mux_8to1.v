`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2021 13:15:10
// Design Name: 
// Module Name: obstacle_mux_16-to1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
/*
* MO-created module of mux to select current obstacle to draw. Mux working in asynch mode 
* Based on 
* https://technobyte.org/verilog-multiplexer-4x1/
* From section : Verilog code for 4�1 multiplexer using behavioral modeling
*
* PWJ Adjusted bit lengths and changed input signals to {obstacle_x,obstacle_y,rgb}
* 
*/

// in and out size to be chosen correctly
module obstacle_mux_8_to_1(

    input wire [35:0] input_0,
    input wire [35:0] input_1,
    input wire [35:0] input_2,
    input wire [35:0] input_3,
    input wire [35:0] input_4,
    input wire [35:0] input_5,
    input wire [35:0] input_6,
    input wire [35:0] input_7,
    input wire [2:0] select,
        
    output reg [35:0] obstacle_mux_out
    );

always @(input_0 or input_1 or input_2 or input_3 or input_4 or input_5 or input_6 or input_7 or select) begin
        //case select of input
        case (select)
            3'b000: obstacle_mux_out <= input_0;
            3'b001: obstacle_mux_out <= input_1;
            3'b010: obstacle_mux_out <= input_2;
            3'b011: obstacle_mux_out <= input_3;
            3'b100: obstacle_mux_out <= input_4;
            3'b101: obstacle_mux_out <= input_5;
            3'b110: obstacle_mux_out <= input_6;
            3'b111: obstacle_mux_out <= input_7;

        endcase
end

endmodule