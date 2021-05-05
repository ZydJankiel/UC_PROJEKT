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
    
    input wire menu_on,
    input wire game_on,
    input wire clk,
    input wire rst
    );

reg [11:0] value_nxt = 0;
reg [11:0] counter = 0, counter_nxt = 0;
reg setmax_x_nxt, setmax_y_nxt;
reg [2:0] state,state_nxt;

localparam IDLE = 2'b00,
           GAME_MODE = 2'b01,
           MENU_MODE = 2'b10;

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
    setmax_x_nxt = 0;
    setmax_y_nxt = 0;
    value_nxt = 0;
    counter_nxt = 0;
    state_nxt = IDLE;
    case(state)
        IDLE: begin
            if (game_on == 1) begin
                state_nxt = GAME_MODE;
                end
            else if (menu_on == 1) begin
                state_nxt = MENU_MODE;
                end
            else begin
                state_nxt = IDLE;
                end
              //state_nxt = menu_on ? MENU_MODE : IDLE; //CZEMU DODANIE TEJ LINIJKI PSUJE WSZYSTKIE PRZYCISKI??????/
              //FOR FUTURE USES NEVER USE LINE ABOVE TO CHECK STATES OF BUTTONS - FOR SOME REASON DISABLES ALL BUTTONS
        end
            
        GAME_MODE: begin
            if (counter == 0) begin
                setmax_x_nxt = 1;
                value_nxt = 800;
                counter_nxt = 1;
            end
            else begin
                setmax_y_nxt = 1;
                value_nxt = 600;
            end
              state_nxt = counter_nxt == 0 ? IDLE : GAME_MODE;
        end  
        
        MENU_MODE : begin
            if (counter == 0) begin
                setmax_x_nxt = 1;
                value_nxt = 1019;
                counter_nxt = 1;
            end
            else begin
                setmax_y_nxt = 1;
                value_nxt = 763;
            end
            state_nxt = counter_nxt == 0 ? IDLE : MENU_MODE;
        end
        
    endcase
end

endmodule
