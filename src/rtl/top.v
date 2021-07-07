module top (
  input clk,
  input rst,
  input rx,
  input game_over,
  output tx,
  output [7:0] curr_char_out,
  output [3:0] an,
  output [7:0] led,
  output [7:0] seg
);
  reg tx_nxt;
  wire [7:0] r_data;
  wire rx_done;
  reg counter;

  uart my_uart(
    .clk(clk), 
    .reset(rst),
    .rd_uart(), 
    .wr_uart(), 
    .rx(rx),
    .w_data(),
    .tx_full(),
    .rx_empty(), 
    .tx(),
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
         tx_nxt = 0;
         counter = 0;
         end
     else begin
         if (game_over)begin
               counter=1; 
               tx_nxt = rx;
               end
         else if (counter == 1)
              tx_nxt = rx;
         else 
             tx_nxt = 0;
      end
 end
   
  assign tx = tx_nxt;
  assign led = r_data; 


endmodule