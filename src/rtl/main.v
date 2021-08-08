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
            
wire reset_CLK;
wire pclk;
wire mclk;

CLK CLK(
    .clk(clk),
    .rst(rst),

    .reset_out(reset_CLK),
    .pixel_clock(pclk),
    .mouse_clock(mclk)
);

//MOUSE WIRES
wire [11:0] xpos_out_mouse, ypos_out_mouse;
wire mouse_left;

//UART WIRES
wire victory_out_UART, opponent_ready_out_UART,opponent_hit_out_UART, tx_out_UART;

//CORE WIRES
wire [15:0] led_CORE;
wire [11:0] rgb_out_CORE;
wire  mouse_mode_out_CORE;
wire [3:0] an_out_CORE;
wire [7:0] seg_out_CORE;
wire game_over_out_CORE, player_ready_out_CORE, play_selected_out_CORE, multiplayer_out_CORE;
wire hsync_out_CORE, vsync_out_CORE;
wire player_hit_out_CORE;

CORE #( .TOP_V_LINE(TOP_V_LINE),
        .BOTTOM_V_LINE(BOTTOM_V_LINE),
        .LEFT_H_LINE(LEFT_H_LINE),
        .RIGHT_H_LINE(RIGHT_H_LINE) ) CORE (
    //inputs
    .clk(pclk),
    .rst(reset_CLK),
    .game_button(game_button),
    .menu_button(menu_button),
    .victory_button(victory_button),
    .game_over_button(game_over),
    .xpos(xpos_out_mouse),
    .ypos(ypos_out_mouse),
    .mouse_left(mouse_left),
    .victory(victory_out_UART),
    .opponent_ready(opponent_ready_out_UART),
    .opponent_hit(opponent_hit_out_UART),

    //outputs
    .hsync(hsync_out_CORE),
    .vsync(vsync_out_CORE),
    .mouse_mode(mouse_mode_out_CORE),
    .game_over(game_over_out_CORE),
    .player_ready(player_ready_out_CORE),
    .play_selected(play_selected_out_CORE),
    .multiplayer(multiplayer_out_CORE),
    .player_hit(player_hit_out_CORE),
    .rgb_out(rgb_out_CORE),
    .an(an_out_CORE),
    .seg(seg_out_CORE)
);

MOUSE #( .TOP_V_LINE(TOP_V_LINE),
        .BOTTOM_V_LINE(BOTTOM_V_LINE),
        .LEFT_H_LINE(LEFT_H_LINE),
        .RIGHT_H_LINE(RIGHT_H_LINE) ) MOUSE ( 
    //inouts
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),

    //inputs
    .clk(mclk),
    .rst(reset_CLK),
    .mouse_mode(mouse_mode_out_CORE),

    //outputs
    .xpos(xpos_out_mouse),
    .ypos(ypos_out_mouse),
    .mouse_left(mouse_left)
);

UART UART (
    //inputs
    .clk(pclk),
    .rst(reset_CLK),
    .rx(rx),
    .game_over(game_over_out_CORE),
    .player_ready(player_ready_out_CORE),
    .play_selected(play_selected_out_CORE),
    .multiplayer(multiplayer_out_CORE),
    .player_hit(player_hit_out_CORE),
    
    //outputs
    .tx(tx_out_UART),
    .victory(victory_out_UART),
    .opponent_ready(opponent_ready_out_UART),
    .opponent_hit(opponent_hit_out_UART)
);

assign hs = hsync_out_CORE;
assign vs = vsync_out_CORE;
assign {r,g,b} = rgb_out_CORE;
assign an = an_out_CORE;
assign seg = seg_out_CORE;
assign tx = tx_out_UART;

endmodule
