module top (
  input clk,
  input rst,
  input rx,
  input game_over,
  output tx
  //output rx_monitor,
  //output tx_monitor, 
  //output [3:0] an,
  //output [7:0] led,
  //output [7:0] seg
);
  reg tx_nxt;
  wire [7:0] r_data, r_data_2nd_char;
  wire [7:0] curr_char_out;
  wire [7:0] prev_char_out;
  wire rx_done;
  reg counter;

  uart my_uart(
    .clk(clk), 
    .reset(rst),
    .rd_uart(1'b1), 
    .wr_uart(), 
    .rx(rx),
    .w_data(8'h4C),
    .tx_full(),
    .rx_empty(), 
    .tx(tx),
    .r_data(r_data),
    //.r_data_2nd_char(r_data_2nd_char),
    .current_char(),
    .rx_done(),
    .full()

  );
  /*
  disp_hex_mux my_disp(
    .clk(clk), 
    .reset(rst),  
    .hex3(r_data[7:4]), 
    .hex2(r_data[3:0]), 
    .hex1(r_data_2nd_char[7:4]), 
    .hex0(r_data_2nd_char[3:0]),
    .dp_in(4'b1111),
    .an(an), 
    .sseg(seg)
  );
  
   assign led = r_data; 
  */ 
  /*
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

*/

endmodule