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
    
    output wire tx,
    output wire victory,
    output wire opponent_ready
);

wire [7:0] curr_char_out;

top uart_top(
    //inputs
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .game_over(game_over),
    .player_ready(player_ready),
    .multiplayer(multiplayer),

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
    .opponent_ready(opponent_ready)
);

endmodule