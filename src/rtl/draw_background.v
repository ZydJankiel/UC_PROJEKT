`timescale 1 ns / 1 ps
/*
 * PWJ: Added state machine for switching between menu background and game background.
 * Placing mouse on PLAY text in MENU_MODE will change its color to green, and pressing
 * left mouse button will change state to GAME_MODE. Pressing btnL button on board will chnge mode back to menu.
 * All of the letters are beeing drawn with big if elseif chunk of code.
 */
module draw_background 
    #( parameter
    TOP_V_LINE     = 317,
    BOTTOM_V_LINE  = 617,
    LEFT_H_LINE    = 361,
    RIGHT_H_LINE   = 661,
    BORDER = 10
  )
  (
  input wire [11:0] vcount_in,
  input wire vsync_in,
  input wire vblnk_in,
  input wire [11:0] hcount_in,
  input wire hsync_in,
  input wire hblnk_in,
  input wire pclk,
  input wire rst,
  input wire game_on,
  input wire menu_on,
  input wire [11:0] xpos,
  input wire [11:0] ypos,
  input wire mouse_left,

  output reg [11:0] vcount_out,
  output reg vsync_out,
  output reg vblnk_out,
  output reg [11:0] hcount_out,
  output reg hsync_out,
  output reg hblnk_out,
  output reg [11:0] rgb_out,
  output reg play_selected,
  output reg mouse_mode,
  
  //THIS IS ONLY FOR TESTING
  output reg [3:0] obstacle_mux_select
  //
  );
reg [11:0] rgb_nxt;
reg [11:0] vcount_nxt, hcount_nxt;
reg vsync_nxt, vblnk_nxt, hsync_nxt, hblnk_nxt;
reg state, state_nxt, mouse_mode_nxt, play_selected_nxt;

  //THIS IS ONLY FOR TESTING
reg [3:0] obstacle_mux_select_nxt;
  //

localparam MENU_MODE = 1'b0,
           GAME_MODE = 1'b1;

  always @(posedge pclk) begin
      if (rst) begin
          state <= MENU_MODE;
          hsync_out <= 0;
          vsync_out <= 0;
          hblnk_out <= 0;
          vblnk_out <= 0;
          hcount_out <= 0;
          vcount_out <= 0;
          rgb_out <= 0;
          mouse_mode <= MENU_MODE; 
          play_selected <= 0;  
          
          //THIS IS ONLY FOR TESTING
          obstacle_mux_select <= 0;
          // 
      end
      else begin
          state <= state_nxt;
          hsync_out <= hsync_nxt;
          vsync_out <= vsync_nxt;
          hblnk_out <= hblnk_nxt;
          vblnk_out <= vblnk_nxt;
          hcount_out <= hcount_nxt;
          vcount_out <= vcount_nxt;
          rgb_out <= rgb_nxt;
          mouse_mode <= mouse_mode_nxt;
          play_selected <= play_selected_nxt;
          //THIS IS ONLY FOR TESTING
          obstacle_mux_select <= obstacle_mux_select_nxt;
          // 
      end
  end
  
  always @* begin
    hsync_nxt = hsync_in;
    vsync_nxt = vsync_in;
    hblnk_nxt = hblnk_in;
    vblnk_nxt = vblnk_in;
    hcount_nxt = hcount_in;
    vcount_nxt = vcount_in;  
    play_selected_nxt = 0;  
    //THIS IS ONLY FOR TESTING
    obstacle_mux_select_nxt = 0;
    //
    case (state)
        MENU_MODE: begin
            state_nxt = game_on ? GAME_MODE : MENU_MODE;
            mouse_mode_nxt = MENU_MODE;
               // During blanking, make it it black.
            if (vblnk_in || hblnk_in) rgb_nxt = 12'h0_0_0; 
            else begin
                 // Active display, top edge, make a yellow line.
                if (vcount_in == 0) rgb_nxt = 12'hf_f_0;
                // Active display, bottom edge, make a red line.
                else if (vcount_in == 767) rgb_nxt = 12'hf_0_0;
                // Active display, left edge, make a green line.
                else if (hcount_in == 0) rgb_nxt = 12'h0_f_0;
                // Active display, right edge, make a blue line.
                else if (hcount_in == 1023) rgb_nxt = 12'h0_0_f;
                // M
                else if ((hcount_in > 170 && hcount_in <= 210 && vcount_in > 90 && vcount_in <= 250) ||
                (hcount_in > 170 && hcount_in <= 370 && vcount_in > 50 && vcount_in <= 90) ||
                (hcount_in > 250 && hcount_in <= 290 && vcount_in > 90 && vcount_in <= 250) ||
                (hcount_in > 330 && hcount_in <= 370 && vcount_in > 90 && vcount_in <= 250))  rgb_nxt = 12'hf_f_f;
                //E
                else if ((hcount_in > 420 && hcount_in <= 460 && vcount_in > 50 && vcount_in <= 250) ||
                (hcount_in > 460 && hcount_in <= 500 && vcount_in > 50 && vcount_in <= 90) ||
                (hcount_in > 460 && hcount_in <= 500 && vcount_in > 130 && vcount_in <= 170) ||
                (hcount_in > 460 && hcount_in <= 500 && vcount_in > 210 && vcount_in <= 250))  rgb_nxt = 12'hf_f_f;
                //N
                else if ((hcount_in > 550 && hcount_in <= 590 && vcount_in > 90 && vcount_in <= 250) ||
                (hcount_in > 550 && hcount_in <= 670 && vcount_in > 50 && vcount_in <= 90) ||
                (hcount_in > 630 && hcount_in <= 670 && vcount_in > 90 && vcount_in <= 250))  rgb_nxt = 12'hf_f_f;
                //U
                else if ((hcount_in > 720 && hcount_in <= 760 && vcount_in > 50 && vcount_in <= 210) ||
                (hcount_in > 720 && hcount_in <= 840 && vcount_in > 210 && vcount_in <= 250) ||
                (hcount_in > 800 && hcount_in <= 840 && vcount_in > 50 && vcount_in <= 210)) rgb_nxt = 12'hf_f_f;
      
                // P
                else if ((hcount_in > 400 && hcount_in <= 420 && vcount_in > 400 && vcount_in <= 480) ||
                (hcount_in > 420 && hcount_in <= 450 && vcount_in > 400 && vcount_in <= 410) ||
                (hcount_in > 440 && hcount_in <= 450 && vcount_in > 400 && vcount_in <= 440) ||
                (hcount_in > 420 && hcount_in <= 450 && vcount_in > 430 && vcount_in <= 440) ||
                //L
                (hcount_in > 480 && hcount_in <= 500 && vcount_in > 400 && vcount_in <= 480) ||
                (hcount_in > 500 && hcount_in <= 530 && vcount_in > 460 && vcount_in <= 480) ||
                //A
                (hcount_in > 560 && hcount_in <= 610 && vcount_in > 400 && vcount_in <= 420) ||
                (hcount_in > 560 && hcount_in <= 580 && vcount_in > 400 && vcount_in <= 480) ||
                (hcount_in > 590 && hcount_in <= 610 && vcount_in > 400 && vcount_in <= 480) ||
                (hcount_in > 580 && hcount_in <= 590 && vcount_in > 440 && vcount_in <= 460) ||
                //Y
                (hcount_in > 640 && hcount_in <= 660 && vcount_in > 400 && vcount_in <= 420) ||
                (hcount_in > 670 && hcount_in <= 690 && vcount_in > 400 && vcount_in <= 420) ||
                (hcount_in > 640 && hcount_in <= 690 && vcount_in > 420 && vcount_in <= 440) ||
                (hcount_in > 655 && hcount_in <= 675 && vcount_in > 440 && vcount_in <= 480)) begin
                    if (xpos > 384 && xpos <= 690 && ypos > 384 && ypos <= 480) begin
                        rgb_nxt = 12'h0_f_0;
                        if (mouse_left) begin
                            state_nxt = GAME_MODE;
                            play_selected_nxt = 1;
                        end
                    end
                    else
                        rgb_nxt = 12'hf_f_f;
                end
                else rgb_nxt = 12'h0_0_0;
             end
             
        end
        GAME_MODE: begin
            //THIS IS ONLY FOR TESTING
            obstacle_mux_select_nxt = 4'b0001;
            //
            mouse_mode_nxt = GAME_MODE;
                           // During blanking, make it it black.
            if (vblnk_in || hblnk_in) rgb_nxt = 12'h0_0_0; 
            else begin
                 // Active display, top edge, make a yellow line.
                if (vcount_in == 0) rgb_nxt = 12'hf_f_0;
                // Active display, bottom edge, make a red line.
                else if (vcount_in == 767) rgb_nxt = 12'hf_0_0;
                // Active display, left edge, make a green line.
                else if (hcount_in == 0) rgb_nxt = 12'h0_f_0;
                // Active display, right edge, make a blue line.
                else if (hcount_in == 1023) rgb_nxt = 12'h0_0_f;
                // GAME BOUNDARY
                else if ((hcount_in >= LEFT_H_LINE - BORDER && hcount_in < LEFT_H_LINE && vcount_in >= TOP_V_LINE - BORDER && vcount_in < BOTTOM_V_LINE + BORDER) || 
                (hcount_in >= LEFT_H_LINE && hcount_in < RIGHT_H_LINE && vcount_in >= TOP_V_LINE - BORDER && vcount_in < TOP_V_LINE ) || 
                (hcount_in >= LEFT_H_LINE && hcount_in < RIGHT_H_LINE && vcount_in >= BOTTOM_V_LINE && vcount_in < BOTTOM_V_LINE + BORDER) || 
                (hcount_in >= RIGHT_H_LINE  && hcount_in < RIGHT_H_LINE + BORDER && vcount_in >= TOP_V_LINE - BORDER && vcount_in < BOTTOM_V_LINE + BORDER) ) rgb_nxt = 12'hf_f_f;        
                else rgb_nxt = 12'h0_0_0;
            end
            state_nxt = menu_on ? MENU_MODE : GAME_MODE;
        end
    endcase     
  end

endmodule
