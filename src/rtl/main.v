`timescale 1 ns / 1 ps

module main (
  inout ps2_clk,
  inout ps2_data, 
  input wire clk,
  input wire rst,
  input wire game_button,
  input wire menu_button,
  input wire player_hit_test,
  input wire game_over,
  input wire [3:0] sw,
  input wire rx,
  
  output wire tx,
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
  wire [35:0] mux_out;
  
  wire [27:0] delayed_signals;  
  
  wire [11:0] rgb_out_back, rgb_out_hp, rgb_out_obs0, rgb_out_obs1;
  wire [11:0] value_constr;
  wire [11:0] xpos_out_mouseCtl, ypos_out_mouseCtl, xpos_out_buff, ypos_out_buff;
  wire [11:0] vcount_out_timing, hcount_out_timing, vcount_out_back, hcount_out_back, vcount_out_hp, hcount_out_hp;
  wire [11:0] obstacle0_x_out,obstacle0_y_out, obstacle1_x_out,obstacle1_y_out;
  
  wire [7:0] curr_char_out;
  
  wire [3:0] red_out_mouse, green_out_mouse, blue_out_mouse;
  wire [3:0] obstacle_mux_select_bg;
  
  wire [1:0] mouse_mode_out_back; 
  
  wire play_selected_back;
  wire vsync_out_timing, hsync_out_timing, vsync_out_back, hsync_out_back, vsync_out_hp, hsync_out_hp;
  wire vblnk_out_timing, hblnk_out_timing, vblnk_out_back, hblnk_out_back, vblnk_out_hp, hblnk_out_hp;
  wire mouse_left_out_mouseCtl, mouse_left_out_buff;
  wire setmax_x_constr, setmax_y_constr, setmin_x_constr, setmin_y_constr;
  wire damage_out, game_over_hp;
  wire equal;

  
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
                  .BORDER(7)) my_game_background (
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
    .game_over(game_over || game_over_hp || equal),
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
    .mouse_mode(mouse_mode_out_back),
    .play_selected(play_selected_back)
    //.obstacle_mux_select(obstacle_mux_select_bg)
);
delay #(.WIDTH(28), .CLK_DEL(1))  control_signals_delay(
    .clk(pclk),
    .rst(locked_reset),
    .din({vcount_out_back, vsync_out_back, vblnk_out_back, hcount_out_back,  hsync_out_back, hblnk_out_back}),
    .dout(delayed_signals)
);

obstacle0 moving_pillars_obstacle(
//inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .pclk(pclk),
    .rst(locked_reset),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
  //outputs  
    .obstacle_x(obstacle0_x_out),
    .obstacle_y(obstacle0_y_out),
    .rgb_out(rgb_out_obs0)
    
);

obstacle1 #(.TEST_TOP_LINE(600), 
                 .TEST_BOTTOM_LINE(500), 
                 .TEST_LEFT_LINE(520), 
                 .TEST_RIGHT_LINE(620)) rectangle_obstacle(
//inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .pclk(pclk),
    .rst(locked_reset),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
  //outputs  
    .obstacle_x(obstacle1_x_out),
    .obstacle_y(obstacle1_y_out),
    .rgb_out(rgb_out_obs1)
    
);

wire pulse;
monostable my_monostable(
    .clk(pclk),
    .reset(rst),
    .trigger(player_hit_test),
    .pulse(pulse)
);

obstacle_mux_16_to_1 my_obstacle_mux_16_to_1(
    //inputs
    .input_0({obstacle0_x_out,obstacle0_y_out,rgb_out_obs0}),
    .input_1({obstacle1_x_out,obstacle1_y_out,rgb_out_obs1}),
    .input_2(0),
    .input_3(0),
    .input_4(0),
    .input_5(0),
    .input_6(0),
    .input_7(0),
    .input_8(0),
    .input_9(0),
    .input_10(0),
    .input_11(0),
    .input_12(0),
    .input_13(0),
    .input_14(0),
    .input_15(0),
    .select(sw),
    
    //outputs
    .obstacle_mux_out(mux_out)
);

colision_detector damage_checker(
    .pclk(pclk),
    .rst(rst),
    .obstacle_x_in(mux_out[35:24]),
    .obstacle_y_in(mux_out[23:12]),
    .mouse_x_in(xpos_out_mouseCtl),
    .mouse_y_in(ypos_out_mouseCtl),
    .damage_out(damage_out)
);

hp_control #(.TOP_V_LINE(TOP_V_LINE), 
                    .BOTTOM_V_LINE(BOTTOM_V_LINE), 
                    .LEFT_H_LINE(LEFT_H_LINE), 
                    .RIGHT_H_LINE(RIGHT_H_LINE),
                    .BORDER(3))
    player_hp_control 
    (
    //inputs
    .vcount_in_hp(delayed_signals[27:16]),
    .vsync_in_hp(delayed_signals[15]),
    .vblnk_in_hp(delayed_signals[14]),
    .hcount_in_hp(delayed_signals[13:2]),
    .hsync_in_hp(delayed_signals[1]),
    .hblnk_in_hp(delayed_signals[0]),
    .rgb_in_hp(mux_out[11:0]),
    .pclk(pclk),
    .rst(locked_reset),
    .game_on_hp(play_selected_back),
    .player_hit(pulse || damage_out),
 
    //outputs
    .vcount_out_hp(vcount_out_hp),
    .vsync_out_hp(vsync_out_hp),
    .vblnk_out_hp(vblnk_out_hp),
    .hcount_out_hp(hcount_out_hp),
    .hsync_out_hp(hsync_out_hp),
    .hblnk_out_hp(hblnk_out_hp),
    .rgb_out_hp(rgb_out_hp),
    .game_over(game_over_hp)
);
wire [11:0] hcount_out_char, vcount_out_char, rgb_out_char;
wire [7:0] draw_rect_char_xy, font_rom_pixels;
wire [6:0] char_code_out;
wire [3:0] draw_rect_char_line;
wire hsync_out_char, vsync_out_char, hblnk_out_char, vblnk_out_char;

draw_rect_char my_draw_rect_char(
  //outputs
  .hcount_out(hcount_out_char),
  .vcount_out(vcount_out_char),
  .hsync_out(hsync_out_char),
  .vsync_out(vsync_out_char),
  .hblnk_out(hblnk_out_char),
  .vblnk_out(vblnk_out_char),
  .rgb_out(rgb_out_char),
  .char_xy(draw_rect_char_xy),
  .char_line(draw_rect_char_line),
  
  //inputs
  .rst(locked_reset),
  .clk(pclk),
  .hcount_in(hcount_out_hp),
  .vcount_in(vcount_out_hp),
  .hsync_in(hsync_out_hp),
  .vsync_in(vsync_out_hp),
  .hblnk_in(hblnk_out_hp),
  .vblnk_in(vblnk_out_hp),
  .rgb_in(rgb_out_hp),
  .char_pixels(font_rom_pixels),
  .mouse_xpos(xpos_out_mouseCtl),
  .mouse_ypos(ypos_out_mouseCtl),
  .game_on(play_selected_back)
  );

char_rom_16x16 my_char_rom(
    //inputs
    .char_xy(draw_rect_char_xy),
    //outputs
    .char_code(char_code_out)
);

font_rom my_font_rom(
    //inputs
    .clk(pclk),
    .addr({char_code_out,draw_rect_char_line}),
    //outputs
    .char_line_pixels(font_rom_pixels)
);

//MOUSE MODULES//  

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
    .hcount(hcount_out_char),
    .vcount(vcount_out_char),
    .blank(hblnk_out_char || vblnk_out_char), 
    .red_in(rgb_out_char[11:8]),
    .green_in(rgb_out_char[7:4]),
    .blue_in(rgb_out_char[3:0]),
  //outputs
      .red_out(red_out_mouse),
      .green_out(green_out_mouse),
      .blue_out(blue_out_mouse),
      .enable_mouse_display_out()
  );
  
assign hs = hsync_out_char;
assign vs = vsync_out_char;
assign {r,g,b} = {red_out_mouse, green_out_mouse, blue_out_mouse};

//UART

top uart_top(
    //inputs
    .clk(pclk),
    .rst(locked_reset),
    .rx(rx),
    .game_over(game_over_hp),

    //outputs
    .tx(tx),
    .curr_char_out(curr_char_out)
);


comparator comparator(
    .clk(pclk),
    .rst(locked_reset),
    .curr_char(curr_char_out),
    .equal(equal)
);

endmodule
