module BUTTONS 
    #( parameter
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
        MENU_BOX_X_SIZE = 128 
    )
    (
        input wire clk,
        input wire rst,
        input wire [11:0] hcount_in,
        input wire hblnk_in,
        input wire hsync_in,
        input wire [11:0] vcount_in,
        input wire vblnk_in,
        input wire vsync_in,
        input wire [11:0] rgb_in,
        input wire display_buttons_m_and_s,
        input wire display_menu_button,
        input wire [11:0] xpos,
        input wire [11:0] ypos,

        output wire [11:0] hcount_out,
        output wire hblnk_out,
        output wire hsync_out,
        output wire [11:0] vcount_out,
        output wire vblnk_out,
        output wire vsync_out,
        output wire [11:0] rgb_out
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
    //output
    .rst(rst),
    .clk(clk),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .hsync_in(hsync_in),
    .vsync_in(vsync_in),
    .hblnk_in(hblnk_in),
    .vblnk_in(vblnk_in),
    .rgb_in(rgb_in),
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
    //output
    .char_xy(draw_rect_char_xy),
    
    //outputs
    .char_code(play_char_code_out)
);

font_rom single_font_rom (
    //output
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
    //output
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
    //output
    .multi_char_xy(draw_rect_mutli_xy),
    
    //outputs
    .multi_char_code(multi_char_code_out)
);

font_rom multi_font_rom (
    //output
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
    //output
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
    //output
    .menu_char_xy(draw_rect_menubut_xy),
    
    //outputs
    .menu_char_code(menubut_char_code_out)
);

font_rom menu_font_rom (
    //output
    .clk(clk),
    .addr({menubut_char_code_out, draw_rect_menubut_line}),
    
    //outputs
    .char_line_pixels(menubut_font_rom_pixels)
);

assign hcount_out = hcount_out_menubut;
assign hblnk_out = hblnk_out_menubut;
assign hsync_out = hsync_out_menubut;
assign vcount_out = vcount_out_menubut;
assign vblnk_out = vblnk_out_menubut;
assign vsync_out = vsync_out_menubut;
assign rgb_out = rgb_out_menubut;

endmodule