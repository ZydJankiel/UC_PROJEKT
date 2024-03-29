`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.07.2021 14:24:05
// Design Name: 
// Module Name: draw_rect_char
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*
*MO-created module, parametrized to allow using in multiple instances
*
*/

module draw_rect_char 
    #( parameter
        //DO NOT TOUCH X POS - IT DISTORTS LETTERS SHAPE
        TEXT_BOX_X_POS  = 432,
        TEXT_BOX_Y_POS  = 400,
        TEXT_BOX_Y_SIZE = 80,
        TEXT_BOX_X_SIZE = 128
    )
    (      
        input wire clk,
        input wire rst,
        input wire [11:0] hcount_in,
        input wire hsync_in,
        input wire hblnk_in,
        input wire [11:0] vcount_in,
        input wire vsync_in,
        input wire vblnk_in,
        input wire [11:0] rgb_in,
        input wire [7:0] char_pixels,
        input wire [11:0] mouse_xpos,
        input wire [11:0] mouse_ypos,
        input wire display_buttons,
        
        output reg [11:0] hcount_out,
        output reg hsync_out,
        output reg hblnk_out,
        output reg [11:0] vcount_out,
        output reg vsync_out, 
        output reg vblnk_out,
        output reg [11:0] rgb_out,
        //output reg [10:0] addr,
        output reg [7:0] char_xy,
        output reg [3:0] char_line
    );
    
reg vsync_nxt, vblnk_nxt, hsync_nxt, hblnk_nxt;   
reg [10:0] vcount_nxt, hcount_nxt, vcount_rect, hcount_rect;
reg [11:0] rgb_nxt;



localparam BG_BLACK = 12'h0_0_0;
localparam LETTER_COLOUR = 12'h0_0_f;
localparam TEXT_BG_COLOUR = 12'h0_f_0;
localparam MOUSE_OVER_COLOUR = 12'hf_f_0;

always @(posedge clk) begin
    if (rst) begin
        vcount_out <= 0;
        vblnk_out  <= 0;
        vsync_out  <= 0;
        hcount_out <= 0;
        hsync_out  <= 0;
        hblnk_out  <= 0;
        rgb_out    <= 0;
    end
    else begin
        vcount_out <= vcount_nxt;
        vblnk_out  <= vblnk_nxt;
        vsync_out  <= vsync_nxt;
        hcount_out <= hcount_nxt;
        hsync_out  <= hsync_nxt;
        hblnk_out  <= hblnk_nxt;
        rgb_out    <= rgb_nxt;
    end 
end 
    
always @* begin
    vcount_nxt = vcount_in;
    vblnk_nxt  = vblnk_in;
    vsync_nxt  = vsync_in;
    hcount_nxt = hcount_in;
    hsync_nxt  = hsync_in;
    hblnk_nxt  = hblnk_in;
          
    if (display_buttons) begin   
        if (hblnk_out || vblnk_out) 
            rgb_nxt = BG_BLACK; 
        else if (vcount_in <= TEXT_BOX_Y_SIZE + TEXT_BOX_Y_POS && vcount_in >= TEXT_BOX_Y_POS && hcount_in <= TEXT_BOX_X_SIZE + TEXT_BOX_X_POS && hcount_in >= TEXT_BOX_X_POS) begin
            if (char_pixels[9-(hcount_in%8)]) 
                rgb_nxt = LETTER_COLOUR;
            else begin
                if (mouse_xpos >= TEXT_BOX_X_POS - 10 && mouse_xpos <= TEXT_BOX_X_SIZE + TEXT_BOX_X_POS -5 && mouse_ypos >= TEXT_BOX_Y_POS - 10 && mouse_ypos <= TEXT_BOX_Y_SIZE + TEXT_BOX_Y_POS)
                    rgb_nxt = MOUSE_OVER_COLOUR;
                else
                    rgb_nxt = TEXT_BG_COLOUR; 
            end
        end
        else
            rgb_nxt = rgb_in;
    end
    else  
        rgb_nxt = rgb_in;
                    
    vcount_rect = vcount_in -  TEXT_BOX_Y_POS;
    hcount_rect = hcount_in -  TEXT_BOX_X_POS;
          
    char_xy = {vcount_rect[7:4], hcount_rect[6:3]};
    char_line = vcount_rect[3:0];
         
end

     
endmodule
