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
wire opponent_hit_comp;
wire rx_done_tick;
wire game_over_ind, player_ready_ind, player_hit_ind;
wire [7:0] message;

transmition_logic transmition_logic(
    .clk(clk),
    .rst(rst),
    .game_over(game_over),
    .player_ready(player_ready),
    .multiplayer(multiplayer),
    .player_hit(player_hit),
    
    .game_over_ind(game_over_ind),
    .player_ready_ind(player_ready_ind),
    .player_hit_ind(player_hit_ind),
    .message(message)
);

uart_module my_uart(
    .clk(clk), 
    .reset(rst),
    .rd_uart(~game_over_ind), 
    .wr_uart(game_over_ind || player_ready_ind || player_hit_ind), 
    .rx(rx),
    .w_data(message),
    .tx_full(),
    .rx_empty(), 
    .tx(tx),
    .r_data(),
    .current_char(curr_char_out),
    .rx_done_tick_out(rx_done_tick)
);

comparator comparator(
    //inputs
    .clk(clk),
    .rst(rst),
    .curr_char(curr_char_out),
    .play_selected(play_selected),
    .multiplayer(multiplayer),
    .rx_done_tick(rx_done_tick),
    
    // outputs
    .victory(victory),
    .opponent_ready(opponent_ready),
    .opponent_hit(opponent_hit)
);

endmodule