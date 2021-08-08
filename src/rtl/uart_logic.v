/*
 * PWJ: Added UART logic
 * UART is sending "L" letter to playet 2 when player 1 has lost the game. Then player's 2 UART receive "L" letter
 * and his comparator module interprets it as victory for him.
 * When one player is waiting for game, his UART sends "R" letter continously to other player, and is waiting for message
 * from him. The game starts only when two players receive "R" letters.
 * UART send letters only in multiplayer mode
*/

module uart_logic (
    input wire clk,
    input wire rst,
    input wire rx,
    input wire game_over,
    input wire player_ready,
    input wire multiplayer,
    
    output wire tx,
    output wire [7:0] curr_char_out
);

reg tx_nxt;
wire [7:0] r_data;
wire rx_done;
reg [7:0] message, message_nxt;
reg game_over_reg, game_over_reg_nxt;
reg player_ready_reg, player_ready_reg_nxt;

uart_module my_uart(
    .clk(clk), 
    .reset(rst),
    .rd_uart(~game_over_reg), 
    .wr_uart(game_over_reg || player_ready_reg), 
    .rx(rx),
    .w_data(message),
    .tx_full(),
    .rx_empty(), 
    .tx(tx),
    .r_data(r_data),
    .current_char(curr_char_out)
);
  
always @ (posedge clk) begin
    if (rst )begin
        message <= 8'h00;
        game_over_reg <= 0;
        player_ready_reg <= 0;
    end
    else begin
        message <= message_nxt;
        game_over_reg <= game_over_reg_nxt;
        player_ready_reg <= player_ready_reg_nxt;
    end
end
   
always @* begin
    message_nxt = 8'h00;
    game_over_reg_nxt = 0;
    player_ready_reg_nxt = 0;

    if (multiplayer) begin
        if (game_over) begin
            message_nxt = 8'h4C;
            game_over_reg_nxt = 1;
        end
        if (player_ready) begin  
            message_nxt = 8'h52;
            player_ready_reg_nxt = 1;
        end
    end
    
end

endmodule