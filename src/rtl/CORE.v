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



wire [35:0] obstacle_data;

wire [27:0] delayed_signals;

wire [15:0] obstacles_counted;

wire [11:0] rgb_out_back, rgb_out_hp;
wire [11:0] vcount_out_timing, hcount_out_timing, vcount_out_back, hcount_out_back, vcount_out_hp, hcount_out_hp;


wire [3:0] red_out_mouse, green_out_mouse, blue_out_mouse;

wire [2:0] mouse_mode_vga_control, control_state; 

wire play_selected_vga_control, display_buttons_m_and_s, display_menu_button;
wire vsync_out_timing, hsync_out_timing, vsync_out_back, hsync_out_back, vsync_out_hp, hsync_out_hp;
wire vblnk_out_timing, hblnk_out_timing, vblnk_out_back, hblnk_out_back, vblnk_out_hp, hblnk_out_hp;
wire damage_out, game_over_hp;
wire player_ready_vga_control, multiplayer_vga_control;



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

control_unit  #( .PLAY_BOX_X_POS(PLAY_BOX_X_POS),
                 .PLAY_BOX_Y_POS(PLAY_BOX_Y_POS),
                 .PLAY_BOX_Y_SIZE(PLAY_BOX_Y_SIZE),
                 .PLAY_BOX_X_SIZE(PLAY_BOX_X_SIZE),
                  
                 .MULTI_BOX_X_POS(MULTI_BOX_X_POS),
                 .MULTI_BOX_Y_POS(MULTI_BOX_Y_POS),
                 .MULTI_BOX_Y_SIZE(MULTI_BOX_Y_SIZE),
                 .MULTI_BOX_X_SIZE(MULTI_BOX_X_SIZE)) vga_control_unit (
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
    
    .state(control_state),
    .mouse_mode(mouse_mode_vga_control),
    .play_selected(play_selected_vga_control),
    .display_buttons_m_and_s(display_buttons_m_and_s),
    .player_ready(player_ready_vga_control),
    .display_menu_button(display_menu_button),
    .multiplayer(multiplayer_vga_control)
                   
);

draw_background #( .TOP_V_LINE(TOP_V_LINE), 
                   .BOTTOM_V_LINE(BOTTOM_V_LINE), 
                   .LEFT_H_LINE(LEFT_H_LINE), 
                   .RIGHT_H_LINE(RIGHT_H_LINE),
                   .BORDER(7) ) draw_game_background (
    //inputs
    .clk(clk),
    .rst(rst),
    .vcount_in(vcount_out_timing),
    .vsync_in(vsync_out_timing),
    .vblnk_in(vblnk_out_timing),
    .hcount_in(hcount_out_timing),
    .hsync_in(hsync_out_timing),
    .hblnk_in(hblnk_out_timing),
    .control_state(control_state),

    //outputs  
    .hcount_out(hcount_out_back),
    .vcount_out(vcount_out_back),
    .hblnk_out(hblnk_out_back),
    .vblnk_out(vblnk_out_back),
    .hsync_out(hsync_out_back),
    .vsync_out(vsync_out_back),
    .rgb_out(rgb_out_back)

);

OBSTACLES OBSTACLES (
    .clk(clk),
    .rst(rst),
    .hcount_in(hcount_out_back),
    .hblnk_in(hblnk_out_back),
    .hsync_in(hsync_out_back),
    .vcount_in(vcount_out_back),
    .vblnk_in(vblnk_out_back),
    .vsync_in(vsync_out_back),
    .rgb_in(rgb_out_back),
    .game_on(game_button),
    .menu_on(menu_button),
    .xpos(xpos),
    .ypos(ypos),
    .victory(victory_button),
    .play_selected(play_selected_vga_control),
    
    .obstacles_counted(obstacles_counted),
    .delayed_signals(delayed_signals),
    .obstacle_data(obstacle_data)
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

colision_detector colision_detector (
    //inputs
    .clk(clk),
    .rst(rst),
    .obstacle_x_in(obstacle_data[35:24]),
    .obstacle_y_in(obstacle_data[23:12]),
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
    .rgb_in_hp(obstacle_data[11:0]),
    .clk(clk),
    .rst(rst),
    .game_on_hp(play_selected_vga_control),
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

wire [11:0] hcount_out_BUTTONS, vcount_out_BUTTONS, rgb_out_BUTTONS;
wire hsync_out_BUTTONS, vsync_out_BUTTONS, hblnk_out_BUTTONS, vblnk_out_BUTTONS;

BUTTONS  #( .PLAY_BOX_X_POS(PLAY_BOX_X_POS),
            .PLAY_BOX_Y_POS(PLAY_BOX_Y_POS),
            .PLAY_BOX_Y_SIZE(PLAY_BOX_Y_SIZE),
            .PLAY_BOX_X_SIZE(PLAY_BOX_X_SIZE),
            
            .MULTI_BOX_X_POS(MULTI_BOX_X_POS),
            .MULTI_BOX_Y_POS(MULTI_BOX_Y_POS),
            .MULTI_BOX_Y_SIZE(MULTI_BOX_Y_SIZE),
            .MULTI_BOX_X_SIZE(MULTI_BOX_X_SIZE),
             
            .MENU_BOX_X_POS(MENU_BOX_X_POS), 
            .MENU_BOX_Y_POS(MENU_BOX_Y_POS), 
            .MENU_BOX_Y_SIZE(MENU_BOX_Y_SIZE), 
            .MENU_BOX_X_SIZE(MENU_BOX_X_SIZE)) BUTTONS (
    .clk(clk),
    .rst(rst),
    .hcount_in(hcount_out_hp),
    .hblnk_in(hblnk_out_hp),
    .hsync_in(hsync_out_hp),
    .vcount_in(vcount_out_hp),
    .vblnk_in(vblnk_out_hp),
    .vsync_in(vsync_out_hp),
    .rgb_in(rgb_out_hp),
    .display_buttons_m_and_s(display_buttons_m_and_s),
    .display_menu_button(display_menu_button),
    .xpos(xpos),
    .ypos(ypos),

    .hcount_out(hcount_out_BUTTONS),
    .hblnk_out(hblnk_out_BUTTONS),
    .hsync_out(hsync_out_BUTTONS),
    .vcount_out(vcount_out_BUTTONS),
    .vblnk_out(vblnk_out_BUTTONS),
    .vsync_out(vsync_out_BUTTONS),
    .rgb_out(rgb_out_BUTTONS)

);

//MOUSE MODULES//  

MouseDisplay MouseDisplay (
    //inputs
    .xpos(xpos),
    .ypos(ypos),
    .pixel_clk(clk),
    .hcount(hcount_out_BUTTONS),
    .vcount(vcount_out_BUTTONS),
    .blank(hblnk_out_BUTTONS || vblnk_out_BUTTONS), 
    .red_in(rgb_out_BUTTONS[11:8]),
    .green_in(rgb_out_BUTTONS[7:4]),
    .blue_in(rgb_out_BUTTONS[3:0]),
    
    //outputs
    .red_out(red_out_mouse),
    .green_out(green_out_mouse),
    .blue_out(blue_out_mouse),
    .enable_mouse_display_out()
);


assign hsync = hsync_out_BUTTONS;
assign vsync = vsync_out_BUTTONS;
assign rgb_out = {red_out_mouse, green_out_mouse, blue_out_mouse};
assign play_selected = play_selected_vga_control;
assign player_ready = player_ready_vga_control;
assign mouse_mode = mouse_mode_vga_control;
assign multiplayer = multiplayer_vga_control;
assign game_over = game_over_hp;

endmodule