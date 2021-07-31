`timescale 1 ns / 1 ps
/*
 * PWJ: Added state machine for switching between menu background and game background.
 * Placing mouse on PLAY text in MENU_MODE will change its color to green, and pressing
 * left mouse button will change state to GAME_MODE. Pressing btnL button on board will chnge mode back to menu.
 * All of the letters are beeing drawn with big if elseif chunk of code.
 *
 *MO 27.06 added gameover state and behaviour (changed states to 2bit form 1bit)    
 *to go to menu from game over screen press left mouse button anywhere on the screen, to play 
 *the game again press PLAY button on gameover screen
 */
module draw_background 
    #( parameter
        TOP_V_LINE       = 317,
        BOTTOM_V_LINE    = 617,
        LEFT_H_LINE      = 361,
        RIGHT_H_LINE     = 661,
        BORDER           = 10
    )
    (
        input wire [11:0] vcount_in,
        input wire vsync_in,
        input wire vblnk_in,
        input wire [11:0] hcount_in,
        input wire hsync_in,
        input wire hblnk_in,
        input wire clk,
        input wire rst,
        input wire [2:0] control_state,
        
        output reg [11:0] vcount_out,
        output reg vsync_out,
        output reg vblnk_out,
        output reg [11:0] hcount_out,
        output reg hsync_out,
        output reg hblnk_out,
        output reg [11:0] rgb_out
    );
    
reg [11:0] rgb_nxt;
reg [11:0] vcount_nxt, hcount_nxt;
reg vsync_nxt, vblnk_nxt, hsync_nxt, hblnk_nxt;

localparam MENU_MODE    = 3'b000,
           GAME_MODE    = 3'b001,
           VICTORY_MODE = 3'b010,
           GAME_OVER    = 3'b011,
           MULTI_WAIT   = 3'b100;
           
always @(posedge clk) begin
    if (rst) begin
        hsync_out               <= 0;
        vsync_out               <= 0;
        hblnk_out               <= 0;
        vblnk_out               <= 0;
        hcount_out              <= 0;
        vcount_out              <= 0;
        rgb_out                 <= 0;
    end
    else begin
        hsync_out               <= hsync_nxt;
        vsync_out               <= vsync_nxt;
        hblnk_out               <= hblnk_nxt;
        vblnk_out               <= vblnk_nxt;
        hcount_out              <= hcount_nxt;
        vcount_out              <= vcount_nxt;
        rgb_out                 <= rgb_nxt;
    end 
end

always @* begin
    hsync_nxt                   = hsync_in;
    vsync_nxt                   = vsync_in;
    hblnk_nxt                   = hblnk_in;
    vblnk_nxt                   = vblnk_in;
    hcount_nxt                  = hcount_in;
    vcount_nxt                  = vcount_in;  
    
    case (control_state)
        MENU_MODE: begin
            
            // During blanking, make it it black.
            if (vblnk_in || hblnk_in) 
                rgb_nxt = 12'h0_0_0; 
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
                
                //circle test
                //else if (((hcount_in-100)*(hcount_in-100)/((10)*(10)) + (vcount_in-100)*(vcount_in-100)/((20)*(20)) >= 1 && (hcount_in-100)*(hcount_in-100)/((15)*(15)) + (vcount_in-100)*(vcount_in-100)/((25)*(25)) <= 6)) rgb_nxt = 12'h0_f_0;
                //^ by M.Karelus
                
                
                //else if (/* (hcount_in >= 200 &&*/ (hcount_in - 500)*(hcount_in - 500) + (vcount_in - 500)*(vcount_in - 500) < 10*10 /*&& (hcount_in - 200) + (vcount_in - 200)*(vcount_in - 200) >= 25*25)*/ ) rgb_nxt = 12'h0_0_f;
                //^by P.Kaczmarczyk
                
                else rgb_nxt = 12'h0_0_0;
            end  
              
        end
        
        GAME_MODE: begin

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
                      
        end
        
        VICTORY_MODE: begin
                 
            rgb_nxt = 12'h2_f_2;
            
        end

        GAME_OVER: begin  
   
            rgb_nxt = 12'hf_2_2;    
                    
        end
    
        //wait for 2nd player if multiplayer mode selected
        MULTI_WAIT: begin
        
            rgb_nxt = 12'h2_2_f;
            
        end
                
        default begin
        
            rgb_nxt = rgb_out;
            
        end
     
    endcase     
end

endmodule
