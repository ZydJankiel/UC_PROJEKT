`timescale 1 ns / 1 ps
/*
 * PWJ: Added module for UART logic
*/

module UART (
    input wire clk,
    input wire rst,
    input wire rx,
    input wire game_over,
    input wire player_ready,
    input wire play_selected,
    input wire multiplayer,
    input wire player_hit,
    
    output wire tx,
    output wire victory,
    output wire opponent_ready,
    output wire opponent_hit
);

wire [7:0] curr_char_out;

uart_logic uart_logic(
    //inputs
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .game_over(game_over),
    .player_ready(player_ready),
    .multiplayer(multiplayer),
    .player_hit(player_hit),

    //outputs
    .tx(tx),
    .curr_char_out(curr_char_out)
);

comparator comparator(
    //inputs
    .clk(clk),
    .rst(rst),
    .curr_char(curr_char_out),
    .play_selected(play_selected),
    .multiplayer(multiplayer),
    
    // outputs
    .victory(victory),
    .opponent_ready(opponent_ready),
    .opponent_hit(opponent_hit)
);

endmodule