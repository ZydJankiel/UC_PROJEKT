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
    
    input wire game_on,
    input wire clk,
    input wire rst
    );

reg [11:0] value_nxt = 0;
reg [11:0] counter = 0, counter_nxt = 0;
reg setmax_x_nxt, setmax_y_nxt;
reg [2:0] state,state_nxt;

localparam IDLE = 1'b0,
           GAME_MODE = 1'b1;

always @(posedge clk) begin
    if(rst) begin
        state <= IDLE;
        value <= 0;
        setmax_x <= 0;
        setmax_y <= 0;
        end
    else begin
        state <= state_nxt;
        value <= value_nxt;
        setmax_x <= setmax_x_nxt;
        setmax_y <= setmax_y_nxt;
        counter <= counter_nxt;
        end
end
    
always @* begin
    case(state)
        IDLE:
            begin
              setmax_x_nxt = 0;
              setmax_y_nxt = 0;
              value_nxt = 0;
              counter_nxt = 0;
              state_nxt = game_on ? GAME_MODE : IDLE;
            end
            
          GAME_MODE:
            begin
              if (counter == 0) begin
                setmax_y_nxt = 0;
                setmax_x_nxt = 1;
                value_nxt = 800;
                counter_nxt = 1;
              end
              else begin
                setmax_y_nxt = 1;
                setmax_x_nxt = 0;
                value_nxt = 600;
                counter_nxt = 0;
            end
            state_nxt = counter_nxt == 0 ? IDLE : GAME_MODE;
        end  
    endcase
end

endmodule
