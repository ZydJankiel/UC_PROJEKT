`timescale 1 ns / 1 ps

module main (
  inout ps2_clk,
  inout ps2_data, 
  input wire clk,
  input wire rst,
  input wire game_button,
  input wire menu_button,
  input wire victory_button,
  input wire game_over,
  input wire [3:0] sw,
  input wire rx,
  
  output wire tx,
  output wire vs,
  output wire hs,
  output wire [3:0] an,
  output wire [7:0] seg,
  output wire [3:0] r,
  output wire [3:0] g,
  output wire [3:0] b,
  output wire [15:0] led
  );

localparam  TOP_V_LINE      = 317,
            BOTTOM_V_LINE   = 617,
            LEFT_H_LINE     = 361,
            RIGHT_H_LINE    = 661,
            
            PLAY_BOX_X_POS  = 432,
            PLAY_BOX_Y_POS  = 400,
            PLAY_BOX_Y_SIZE = 80,
            PLAY_BOX_X_SIZE = 128,
            
            MULTI_BOX_X_POS = 432,
            MULTI_BOX_Y_POS  = 640,
            MULTI_BOX_Y_SIZE = 80,
            MULTI_BOX_X_SIZE = 128,
            
            MENU_BOX_X_POS = 432,
            MENU_BOX_Y_POS  = 520,
            MENU_BOX_Y_SIZE = 80,
            MENU_BOX_X_SIZE = 128;            
            
  wire locked;
  wire pclk;
  wire clkMouse;

  clk_wiz_0 clk_wiz_0 (
      .clk(clk),
      .reset(rst),
      .clk130MHz(clkMouse),
      .clk65MHz(pclk),
      .locked(locked)
  );

  wire locked_reset;
  clk_locked_menager clk_locked_menager(
      .pclk(pclk),
      .locked_in(locked),
      .reset_out(locked_reset)
  );
  wire [35:0] mux_out;
  
  wire [27:0] delayed_signals;  
  
  wire [11:0] rgb_out_back, rgb_out_hp, rgb_out_obs0, rgb_out_obs1, rgb_out_obs2, rgb_out_obs3, rgb_out_obs4, rgb_out_obs5, rgb_out_obs6, rgb_out_obs7;
  wire [11:0] value_constr;
  wire [11:0] xpos_out_mouseCtl, ypos_out_mouseCtl, xpos_out_buff, ypos_out_buff;
  wire [11:0] vcount_out_timing, hcount_out_timing, vcount_out_back, hcount_out_back, vcount_out_hp, hcount_out_hp;
  wire [11:0] obstacle0_x_out,obstacle0_y_out, obstacle1_x_out, obstacle1_y_out, obstacle2_x_out, obstacle2_y_out, obstacle3_x_out, obstacle3_y_out;
  wire [11:0] obstacle4_x_out,obstacle4_y_out, obstacle5_x_out, obstacle5_y_out, obstacle6_x_out, obstacle6_y_out, obstacle7_x_out, obstacle7_y_out;
  
  wire [7:0] curr_char_out;
  
  wire [3:0] red_out_mouse, green_out_mouse, blue_out_mouse;
  wire [3:0] obstacle_mux_select_bg;
  wire [3:0] selected_obstacle, mux_code;
  
  wire [2:0] mouse_mode_out_back; 
  
  wire play_selected_back, display_buttons_m_and_s, display_menu_button;
  wire vsync_out_timing, hsync_out_timing, vsync_out_back, hsync_out_back, vsync_out_hp, hsync_out_hp;
  wire vblnk_out_timing, hblnk_out_timing, vblnk_out_back, hblnk_out_back, vblnk_out_hp, hblnk_out_hp;
  wire mouse_left_out_mouseCtl, mouse_left_out_buff;
  wire setmax_x_constr, setmax_y_constr, setmin_x_constr, setmin_y_constr, set_x_constr, set_y_constr;
  wire damage_out, game_over_hp;
  wire victory, opponent_ready, player_ready, multiplayer_out_back;
  
  wire LFSR_Done, done_obs0, done_obs1, done_obs2, done_obs3, done_obs4, done_obs5, done_obs6, done_obs7, done_control;
  wire work7, work6, work5, work4, work3, work2, work1, work0;
  
  vga_timing vga_timing (
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
                  .BORDER(7),
                  
                  .PLAY_BOX_X_POS(PLAY_BOX_X_POS),
                  .PLAY_BOX_Y_POS(PLAY_BOX_Y_POS),
                  .PLAY_BOX_Y_SIZE(PLAY_BOX_Y_SIZE),
                  .PLAY_BOX_X_SIZE(PLAY_BOX_X_SIZE),
                  
                  .MULTI_BOX_X_POS(MULTI_BOX_X_POS),
                  .MULTI_BOX_Y_POS(MULTI_BOX_Y_POS),
                  .MULTI_BOX_Y_SIZE(MULTI_BOX_Y_SIZE),
                  .MULTI_BOX_X_SIZE(MULTI_BOX_X_SIZE)
                  ) 
                  
    draw_game_background (
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
    .game_over(game_over || game_over_hp ),
    .xpos(xpos_out_mouseCtl),
    .ypos(ypos_out_mouseCtl),
    .mouse_left(mouse_left_out_mouseCtl),
    .victory(victory),
    .opponent_ready(opponent_ready),
 //outputs  
    .hcount_out(hcount_out_back),
    .vcount_out(vcount_out_back),
    .hblnk_out(hblnk_out_back),
    .vblnk_out(vblnk_out_back),
    .hsync_out(hsync_out_back),
    .vsync_out(vsync_out_back),
    .rgb_out(rgb_out_back),
    .mouse_mode(mouse_mode_out_back),
    .play_selected(play_selected_back),
    .display_buttons_m_and_s(display_buttons_m_and_s),
    .player_ready(player_ready),
    .display_menu_button(display_menu_button),
    .multiplayer(multiplayer_out_back)
);

delay #(.WIDTH(28), .CLK_DEL(1))  control_signals_delay(
    .clk(pclk),
    .rst(locked_reset),
    .din({vcount_out_back, vsync_out_back, vblnk_out_back, hcount_out_back,  hsync_out_back, hblnk_out_back}),
    .dout(delayed_signals)
);

obstacle0 #(.SELECT_CODE(4'b0000)) moving_pillars_obstacle(
//inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .pclk(pclk),
    .rst(locked_reset),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_control(done_control),
  //outputs  
    .working(work0),
    .obstacle_x(obstacle0_x_out),
    .obstacle_y(obstacle0_y_out),
    .rgb_out(rgb_out_obs0),
    .done(done_obs0)
    
);

lasers_obstacle vertical_lasers_obstacle(
//inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .pclk(pclk),
    .rst(locked_reset),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_control(done_control),
  //outputs  
    .working(work1),
    .obstacle_x(obstacle1_x_out),
    .obstacle_y(obstacle1_y_out),
    .rgb_out(rgb_out_obs1),
    .done(done_obs1) 
);

obstacle1 #(.TEST_TOP_LINE(500),
                 .TEST_BOTTOM_LINE(400),
                 .TEST_LEFT_LINE(520), 
                 .TEST_RIGHT_LINE(620),
                 .COLOR(12'hf_0_0),
                 .SELECT_CODE(4'b0010)) rectangle2_obstacle(
//inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .pclk(pclk),
    .rst(locked_reset),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_control(done_control),
  //outputs  
    .working(work2),
    .obstacle_x(obstacle2_x_out),
    .obstacle_y(obstacle2_y_out),
    .rgb_out(rgb_out_obs2),
    .done(done_obs2)
);

obstacle1 #(.TEST_TOP_LINE(500),
                 .TEST_BOTTOM_LINE(400),
                 .TEST_LEFT_LINE(400), 
                 .TEST_RIGHT_LINE(500),
                 .COLOR(12'h0_0_f),
                 .SELECT_CODE(4'b0011)) rectangle3_obstacle(
//inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .pclk(pclk),
    .rst(locked_reset),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_control(done_control),
  //outputs  
    .working(work3),
    .obstacle_x(obstacle3_x_out),
    .obstacle_y(obstacle3_y_out),
    .rgb_out(rgb_out_obs3),
    .done(done_obs3)
);

obstacle1 #(.TEST_TOP_LINE(500),
                 .TEST_BOTTOM_LINE(400),
                 .TEST_LEFT_LINE(450), 
                 .TEST_RIGHT_LINE(550),
                 .COLOR(12'h8_8_8),
                 .SELECT_CODE(4'b0100)) rectangle4_obstacle(
//inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .pclk(pclk),
    .rst(locked_reset),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_control(done_control),
  //outputs  
    .working(work4),
    .obstacle_x(obstacle4_x_out),
    .obstacle_y(obstacle4_y_out),
    .rgb_out(rgb_out_obs4),
    .done(done_obs4) 
);

obstacle1 #(.TEST_TOP_LINE(600), 
                 .TEST_BOTTOM_LINE(500), 
                 .TEST_LEFT_LINE(520), 
                 .TEST_RIGHT_LINE(620),
                 .COLOR(12'hf_f_0),
                 .SELECT_CODE(4'b0101)) rectangle5_obstacle(
//inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .pclk(pclk),
    .rst(locked_reset),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_control(done_control),
  //outputs  
    .working(work5),
    .obstacle_x(obstacle5_x_out),
    .obstacle_y(obstacle5_y_out),
    .rgb_out(rgb_out_obs5),
    .done(done_obs5)
);

obstacle1 #(.TEST_TOP_LINE(500),
                 .TEST_BOTTOM_LINE(400),
                 .TEST_LEFT_LINE(520), 
                 .TEST_RIGHT_LINE(620),
                 .COLOR(12'h0_f_f),
                 .SELECT_CODE(4'b0110)) rectangle6_obstacle(
//inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .pclk(pclk),
    .rst(locked_reset),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_control(done_control),
  //outputs  
    .working(work6),
    .obstacle_x(obstacle6_x_out),
    .obstacle_y(obstacle6_y_out),
    .rgb_out(rgb_out_obs6),
    .done(done_obs6) 
);

obstacle1 #(.TEST_TOP_LINE(500),
                 .TEST_BOTTOM_LINE(400),
                 .TEST_LEFT_LINE(400), 
                 .TEST_RIGHT_LINE(500),
                 .COLOR(12'h0_f_0),
                 .SELECT_CODE(4'b0111)) rectangle7_obstacle(
//inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .pclk(pclk),
    .rst(locked_reset),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_control(done_control),
  //outputs  
    .working(work7),
    .obstacle_x(obstacle7_x_out),
    .obstacle_y(obstacle7_y_out),
    .rgb_out(rgb_out_obs7),
    .done(done_obs7) 
);

obstacles_control obstacles_control(
//inputs
    .clk(pclk),
    .rst(locked_reset),
    .done(victory_button || done_obs0 || done_obs1 || done_obs2 || done_obs3 || done_obs4 || done_obs5 || done_obs6 || done_obs7),
    .play_selected(play_selected_back),
    
    .obstacle_code(selected_obstacle),
    .done_out(done_control)
);

obstacle_mux_16_to_1 obstacle_mux_16_to_1(
    //inputs
    .input_0({obstacle0_x_out,obstacle0_y_out,rgb_out_obs0}),
    .input_1({obstacle1_x_out,obstacle1_y_out,rgb_out_obs1}),
    .input_2({obstacle2_x_out,obstacle2_y_out,rgb_out_obs2}),
    .input_3({obstacle3_x_out,obstacle3_y_out,rgb_out_obs3}),
    .input_4({obstacle4_x_out,obstacle4_y_out,rgb_out_obs4}),
    .input_5({obstacle5_x_out,obstacle5_y_out,rgb_out_obs5}),
    .input_6({obstacle6_x_out,obstacle6_y_out,rgb_out_obs6}),
    .input_7({obstacle7_x_out,obstacle7_y_out,rgb_out_obs7}),
    .input_8(0),
    .input_9(0),
    .input_10(0),
    .input_11(0),
    .input_12(0),
    .input_13(0),
    .input_14(0),
    .input_15(0),
    .select(selected_obstacle),
    
    //outputs
    .obstacle_mux_out(mux_out)
);

colision_detector colision_detector(
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
    hp_control
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
    .player_hit(damage_out),
 
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
wire [7:0] draw_rect_char_xy, play_font_rom_pixels;
wire [6:0] play_char_code_out;
wire [3:0] draw_rect_play_line;
wire hsync_out_char, vsync_out_char, hblnk_out_char, vblnk_out_char;

draw_rect_char #(   .TEXT_BOX_X_POS(PLAY_BOX_X_POS), 
                    .TEXT_BOX_Y_POS(PLAY_BOX_Y_POS), 
                    .TEXT_BOX_Y_SIZE(PLAY_BOX_Y_SIZE), 
                    .TEXT_BOX_X_SIZE(PLAY_BOX_X_SIZE)
  )
  draw_single_button                 
  (
  //outputs
  .hcount_out(hcount_out_char),
  .vcount_out(vcount_out_char),
  .hsync_out(hsync_out_char),
  .vsync_out(vsync_out_char),
  .hblnk_out(hblnk_out_char),
  .vblnk_out(vblnk_out_char),
  .rgb_out(rgb_out_char),
  .char_xy(draw_rect_char_xy),
  .char_line(draw_rect_play_line),
  
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
  .char_pixels(play_font_rom_pixels),
  .mouse_xpos(xpos_out_mouseCtl),
  .mouse_ypos(ypos_out_mouseCtl),
  .display_buttons(display_buttons_m_and_s)
  );

char_rom_16x16 single_char_rom(
    //inputs
    .char_xy(draw_rect_char_xy),
    //outputs
    .char_code(play_char_code_out)
);

font_rom single_font_rom(
    //inputs
    .clk(pclk),
    .addr({play_char_code_out, draw_rect_play_line}),
    //outputs
    .char_line_pixels(play_font_rom_pixels)
);

//MULTPLAYER BUTTON
wire [11:0] hcount_out_multi, vcount_out_multi, rgb_out_multi;
wire [7:0] draw_rect_mutli_xy, multi_font_rom_pixels;
wire [6:0] multi_char_code_out;
wire [3:0] draw_rect_multi_line;
wire hsync_out_multi, vsync_out_multi, hblnk_out_multi, vblnk_out_multi;



draw_rect_char #(   .TEXT_BOX_X_POS(MULTI_BOX_X_POS), 
                    .TEXT_BOX_Y_POS(MULTI_BOX_Y_POS), 
                    .TEXT_BOX_Y_SIZE(MULTI_BOX_Y_SIZE), 
                    .TEXT_BOX_X_SIZE(MULTI_BOX_X_SIZE)
  )
  draw_multiplayer_button                 
  (
  //outputs
  .hcount_out(hcount_out_multi),
  .vcount_out(vcount_out_multi),
  .hsync_out(hsync_out_multi),
  .vsync_out(vsync_out_multi),
  .hblnk_out(hblnk_out_multi),
  .vblnk_out(vblnk_out_multi),
  .rgb_out(rgb_out_multi),
  .char_xy(draw_rect_mutli_xy),
  .char_line(draw_rect_multi_line),
  
  //inputs
  .rst(locked_reset),
  .clk(pclk),
  .hcount_in(hcount_out_char),
  .vcount_in(vcount_out_char),
  .hsync_in(hsync_out_char),
  .vsync_in(vsync_out_char),
  .hblnk_in(hblnk_out_char),
  .vblnk_in(vblnk_out_char),
  .rgb_in(rgb_out_char),
  .char_pixels(multi_font_rom_pixels),
  .mouse_xpos(xpos_out_mouseCtl),
  .mouse_ypos(ypos_out_mouseCtl),
  .display_buttons(display_buttons_m_and_s)
  );

multi_char_rom_16x16 multi_char_rom(
    //inputs
    .multi_char_xy(draw_rect_mutli_xy),
    //outputs
    .multi_char_code(multi_char_code_out)
);

font_rom multi_font_rom(
    //inputs
    .clk(pclk),
    .addr({multi_char_code_out, draw_rect_multi_line}),
    //outputs
    .char_line_pixels(multi_font_rom_pixels)
);



//MENU BUTTON

wire [11:0] hcount_out_menubut, vcount_out_menubut, rgb_out_menubut;
wire [7:0] draw_rect_menubut_xy, menubut_font_rom_pixels;
wire [6:0] menubut_char_code_out;
wire [3:0] draw_rect_menubut_line;
wire hsync_out_menubut, vsync_out_menubut, hblnk_out_menubut, vblnk_out_menubut;

draw_rect_char #(   .TEXT_BOX_X_POS(MENU_BOX_X_POS), 
                    .TEXT_BOX_Y_POS(MENU_BOX_Y_POS), 
                    .TEXT_BOX_Y_SIZE(MENU_BOX_Y_SIZE), 
                    .TEXT_BOX_X_SIZE(MENU_BOX_X_SIZE)
  )
  draw_menu_button                 
  (
  //outputs
  .hcount_out(hcount_out_menubut),
  .vcount_out(vcount_out_menubut),
  .hsync_out(hsync_out_menubut),
  .vsync_out(vsync_out_menubut),
  .hblnk_out(hblnk_out_menubut),
  .vblnk_out(vblnk_out_menubut),
  .rgb_out(rgb_out_menubut),
  .char_xy(draw_rect_menubut_xy),
  .char_line(draw_rect_menubut_line),
  
  //inputs
  .rst(locked_reset),
  .clk(pclk),
  .hcount_in(hcount_out_multi),
  .vcount_in(vcount_out_multi),
  .hsync_in(hsync_out_multi),
  .vsync_in(vsync_out_multi),
  .hblnk_in(hblnk_out_multi),
  .vblnk_in(vblnk_out_multi),
  .rgb_in(rgb_out_multi),
  .char_pixels(menubut_font_rom_pixels),
  .mouse_xpos(xpos_out_mouseCtl),
  .mouse_ypos(ypos_out_mouseCtl),
  .display_buttons(display_menu_button)
  );

menu_char_rom_16x16 menu_char_rom(
    //inputs
    .menu_char_xy(draw_rect_menubut_xy),
    //outputs
    .menu_char_code(menubut_char_code_out)
);

font_rom menu_font_rom(
    //inputs
    .clk(pclk),
    .addr({menubut_char_code_out, draw_rect_menubut_line}),
    //outputs
    .char_line_pixels(menubut_font_rom_pixels)
);


//MOUSE MODULES//  

  MouseCtl My_MouseCtl(
  //inouts
      .ps2_clk(ps2_clk),
      .ps2_data(ps2_data),
  //inputs
      .rst(locked_reset),
      .clk(clkMouse),
      .setx(set_x_constr),
      .sety(set_y_constr),
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
                      .MAX_X(RIGHT_H_LINE)) mouse_constrainer (
  //inputs
      .clk(pclk),
      .rst(locked_reset),
      .mouse_mode(mouse_mode_out_back),
  //outputs
      .setmax_x(setmax_x_constr),
      .setmax_y(setmax_y_constr),
      .setmin_x(setmin_x_constr),
      .setmin_y(setmin_y_constr),
      .set_x(set_x_constr),
      .set_y(set_y_constr),
      .value(value_constr)
  );

  MouseDisplay MouseDisplay (
  //inputs
    .xpos(xpos_out_mouseCtl),
    .ypos(ypos_out_mouseCtl),
    .pixel_clk(pclk),
    .hcount(hcount_out_menubut),
    .vcount(vcount_out_menubut),
    .blank(hblnk_out_menubut || vblnk_out_menubut), 
    .red_in(rgb_out_menubut[11:8]),
    .green_in(rgb_out_menubut[7:4]),
    .blue_in(rgb_out_menubut[3:0]),
  //outputs
      .red_out(red_out_mouse),
      .green_out(green_out_mouse),
      .blue_out(blue_out_mouse),
      .enable_mouse_display_out()
  );
  


//UART

top uart_top(
    //inputs
    .clk(pclk),
    .rst(locked_reset),
    .rx(rx),
    .game_over(game_over_hp),
    .player_ready(player_ready),
    .multiplayer(multiplayer_out_back),

    //outputs
    .tx(tx),
    .curr_char_out(curr_char_out),
    .an(an),
    .seg(seg)
);

comparator comparator(
    //inputs
    .clk(pclk),
    .rst(locked_reset),
    .curr_char(curr_char_out),
    .play_selected(play_selected_back),
    .multiplayer(multiplayer_out_back),
    // outputs
    .victory(victory),
    .opponent_ready(opponent_ready)
);


assign hs = hsync_out_menubut;
assign vs = vsync_out_menubut;
assign {r,g,b} = {red_out_mouse, green_out_mouse, blue_out_mouse};
assign led = {work7, work6, work5, work4, work3, work2, work1, work0 ,4'b0000, selected_obstacle};
endmodule
