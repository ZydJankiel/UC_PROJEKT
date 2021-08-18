`timescale 1 ns / 1 ps

// PWJ: Based on module from laboratory class

module draw_sens (
  input wire [11:0] vcount_in,
  input wire vsync_in,
  input wire vblnk_in,
  input wire [11:0] hcount_in,
  input wire hsync_in,
  input wire hblnk_in,
  input wire [11:0] rgb_in,
  input wire pclk,
  input wire rst,
  input wire [11:0] rgb_pixel,
  input wire game_on,
  input wire victory_or_defeat,
  input wire multiplayer,

  output reg [11:0] vcount_out,
  output reg vsync_out,
  output reg vblnk_out,
  output reg [11:0] hcount_out,
  output reg hsync_out,
  output reg hblnk_out,
  output reg [11:0] rgb_out,
  output reg [15:0] pixel_addr
  );
  
reg [10:0] addrx, addry;
reg [11:0] rgb_nxt;
reg [11:0] vcount_nxt, hcount_nxt;
reg vsync_nxt, vblnk_nxt, hsync_nxt, hblnk_nxt;
reg state, state_nxt;

localparam MENU = 0,
           GAME = 1;

localparam RECT_WIDTH = 180;
localparam RECT_HEIGHT = 220;

localparam X_START_GAME = 425;
localparam Y_START_GAME = 30;

localparam X_START_MENU = 700;
localparam Y_START_MENU = 430;

always @(posedge pclk) begin
  if (rst) begin
    state      <= MENU;
    vcount_out <= 0;
    vblnk_out  <= 0;
    vsync_out  <= 0;
    hcount_out <= 0;
    hsync_out  <= 0;
    hblnk_out  <= 0;
    rgb_out    <= 0;
  end
  else begin
    state      <= state_nxt;
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
    addry      = vcount_in;
    addrx      = hcount_in;
    pixel_addr = {addry[7:0], addrx[7:0]};
    
    case (state)
        MENU: begin
            
                state_nxt = game_on ? GAME : MENU;
                
                if (victory_or_defeat || multiplayer)
                    rgb_nxt = rgb_in;
                else begin
                    if (hcount_in >= X_START_MENU && vcount_in >= Y_START_MENU && hcount_in <= (X_START_MENU + RECT_WIDTH) && vcount_in <= (Y_START_MENU + RECT_HEIGHT)) begin
                        rgb_nxt = rgb_pixel; 
                        addry = vcount_in - Y_START_MENU;
                        addrx = hcount_in - X_START_MENU;
                    end
                    else
                        rgb_nxt = rgb_in;
                    pixel_addr = {addry[7:0], addrx[7:0]};
                end
                
            end
        GAME: begin
        
                state_nxt = game_on ? GAME : MENU;
                
                if (hcount_in >= X_START_GAME && vcount_in >= Y_START_GAME && hcount_in <= (X_START_GAME + RECT_WIDTH) && vcount_in <= (Y_START_GAME + RECT_HEIGHT)) begin
                    rgb_nxt = rgb_pixel; 
                    addry = vcount_in - Y_START_GAME;
                    addrx = hcount_in - X_START_GAME;
                end
                else
                    rgb_nxt = rgb_in;
                pixel_addr = {addry[7:0], addrx[7:0]};

            end
    endcase


  end

endmodule
