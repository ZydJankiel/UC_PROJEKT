`timescale 1 ns / 1 ps

module main (
  inout ps2_clk,
  inout ps2_data, 
  input wire clk,
  input wire rst,
  output wire vs,
  output wire hs,
  output wire [3:0] r,
  output wire [3:0] g,
  output wire [3:0] b
  );

  wire locked;
  wire pclk;
  wire clkMouse;

clk_wiz_0 my_clk_wiz_0 (
  .clk(clk),
  .reset(rst),
  .clk100MHz(clkMouse),
  .clk108MHz(pclk),
  .locked(locked)
);

  wire locked_reset;
  clk_locked_menager my_clk_locked_menager(
    .pclk(pclk),
    .locked_in(locked),
    .reset_out(locked_reset)
  );

  wire [11:0] vcount_out_timing, hcount_out_timing, vcount_out_back, hcount_out_back;
  wire vsync_out_timing, hsync_out_timing, vsync_out_back, hsync_out_back;
  wire vblnk_out_timing, hblnk_out_timing, vblnk_out_back, hblnk_out_back;
  wire [11:0] rgb_out_back;
  wire [11:0] xpos_out_mouseCtl, ypos_out_mouseCtl, xpos_out_buff, ypos_out_buff;
  wire mouse_left_out_mouseCtl, mouse_left_out_buff;
  wire [3:0] red_out_mouse, green_out_mouse, blue_out_mouse;


  vga_timing my_timing (
  //inputs 
    .pclk(pclk),
    .rst(locked_reset),
  //outputs
    .vcount(vcount_out_timing),
    .vsync(vsync_out_timing),
    .vblnk(vblnk_out_timing),
    .hcount(hcount_out_timing),
    .hsync(hsync_out_timing),
    .hblnk(hblnk_out_timing)
  );
  
  draw_background my_background (
  //inputs
   .vcount_in(vcount_out_timing),
   .vsync_in(vsync_out_timing),
   .vblnk_in(vblnk_out_timing),
   .hcount_in(hcount_out_timing),
   .hsync_in(hsync_out_timing),
   .hblnk_in(hblnk_out_timing),
   .pclk(pclk),
   .rst(locked_reset),
  //outputs  
   .hcount_out(hcount_out_back),
   .vcount_out(vcount_out_back),
   .hblnk_out(hblnk_out_back),
   .vblnk_out(vblnk_out_back),
   .hsync_out(hsync_out_back),
   .vsync_out(vsync_out_back),
   .rgb_out(rgb_out_back)
  );

  wire mouse_reset_buff;
  delay #(.WIDTH(1), .CLK_DEL(1)) my_mouse_reset_buffor(
    .clk(clkMouse),
    .rst(0),
    .din(locked_reset),
    .dout(mouse_reset_buff)
  );
  
  MouseCtl my_MouseCtl(
  //inouts
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
  //inputs
    .rst(mouse_reset_buff),
    .clk(clkMouse),
    .setx(0),
    .sety(0),
    .setmax_x(0),
    .setmax_y(0),
    .value(0),
  //outputs
    .xpos(xpos_out_mouseCtl),
    .ypos(ypos_out_mouseCtl),
    .zpos(),
    .left(mouse_left_out_mouseCtl),
    .middle(),
    .right(),
    .new_event()
  );
    delay #(.WIDTH(24), .CLK_DEL(2)) my_mouse_buffor(
        .clk(clkMouse),
        .rst(locked_reset),
        .din({xpos_out_mouseCtl,ypos_out_mouseCtl}),
        .dout({xpos_out_buff,ypos_out_buff})
      );
      wire [11:0] xpos_out_buff2,ypos_out_buff2;
    delay #(.WIDTH(24), .CLK_DEL(2)) my_mouse_buffor1(
      .clk(pclk),
      .rst(locked_reset),
      .din({xpos_out_buff,ypos_out_buff}),
      .dout({xpos_out_buff2,ypos_out_buff2})
    );
    
    MouseDisplay My_MouseDisplay (
  //inputs
    .xpos(xpos_out_buff2),
    .ypos(ypos_out_buff2),
    .pixel_clk(pclk),
    .hcount(hcount_out_back),
    .vcount(vcount_out_back),
    .blank(hblnk_out_back || vblnk_out_back), 
    .red_in(rgb_out_back[11:8]),
    .green_in(rgb_out_back[7:4]),
    .blue_in(rgb_out_back[3:0]),
  //outputs
    .red_out(red_out_mouse),
    .green_out(green_out_mouse),
    .blue_out(blue_out_mouse),
    .enable_mouse_display_out()
 );
  
assign hs = hsync_out_back;
assign vs = vsync_out_back;
assign {r,g,b} = {red_out_mouse, green_out_mouse, blue_out_mouse};

endmodule
