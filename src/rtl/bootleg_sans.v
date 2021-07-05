`timescale 1 ns / 1 ps

module draw_sans (
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

localparam IDLE = 0,
           DRAW = 1;

localparam RECT_WIDTH = 180;
localparam RECT_HEIGHT = 220;

localparam X_START = 425;
localparam Y_START = 30;

always @(posedge pclk) begin
  if (rst) begin
    state <= IDLE;
    vcount_out <= 0;
    vblnk_out <= 0;
    vsync_out <= 0;
    hcount_out <= 0;
    hsync_out <= 0;
    hblnk_out <= 0;
    rgb_out <= 0;
  end
  else begin
    state <= state_nxt;
    vcount_out <= vcount_nxt;
    vblnk_out <= vblnk_nxt;
    vsync_out <= vsync_nxt;
    hcount_out <= hcount_nxt;
    hsync_out <= hsync_nxt;
    hblnk_out <= hblnk_nxt;
    rgb_out <= rgb_nxt;
  end
end

always @* begin

    vcount_nxt = vcount_in;
    vblnk_nxt = vblnk_in;
    vsync_nxt = vsync_in;
    hcount_nxt = hcount_in;
    hsync_nxt = hsync_in;
    hblnk_nxt = hblnk_in;
    
    case (state)
        IDLE:
            begin
                state_nxt = game_on ? DRAW : IDLE;
                rgb_nxt = rgb_in;
            end
        DRAW:
            begin
                state_nxt = game_on ? DRAW : IDLE;
                if (hcount_in >= X_START && vcount_in >= Y_START && hcount_in <= (X_START + RECT_WIDTH) && vcount_in <= (Y_START + RECT_HEIGHT)) begin
                    rgb_nxt = rgb_pixel; 
                    addry = vcount_in - Y_START;
                    addrx = hcount_in - X_START;
                end
                else
                    rgb_nxt = rgb_in;
                pixel_addr = {addry[7:0], addrx[7:0]};

            end
    endcase


  
  end

endmodule
