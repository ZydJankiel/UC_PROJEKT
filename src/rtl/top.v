module top (
  input clk,
  input rst,
  input rx,
  input game_over,
  input player_ready,
  output tx,
  output [7:0] curr_char_out,
  output [3:0] an,
  output [7:0] led,
  output [7:0] seg
);

  reg tx_nxt;
  wire [7:0] r_data;
  wire rx_done;
  reg [7:0] message, message_nxt;
  reg game_over_reg, game_over_reg_nxt;
  reg player_ready_reg, player_ready_reg_nxt;
  reg [35:0] counter, counter_nxt;

  uart my_uart(
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
  
  disp_hex_mux my_disp(
    .clk(clk), 
    .reset(rst),
    .hex3(curr_char_out[7:4]), 
    .hex2(curr_char_out[3:0]), 
    .hex1(curr_char_out[7:4]), 
    .hex0(curr_char_out[3:0]), 
    .dp_in(4'b1111),
    .an(an), 
    .sseg(seg)
  );
 //nizej czesc 1 z polecenia
always @ (posedge clk) begin
    if (rst )begin
        message <= 8'h00;
        game_over_reg <= 0;
        player_ready_reg <= 0;
        counter <= 0;
    end
    else begin
        message <= message_nxt;
        game_over_reg <= game_over_reg_nxt;
        player_ready_reg <= player_ready_reg_nxt;
        counter <= counter_nxt;
    end
end
   
always @* begin
    message_nxt = 8'h00;
    game_over_reg_nxt = 0;
    player_ready_reg_nxt = 0;
    counter_nxt = counter;
    if (game_over) begin
        message_nxt = 8'h4C;
        game_over_reg_nxt = 1;
    end
    if (player_ready) begin  
        if (counter >= 65000000) begin
            message_nxt = 8'h52;
            player_ready_reg_nxt = 1;
            counter_nxt = 0;
        end
        else begin
            player_ready_reg_nxt = 0;
            counter_nxt = counter + 1;
        end
    end
end

assign led = r_data; 


endmodule