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
MO-created module of mux to select current obstacle to draw. Mux working in asynch mode 
Based on 
https://technobyte.org/verilog-multiplexer-4x1/
From section : Verilog code for 4×1 multiplexer using behavioral modeling
*/

// in and out size to be chosen correctly
module obstacle_mux_16_to_1(

    input wire [40:0] input_0,
    input wire [40:0] input_1,
    input wire [40:0] input_2,
    input wire [40:0] input_3,
    input wire [40:0] input_4,
    input wire [40:0] input_5,
    input wire [40:0] input_6,
    input wire [40:0] input_7,
    input wire [40:0] input_8,
    input wire [40:0] input_9,
    input wire [40:0] input_10,
    input wire [40:0] input_11,
    input wire [40:0] input_12,
    input wire [40:0] input_13,
    input wire [40:0] input_14,
    input wire [40:0] input_15,
    input wire [3:0] select,
        
    output reg [40:0] obstacle_mux_out
    );

always @(input_1 or input_2 or input_3 or input_4 or input_5 or input_6 or input_7 or input_8 or input_9
        or input_10 or input_11 or input_12 or input_13 or input_14 or input_15 or select) begin
        //case select of input
        case (select)
            4'b0000: obstacle_mux_out <= input_0;
            4'b0001: obstacle_mux_out <= input_1;
            4'b0010: obstacle_mux_out <= input_2;
            4'b0011: obstacle_mux_out <= input_3;
            4'b0100: obstacle_mux_out <= input_4;
            4'b0101: obstacle_mux_out <= input_5;
            4'b0110: obstacle_mux_out <= input_6;
            4'b0111: obstacle_mux_out <= input_7;
            
            4'b1000: obstacle_mux_out <= input_8;
            4'b1001: obstacle_mux_out <= input_9;
            4'b1010: obstacle_mux_out <= input_10;
            4'b1011: obstacle_mux_out <= input_11;
            4'b1100: obstacle_mux_out <= input_12;
            4'b1101: obstacle_mux_out <= input_13;
            4'b1110: obstacle_mux_out <= input_14;
            4'b1111: obstacle_mux_out <= input_15;
            
        endcase
end

endmodule