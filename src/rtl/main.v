`timescale 1 ns / 1 ps
//// test
module main (
  inout ps2_clk,
  inout ps2_data, 
  input wire clk,
  input wire rst,
  input wire game_button,
  input wire menu_button,
  
  output wire vs,
  output wire hs,
  output wire [3:0] r,
  output wire [3:0] g,
  output wire [3:0] b
  );

localparam  TOP_V_LINE     = 317,
            BOTTOM_V_LINE  = 617,
            LEFT_H_LINE    = 361,
            RIGHT_H_LINE   = 661;
            
  wire locked;
  wire pclk;
  wire clkMouse;

clk_wiz_0 my_clk_wiz_0 (
  .clk(clk),
  .reset(rst),
  .clk130MHz(clkMouse),
  .clk65MHz(pclk),
  .locked(locked)
);

  wire locked_reset;
  clk_locked_menager my_clk_locked_menager(
    .pclk(pclk),
    .locked_in(locked),
    .reset_out(locked_reset)
  );
  wire [11:0] rgb_out_back;
  wire [11:0] value_constr;
  wire [11:0] xpos_out_mouseCtl, ypos_out_mouseCtl, xpos_out_buff, ypos_out_buff;
  wire [11:0] vcount_out_timing, hcount_out_timing, vcount_out_back, hcount_out_back;
  wire [3:0] red_out_mouse, green_out_mouse, blue_out_mouse;
  
  wire vsync_out_timing, hsync_out_timing, vsync_out_back, hsync_out_back;
  wire vblnk_out_timing, hblnk_out_timing, vblnk_out_back, hblnk_out_back;

  wire mouse_left_out_mouseCtl, mouse_left_out_buff;
  wire setmax_x_constr, setmax_y_constr, setmin_x_constr, setmin_y_constr, mouse_mode_out_back;   


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
  
  draw_background #(.TOP_V_LINE(TOP_V_LINE), 
                    .BOTTOM_V_LINE(BOTTOM_V_LINE), 
                    .LEFT_H_LINE(LEFT_H_LINE), 
                    .RIGHT_H_LINE(RIGHT_H_LINE),
                    .BORDER(10)) my_game_background (
  //inputs
   .vcount_in(vcount_out_timing),
   .vsync_in(vsync_out_timing),
   .vblnk_in(vblnk_out_timing),
   .hcount_in(hcount_out_timing),
   .hsync_in(hsync_out_timing),
   .hblnk_in(hblnk_out_timing),
   .pclk(pclk),
   .rst(locked_reset),
   .game_on(game_button),
   .menu_on(menu_button),
   .xpos(xpos_out_mouseCtl),
   .ypos(ypos_out_mouseCtl),
   .mouse_left(mouse_left_out_mouseCtl),
  //outputs  
   .hcount_out(hcount_out_back),
   .vcount_out(vcount_out_back),
   .hblnk_out(hblnk_out_back),
   .vblnk_out(vblnk_out_back),
   .hsync_out(hsync_out_back),
   .vsync_out(vsync_out_back),
   .rgb_out(rgb_out_back),
   .mouse_mode(mouse_mode_out_back)
  );

  MouseCtl My_MouseCtl(
  //inouts
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
  //inputs
    .rst(locked_reset),
    .clk(clkMouse),
    .setx(0),
    .sety(0),
    .setmax_x(setmax_x_constr),
    .setmax_y(setmax_y_constr),
    .setmin_x(setmin_x_constr),
    .setmin_y(setmin_y_constr),
    .value(value_constr),
  //outputs
    .xpos(xpos_out_mouseCtl),
    .ypos(ypos_out_mouseCtl),
    .zpos(),
    .left(mouse_left_out_mouseCtl),
    .middle(),
    .right(),
    .new_event()
  );
  
  mouse_constrainer #(.MIN_Y(TOP_V_LINE), 
                      .MAX_Y(BOTTOM_V_LINE), 
                      .MIN_X(LEFT_H_LINE), 
                      .MAX_X(RIGHT_H_LINE)) my_mouse_constrainer (
    //inputs
    .clk(pclk),
    .rst(locked_reset),
    .mouse_mode(mouse_mode_out_back),
    //outputs
    .setmax_x(setmax_x_constr),
    .setmax_y(setmax_y_constr),
    .setmin_x(setmin_x_constr),
    .setmin_y(setmin_y_constr),
    .value(value_constr)
    );
 /*   mouse_buffor my_mouse_buffor(
        // inputs
      .pclk(pclk),
      .rst(locked_reset),
      .xpos_in(xpos_out_mouseCtl),
      .ypos_in(ypos_out_mouseCtl),
      .mouse_left_in(mouse_left_out_mouseCtl), 
    // outputs
      .mouse_left_out(mouse_left_out_buff),
      .xpos_out(xpos_out_buff),
      .ypos_out(ypos_out_buff)
    );
    */
    MouseDisplay My_MouseDisplay (
  //inputs
    .xpos(xpos_out_mouseCtl),
    .ypos(ypos_out_mouseCtl),
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
