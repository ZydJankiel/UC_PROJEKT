
// PWJ: Added logic for transmiting data via UART

module transmition_logic (
    input wire clk,
    input wire rst,
    input wire game_over,
    input wire player_ready,
    input wire multiplayer,
    input wire player_hit,
    
    output reg game_over_ind,
    output reg player_ready_ind,
    output reg player_hit_ind,
    output reg [7:0] message
);

reg [7:0]  message_nxt;
reg game_over_ind_nxt;
reg player_ready_ind_nxt;
reg player_hit_ind_nxt;


  
always @ (posedge clk) begin
    if (rst )begin
        message          <= 8'h00;
        game_over_ind    <= 0;
        player_ready_ind <= 0;
        player_hit_ind   <= 0;
    end
    else begin
        message          <= message_nxt;
        game_over_ind    <= game_over_ind_nxt;
        player_ready_ind <= player_ready_ind_nxt;
        player_hit_ind   <= player_hit_ind_nxt;
    end
end
   
always @* begin
    message_nxt          = 8'h00;
    game_over_ind_nxt    = 0;
    player_ready_ind_nxt = 0;
    player_hit_ind_nxt   = 0;

    if (multiplayer) begin
        if (game_over) begin
            message_nxt = 8'h4C;
            game_over_ind_nxt = 1;
        end
        if (player_ready) begin  
            message_nxt = 8'h52;
            player_ready_ind_nxt = 1;
        end
        if (player_hit) begin
            message_nxt = 8'h48;
            player_hit_ind_nxt = 1;
        end
    end
    
end

endmodule