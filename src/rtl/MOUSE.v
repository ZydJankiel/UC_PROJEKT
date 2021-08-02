`timescale 1 ns / 1 ps
/*
 * PWJ: Added module for MOUSE logic
*/

module MOUSE 
    #( parameter
        TOP_V_LINE       = 317,
        BOTTOM_V_LINE    = 617,
        LEFT_H_LINE      = 361,
        RIGHT_H_LINE     = 661   
    )
    (
        inout wire ps2_clk,
        inout wire ps2_data,

        input wire clk,
        input wire rst,
        input wire mouse_mode,

        output wire [11:0] xpos,
        output wire [11:0] ypos,
        output wire mouse_left
    );

wire [11:0] xpos_ctl, ypos_ctl;
wire [11:0] value_constr;
wire mouse_left_ctl;
wire set_x_constr, set_y_constr, setmax_x_constr, setmax_y_constr, setmin_x_constr, setmin_y_constr;

MouseCtl My_MouseCtl (
    //inouts
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    
    //inputs
    .rst(rst),
    .clk(clk),
    .setx(set_x_constr),
    .sety(set_y_constr),
    .setmax_x(setmax_x_constr),
    .setmax_y(setmax_y_constr),
    .setmin_x(setmin_x_constr),
    .setmin_y(setmin_y_constr),
    .value(value_constr),
    //outputs
    .xpos(xpos_ctl),
    .ypos(ypos_ctl),
    .zpos(),
    .left(mouse_left_ctl),
    .middle(),
    .right(),
    .new_event()
);

mouse_constrainer #( .MIN_Y(TOP_V_LINE), 
                     .MAX_Y(BOTTOM_V_LINE), 
                     .MIN_X(LEFT_H_LINE), 
                     .MAX_X(RIGHT_H_LINE)) mouse_constrainer (
    //inputs
    .clk(clk),
    .rst(rst),
    .mouse_mode(mouse_mode),
    
    //outputs
    .setmax_x(setmax_x_constr),
    .setmax_y(setmax_y_constr),
    .setmin_x(setmin_x_constr),
    .setmin_y(setmin_y_constr),
    .set_x(set_x_constr),
    .set_y(set_y_constr),
    .value(value_constr)
);

assign xpos       = xpos_ctl;
assign ypos       = ypos_ctl;
assign mouse_left = mouse_left_ctl;

endmodule