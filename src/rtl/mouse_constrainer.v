`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.05.2021 14:02:16
// Design Name: 
// Module Name: mouse_constrainer
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

// implemented by MO
module mouse_constrainer(
    output reg [11:0] value,
    output reg setmax_x,
    output reg setmax_y,
    
    input clk,
    input rst
    );

reg [11:0] value_nxt = 0;
reg [11:0] counter = 0, counter_nxt = 0;
reg setmax_x_nxt, setmax_y_nxt;
    
always @(posedge clk) begin
    if(rst) begin
        value <= 0;
        setmax_x <= 0;
        setmax_y <= 0;
        end
    else begin
        value <= value_nxt;
        setmax_x <= setmax_x_nxt;
        setmax_y <= setmax_y_nxt;
        counter <= counter_nxt;
        end

end
    
// this is very poorly scalable - if u want to add possibility to change constraints mid-game 
// then it should be done on state machine
always @* begin
    value_nxt = 0;
    setmax_x_nxt = 0;
    setmax_y_nxt = 0;
    counter_nxt = counter + 1;
    if (counter == 0) begin
        value_nxt = 762;            //762 is perfect to still see the crusor
        setmax_y_nxt = 1;
        end
    else if(counter == 10) begin
        value_nxt = 1018;           // 1018 is perfect to still see the crusor
        setmax_x_nxt = 1;
        end
    else if (counter == 1023 )begin
        counter_nxt = 0;
        end      
end

endmodule
