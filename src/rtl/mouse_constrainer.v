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
module mouse_constrainer
    #(  MIN_Y     = 367,
        MAX_Y  = 667,
        MIN_X    = 361,
        MAX_X   = 661
     )
    (
    input wire clk,
    input wire rst,
    input wire [2:0] mouse_mode,
    
    output reg [11:0] value,
    output reg setmax_x,
    output reg setmax_y,
    output reg setmin_x,
    output reg setmin_y,
    output reg set_x,
    output reg set_y
    );

reg [11:0] value_nxt = 0;
reg [11:0] counter = 0, counter_nxt = 0;
reg setmax_x_nxt, setmax_y_nxt, setmin_x_nxt, setmin_y_nxt, set_x_nxt, set_y_nxt;
reg [2:0] state,state_nxt;

localparam BOX_CENTER_X = 511,
           BOX_CENTER_Y = 517;

localparam IDLE = 2'b00,
           GAME_MODE = 2'b01,
           MENU_MODE = 2'b10;

always @(posedge clk) begin
    if(rst) begin
        state <= IDLE;
        value <= 0;
        setmax_x <= 0;
        setmax_y <= 0;
        setmin_x <= 0;
        setmin_y <= 0;
        set_x <= 0;
        set_y <= 0;
        counter <= 0;
        end
    else begin
        state <= state_nxt;
        value <= value_nxt;
        setmax_x <= setmax_x_nxt;
        setmax_y <= setmax_y_nxt;
        setmin_x <= setmin_x_nxt;
        setmin_y <= setmin_y_nxt;
        set_x <= set_x_nxt;
        set_y <= set_y_nxt;
        counter <= counter_nxt;
        end
end
    
always @* begin
    setmax_x_nxt = 0;
    setmax_y_nxt = 0;
    setmin_x_nxt = 0;
    setmin_y_nxt = 0;
    set_x_nxt = 0;
    set_y_nxt = 0;
    value_nxt = 0;
    counter_nxt = 0;
    state_nxt = IDLE;
    case(state)
        IDLE: begin
            if (mouse_mode == 3'b001) begin
                state_nxt = GAME_MODE;
                end
            else if (mouse_mode == 3'b000) begin
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
                value_nxt = MAX_X - 16;
                counter_nxt = counter +1;
            end
            else if (counter == 1)begin
                setmax_y_nxt = 1;
                value_nxt = MAX_Y - 16;
                counter_nxt = counter +1;
            end
            else if (counter == 2)begin
                setmin_x_nxt = 1;
                value_nxt = MIN_X;
                counter_nxt = counter +1;
            end
            else begin
                setmin_y_nxt = 1;
                value_nxt = MIN_Y;
                counter_nxt = 0;
            end
            //  I WILL USE IT LATER
            /*else if (counter == 3) begin
                setmin_y_nxt = 1;
                value_nxt = MIN_Y;
                counter_nxt = counter +1;
            end
            else if (counter == 4) begin
                set_x_nxt = 1;
                value_nxt = BOX_CENTER_X;
                counter_nxt = counter +1;
            end
            else begin
                set_y_nxt = 1;
                value_nxt = BOX_CENTER_Y;
                counter_nxt = 0;
            end */                              
              state_nxt = counter_nxt == 0 ? IDLE : GAME_MODE;
        end  
        
        MENU_MODE : begin
            if (counter == 0) begin
                setmax_x_nxt = 1;
                value_nxt = 1019;
                counter_nxt = counter + 1;
            end
            else if (counter == 1) begin
                setmax_y_nxt = 1;
                value_nxt = 763;
                counter_nxt = counter +1;
            end
            else if (counter == 2)begin
                setmin_x_nxt = 1;
                value_nxt = 0;
                counter_nxt = counter +1;
            end
            else begin
                setmin_y_nxt = 1;
                value_nxt = 0;
                counter_nxt = 0;
            end
            state_nxt = counter_nxt == 0 ? IDLE : MENU_MODE;
        end
        
    endcase
end

endmodule
