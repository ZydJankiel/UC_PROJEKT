`timescale 1 ns / 1 ps

module main (
    inout ps2_clk,
    inout ps2_data, 
    
    input wire clk,
    input wire rst,
    input wire game_button,
    input wire menu_button,
    input wire victory_button,
    input wire game_over,
    input wire rx,
    
    output wire tx,
    output wire vs,
    output wire hs,
    output wire [3:0] an,
    output wire [7:0] seg,
    output wire [3:0] r,
    output wire [3:0] g,
    output wire [3:0] b
);

localparam  TOP_V_LINE      = 317,
            BOTTOM_V_LINE   = 617,
            LEFT_H_LINE     = 361,
            RIGHT_H_LINE    = 661;     
            
wire locked;
wire pclk;
wire clkMouse;

clk_wiz_0 clk_wiz_0 (
    //inputs
    .clk(clk),
    .reset(rst),
    
    //outputs
    .clk130MHz(clkMouse),
    .clk65MHz(pclk),
    .locked(locked)
);

wire locked_reset;
clk_locked_menager clk_locked_menager(
    //inputs
    .pclk(pclk),
    .locked_in(locked),
    
    //outputs
    .reset_out(locked_reset)
);
//MOUSE WIRES
wire [11:0] xpos_out_mouse, ypos_out_mouse;
wire mouse_left;

//UART WIRES
wire victory_out_UART, opponent_ready_out_UART, tx_out_UART;

//CORE WIRES
wire [15:0] led_CORE;
wire [11:0] rgb_out_CORE;
wire [2:0] mouse_mode_out_CORE;
wire [3:0] an_out_CORE;
wire [7:0] seg_out_CORE;
wire game_over_out_CORE, player_ready_out_CORE, play_selected_out_CORE, multiplayer_out_CORE;
wire hsync_out_CORE, vsync_out_CORE;

CORE #( .TOP_V_LINE(TOP_V_LINE),
        .BOTTOM_V_LINE(BOTTOM_V_LINE),
        .LEFT_H_LINE(LEFT_H_LINE),
        .RIGHT_H_LINE(RIGHT_H_LINE) ) CORE (
        
        .clk(pclk),
        .rst(locked_reset),
        .game_button(game_button),
        .menu_button(menu_button),
        .victory_button(victory_button),
        .game_over_button(game_over),
        .xpos(xpos_out_mouse),
        .ypos(ypos_out_mouse),
        .mouse_left(mouse_left),
        .victory(victory_out_UART),
        .opponent_ready(opponent_ready_out_UART),

        .hsync(hsync_out_CORE),
        .vsync(vsync_out_CORE),
        .mouse_mode(mouse_mode_out_CORE),
        .game_over(game_over_out_CORE),
        .player_ready(player_ready_out_CORE),
        .play_selected(play_selected_out_CORE),
        .multiplayer(multiplayer_out_CORE),
        .rgb_out(rgb_out_CORE),
        .an(an_out_CORE),
        .seg(seg_out_CORE)
    );

MOUSE #( .TOP_V_LINE(TOP_V_LINE),
        .BOTTOM_V_LINE(BOTTOM_V_LINE),
        .LEFT_H_LINE(LEFT_H_LINE),
        .RIGHT_H_LINE(RIGHT_H_LINE) ) MOUSE ( 
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),

    .clk(clkMouse),
    .rst(locked_reset),
    .mouse_mode(mouse_mode_out_CORE),

    .xpos(xpos_out_mouse),
    .ypos(ypos_out_mouse),
    .mouse_left(mouse_left)
);



//UART

UART UART (

    .clk(pclk),
    .rst(locked_reset),
    .rx(rx),
    .game_over(game_over_out_CORE),
    .player_ready(player_ready_out_CORE),
    .play_selected(play_selected_out_CORE),
    .multiplayer(multiplayer_out_CORE),
    
    .tx(tx_out_UART),
    .victory(victory_out_UART),
    .opponent_ready(opponent_ready_out_UART)
);


assign hs = hsync_out_CORE;
assign vs = vsync_out_CORE;
assign {r,g,b} = rgb_out_CORE;
assign an = an_out_CORE;
assign seg = seg_out_CORE;
assign tx = tx_out_UART;

endmodule
