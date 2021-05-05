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
    output reg setmin_x,
    output reg setmin_y,
    
    input wire game_on,
    input wire clk,
    input wire rst
    );

reg [11:0] value_nxt = 0;
reg [11:0] counter = 0, counter_nxt = 0;
reg setmax_x_nxt, setmax_y_nxt, setmin_x_nxt, setmin_y_nxt;
reg [2:0] state,state_nxt;

localparam IDLE = 3'b000,
           SETMAX_X = 3'b001,
           SETMAX_Y = 3'b010,
           SETMIN_X = 3'b011,
           SETMIN_Y = 3'b100;

always @(posedge clk) begin
    if(rst) begin
        state <= IDLE;
        value <= 0;
        setmax_x <= 0;
        setmax_y <= 0;
        setmin_x <= 0;
        setmin_y <= 0;
        end
    else begin
        state <= state_nxt;
        value <= value_nxt;
        setmax_x <= setmax_x_nxt;
        setmax_y <= setmax_y_nxt;
        setmin_x <= setmin_x_nxt;
        setmin_y <= setmin_y_nxt;
        counter <= counter_nxt;
        end
end
    
always @* begin
    setmax_x_nxt = 0;
    setmax_y_nxt = 0;
    setmin_x_nxt = 0;
    setmin_y_nxt = 0;
    counter_nxt = 0;
    case(state)
        IDLE:
            begin
                value_nxt = 0;
                state_nxt = game_on ? SETMAX_X : IDLE;
            end
        SETMAX_X:
            begin
                setmax_x_nxt = 1;
                value_nxt = 800; 
                state_nxt = SETMAX_Y;
            end
        SETMAX_Y:
            begin
                setmax_y_nxt = 1;
                value_nxt = 600; 
                state_nxt = SETMIN_X;                
            end
        SETMIN_X:
            begin
                setmin_x_nxt = 1;
                value_nxt = 400; 
                state_nxt = SETMIN_Y;                 
            end
        SETMIN_Y:
            begin
                setmin_y_nxt = 1;
                value_nxt = 200; 
                state_nxt = IDLE;                      
            end
        /*    
          GAME_MODE:
              begin
                  if (counter == 0) begin
                      setmax_x_nxt = 1;
                      value_nxt = 800;
                      counter_nxt = 1;
                  end
                  else if (counter == 1) begin
                      setmax_y_nxt = 1;
                      value_nxt = 600;
                      counter_nxt = 2;
                  end
                  else if (counter == 2) begin
                      setmin_x_nxt = 1;
                      value_nxt = 400;
                      counter_nxt = 3;
                  end
                  else begin
                      setmin_y_nxt = 1;
                      value_nxt = 200;
                      counter_nxt = 0;
                  end
                  state_nxt = counter_nxt == 0 ? IDLE : GAME_MODE; 
              end */
    endcase
end

endmodule
