/*
 * PWJ: Added module for CORE logic

*/

module CORE 
    #( parameter
        TOP_V_LINE       = 317,
        BOTTOM_V_LINE    = 617,
        LEFT_H_LINE      = 361,
        RIGHT_H_LINE     = 661   
    )
    (
        input wire clk,
        input wire rst,
        input wire game_button,
        input wire menu_button,
        input wire victory_button,
        input wire game_over_button,
        input wire [11:0] xpos,
        input wire [11:0] ypos,
        input wire mouse_left,
        input wire victory,
        input wire opponent_ready,

        output wire hsync,
        output wire vsync,
        output wire mouse_mode,
        output wire game_over,
        output wire player_ready,
        output wire play_selected,
        output wire multiplayer,
        output wire [11:0] rgb_out,
        output wire [3:0] an,
        output wire [7:0] seg
    );

wire [35:0] mux_out;

wire [27:0] delayed_signals;  

wire [15:0] obstacles_counted;

wire [11:0] rgb_out_back, rgb_out_hp, rgb_out_obs0, rgb_out_obs1, rgb_out_obs2, rgb_out_obs3, rgb_out_obs4, rgb_out_obs5, rgb_out_obs6, rgb_out_obs7;
wire [11:0] vcount_out_timing, hcount_out_timing, vcount_out_back, hcount_out_back, vcount_out_hp, hcount_out_hp;
wire [11:0] obstacle0_x_out,obstacle0_y_out, obstacle1_x_out, obstacle1_y_out, obstacle2_x_out, obstacle2_y_out, obstacle3_x_out, obstacle3_y_out;
wire [11:0] obstacle4_x_out,obstacle4_y_out, obstacle5_x_out, obstacle5_y_out, obstacle6_x_out, obstacle6_y_out, obstacle7_x_out, obstacle7_y_out;

wire [3:0] red_out_mouse, green_out_mouse, blue_out_mouse;
wire [3:0] obstacle_mux_select_bg;
wire [3:0] selected_obstacle, mux_code;

wire [2:0] mouse_mode_back; 

wire play_selected_back, display_buttons_m_and_s, display_menu_button;
wire vsync_out_timing, hsync_out_timing, vsync_out_back, hsync_out_back, vsync_out_hp, hsync_out_hp;
wire vblnk_out_timing, hblnk_out_timing, vblnk_out_back, hblnk_out_back, vblnk_out_hp, hblnk_out_hp;
wire damage_out, game_over_hp;
wire player_ready_back, multiplayer_back;

wire done_obs0, done_obs1, done_obs2, done_obs3, done_obs4, done_obs5, done_obs6, done_obs7, done_control, done_counter;

localparam  PLAY_BOX_X_POS  = 432,
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



vga_timing vga_timing (
    //inputs 
    .clk(clk),
    .rst(rst),
    
    //outputs
    .vcount(vcount_out_timing),
    .vsync(vsync_out_timing),
    .vblnk(vblnk_out_timing),
    .hcount(hcount_out_timing),
    .hsync(hsync_out_timing),
    .hblnk(hblnk_out_timing)
);

draw_background #( .TOP_V_LINE(TOP_V_LINE), 
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
                   .MULTI_BOX_X_SIZE(MULTI_BOX_X_SIZE) ) draw_game_background (
    //inputs
    .vcount_in(vcount_out_timing),
    .vsync_in(vsync_out_timing),
    .vblnk_in(vblnk_out_timing),
    .hcount_in(hcount_out_timing),
    .hsync_in(hsync_out_timing),
    .hblnk_in(hblnk_out_timing),
    .clk(clk),
    .rst(rst),
    .game_on(game_button),
    .menu_on(menu_button),
    .game_over(game_over_button || game_over_hp),
    .xpos(xpos),
    .ypos(ypos),
    .mouse_left(mouse_left),
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
    .mouse_mode(mouse_mode_back),
    .play_selected(play_selected_back),
    .display_buttons_m_and_s(display_buttons_m_and_s),
    .player_ready(player_ready_back),
    .display_menu_button(display_menu_button),
    .multiplayer(multiplayer_back)
);

delay #(.WIDTH(28), .CLK_DEL(1))  control_signals_delay(
    //inputs
    .clk(clk),
    .rst(rst),
    .din({vcount_out_back, vsync_out_back, vblnk_out_back, hcount_out_back,  hsync_out_back, hblnk_out_back}),
    
    //outputs
    .dout(delayed_signals)
);

pillars_horizontal_obstacle #(.SELECT_CODE(4'b0000)) pillars_horizontal_obstacle(
    //inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .clk(clk),
    .rst(rst),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_in(done_counter),
    
    //outputs  
    .obstacle_x(obstacle0_x_out),
    .obstacle_y(obstacle0_y_out),
    .rgb_out(rgb_out_obs0),
    .done(done_obs0)
);

lasers_obstacle vertical_lasers_obstacle (
    //inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .clk(clk),
    .rst(rst),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_in(done_counter),
    
    //outputs  
    .obstacle_x(obstacle1_x_out),
    .obstacle_y(obstacle1_y_out),
    .rgb_out(rgb_out_obs1),
    .done(done_obs1) 
);

horizontal_lasers_obstacle horizontal_lasers_obstacle (
    //inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .clk(clk),
    .rst(rst),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_in(done_counter),
    
    //outputs  
    .obstacle_x(obstacle2_x_out),
    .obstacle_y(obstacle2_y_out),
    .rgb_out(rgb_out_obs2),
    .done(done_obs2)
);

square_follow_obstacle square_follow_obstacle (
    //inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .clk(clk),
    .rst(rst),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_in(done_counter),
    
    //outputs  
    .obstacle_x(obstacle3_x_out),
    .obstacle_y(obstacle3_y_out),
    .rgb_out(rgb_out_obs3),
    .done(done_obs3)
);

mouse_follower_obstacle mouse_follower_obstacle(
    //inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .clk(clk),
    .rst(rst),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_in(done_counter),
    .mouse_xpos(xpos),
    .mouse_ypos(ypos),

    //outputs  
    .obstacle_x(obstacle4_x_out),
    .obstacle_y(obstacle4_y_out),
    .rgb_out(rgb_out_obs4),
    .done(done_obs4) 
);

obstacle1 #( .TEST_TOP_LINE(600), 
             .TEST_BOTTOM_LINE(500), 
             .TEST_LEFT_LINE(520), 
             .TEST_RIGHT_LINE(620),
             .COLOR(12'hf_f_0),
             .SELECT_CODE(4'b0101) ) rectangle5_obstacle (
    //inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .clk(clk),
    .rst(rst),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_in(done_counter),
    
    //outputs  
    .obstacle_x(obstacle5_x_out),
    .obstacle_y(obstacle5_y_out),
    .rgb_out(rgb_out_obs5),
    .done(done_obs5)
);

obstacle1 #( .TEST_TOP_LINE(500),
             .TEST_BOTTOM_LINE(400),
             .TEST_LEFT_LINE(520), 
             .TEST_RIGHT_LINE(620),
             .COLOR(12'h0_f_f),
             .SELECT_CODE(4'b0110) ) rectangle6_obstacle (
    //inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .clk(clk),
    .rst(rst),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_in(done_counter),
    
    //outputs  
    .obstacle_x(obstacle6_x_out),
    .obstacle_y(obstacle6_y_out),
    .rgb_out(rgb_out_obs6),
    .done(done_obs6) 
);

obstacle1 #( .TEST_TOP_LINE(500),
             .TEST_BOTTOM_LINE(400),
             .TEST_LEFT_LINE(400), 
             .TEST_RIGHT_LINE(500),
             .COLOR(12'h0_f_0),
             .SELECT_CODE(4'b0111) ) rectangle7_obstacle (
    //inputs
    .vcount_in(vcount_out_back),
    .hcount_in(hcount_out_back),
    .clk(clk),
    .rst(rst),
    .game_on(game_button),
    .menu_on(menu_button),
    .rgb_in(rgb_out_back),
    .play_selected(play_selected_back),
    .selected(selected_obstacle),
    .done_in(done_counter),
    
    //outputs  
    .obstacle_x(obstacle7_x_out),
    .obstacle_y(obstacle7_y_out),
    .rgb_out(rgb_out_obs7),
    .done(done_obs7) 
);

obstacles_counter obstacles_counter (
    //inputs
    .clk(clk),
    .rst(rst),
    .start(play_selected_back),
    .done_in(done_control),
    
    //outputs
    .done_out(done_counter),
    .obstacles_counted(obstacles_counted)
);

obstacles_control obstacles_control (
    //inputs
    .clk(clk),
    .rst(rst),
    .done(victory_button || done_obs0 || done_obs1 || done_obs2 || done_obs3 || done_obs4 || done_obs5 || done_obs6 || done_obs7),
    .play_selected(play_selected_back),
    
    //outputs
    .obstacle_code(selected_obstacle),
    .done_out(done_control)
);

disp_hex_mux my_disp(
    .clk(clk), 
    .reset(rst),
    .hex3(obstacles_counted[15:12]), 
    .hex2(obstacles_counted[11:8]), 
    .hex1(obstacles_counted[7:4]), 
    .hex0(obstacles_counted[3:0]), 
    .dp_in(4'b1111),
    .an(an), 
    .sseg(seg)
);

obstacle_mux_16_to_1 obstacle_mux_16_to_1 (
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

colision_detector colision_detector (
    //inputs
    .clk(clk),
    .rst(rst),
    .obstacle_x_in(mux_out[35:24]),
    .obstacle_y_in(mux_out[23:12]),
    .mouse_x_in(xpos),
    .mouse_y_in(ypos),
    
    //outputs
    .damage_out(damage_out)
);

hp_control #( .TOP_V_LINE(TOP_V_LINE), 
              .BOTTOM_V_LINE(BOTTOM_V_LINE), 
              .LEFT_H_LINE(LEFT_H_LINE), 
              .RIGHT_H_LINE(RIGHT_H_LINE),
              .BORDER(3)) hp_control (
    //inputs
    .vcount_in_hp(delayed_signals[27:16]),
    .vsync_in_hp(delayed_signals[15]),
    .vblnk_in_hp(delayed_signals[14]),
    .hcount_in_hp(delayed_signals[13:2]),
    .hsync_in_hp(delayed_signals[1]),
    .hblnk_in_hp(delayed_signals[0]),
    .rgb_in_hp(mux_out[11:0]),
    .clk(clk),
    .rst(rst),
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

//SINGLE BUTTON

wire [11:0] hcount_out_char, vcount_out_char, rgb_out_char;
wire [7:0] draw_rect_char_xy, play_font_rom_pixels;
wire [6:0] play_char_code_out;
wire [3:0] draw_rect_play_line;
wire hsync_out_char, vsync_out_char, hblnk_out_char, vblnk_out_char;

draw_rect_char #( .TEXT_BOX_X_POS(PLAY_BOX_X_POS), 
                  .TEXT_BOX_Y_POS(PLAY_BOX_Y_POS), 
                  .TEXT_BOX_Y_SIZE(PLAY_BOX_Y_SIZE), 
                  .TEXT_BOX_X_SIZE(PLAY_BOX_X_SIZE) ) draw_single_button (
    //inputs
    .rst(rst),
    .clk(clk),
    .hcount_in(hcount_out_hp),
    .vcount_in(vcount_out_hp),
    .hsync_in(hsync_out_hp),
    .vsync_in(vsync_out_hp),
    .hblnk_in(hblnk_out_hp),
    .vblnk_in(vblnk_out_hp),
    .rgb_in(rgb_out_hp),
    .char_pixels(play_font_rom_pixels),
    .mouse_xpos(xpos),
    .mouse_ypos(ypos),
    .display_buttons(display_buttons_m_and_s),
    
    //outputs
    .hcount_out(hcount_out_char),
    .vcount_out(vcount_out_char),
    .hsync_out(hsync_out_char),
    .vsync_out(vsync_out_char),
    .hblnk_out(hblnk_out_char),
    .vblnk_out(vblnk_out_char),
    .rgb_out(rgb_out_char),
    .char_xy(draw_rect_char_xy),
    .char_line(draw_rect_play_line)
);

char_rom_16x16 single_char_rom (
    //inputs
    .char_xy(draw_rect_char_xy),
    
    //outputs
    .char_code(play_char_code_out)
);

font_rom single_font_rom (
    //inputs
    .clk(clk),
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



draw_rect_char #( .TEXT_BOX_X_POS(MULTI_BOX_X_POS), 
                  .TEXT_BOX_Y_POS(MULTI_BOX_Y_POS), 
                  .TEXT_BOX_Y_SIZE(MULTI_BOX_Y_SIZE), 
                  .TEXT_BOX_X_SIZE(MULTI_BOX_X_SIZE) ) draw_multiplayer_button (
    //inputs
    .rst(rst),
    .clk(clk),
    .hcount_in(hcount_out_char),
    .vcount_in(vcount_out_char),
    .hsync_in(hsync_out_char),
    .vsync_in(vsync_out_char),
    .hblnk_in(hblnk_out_char),
    .vblnk_in(vblnk_out_char),
    .rgb_in(rgb_out_char),
    .char_pixels(multi_font_rom_pixels),
    .mouse_xpos(xpos),
    .mouse_ypos(ypos),
    .display_buttons(display_buttons_m_and_s),
    
    //outputs
    .hcount_out(hcount_out_multi),
    .vcount_out(vcount_out_multi),
    .hsync_out(hsync_out_multi),
    .vsync_out(vsync_out_multi),
    .hblnk_out(hblnk_out_multi),
    .vblnk_out(vblnk_out_multi),
    .rgb_out(rgb_out_multi),
    .char_xy(draw_rect_mutli_xy),
    .char_line(draw_rect_multi_line)
);

multi_char_rom_16x16 multi_char_rom (
    //inputs
    .multi_char_xy(draw_rect_mutli_xy),
    
    //outputs
    .multi_char_code(multi_char_code_out)
);

font_rom multi_font_rom (
    //inputs
    .clk(clk),
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

draw_rect_char #( .TEXT_BOX_X_POS(MENU_BOX_X_POS), 
                  .TEXT_BOX_Y_POS(MENU_BOX_Y_POS), 
                  .TEXT_BOX_Y_SIZE(MENU_BOX_Y_SIZE), 
                  .TEXT_BOX_X_SIZE(MENU_BOX_X_SIZE) ) draw_menu_button (
    //inputs
    .rst(rst),
    .clk(clk),
    .hcount_in(hcount_out_multi),
    .vcount_in(vcount_out_multi),
    .hsync_in(hsync_out_multi),
    .vsync_in(vsync_out_multi),
    .hblnk_in(hblnk_out_multi),
    .vblnk_in(vblnk_out_multi),
    .rgb_in(rgb_out_multi),
    .char_pixels(menubut_font_rom_pixels),
    .mouse_xpos(xpos),
    .mouse_ypos(ypos),
    .display_buttons(display_menu_button),
    
    //outputs
    .hcount_out(hcount_out_menubut),
    .vcount_out(vcount_out_menubut),
    .hsync_out(hsync_out_menubut),
    .vsync_out(vsync_out_menubut),
    .hblnk_out(hblnk_out_menubut),
    .vblnk_out(vblnk_out_menubut),
    .rgb_out(rgb_out_menubut),
    .char_xy(draw_rect_menubut_xy),
    .char_line(draw_rect_menubut_line)
);

menu_char_rom_16x16 menu_char_rom (
    //inputs
    .menu_char_xy(draw_rect_menubut_xy),
    
    //outputs
    .menu_char_code(menubut_char_code_out)
);

font_rom menu_font_rom (
    //inputs
    .clk(clk),
    .addr({menubut_char_code_out, draw_rect_menubut_line}),
    
    //outputs
    .char_line_pixels(menubut_font_rom_pixels)
);

//MOUSE MODULES//  

MouseDisplay MouseDisplay (
    //inputs
    .xpos(xpos),
    .ypos(ypos),
    .pixel_clk(clk),
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


assign hsync = hsync_out_menubut;
assign vsync = vsync_out_menubut;
assign rgb_out = {red_out_mouse, green_out_mouse, blue_out_mouse};
assign play_selected = play_selected_back;
assign player_ready = player_ready_back;
assign mouse_mode = mouse_mode_back;
assign multiplayer = multiplayer_back;
assign game_over = game_over_hp;

endmodule