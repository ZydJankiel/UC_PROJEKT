`timescale 1 ns / 1 ps
/*
 * PWJ: Added state machine for switching between menu background and game background.
 * Pressing btnL button on board will chnge mode back to menu.
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
           
localparam TOPBORDER = 100,
           BOTBORDER = 300;
           
always @(posedge clk) begin
    if (rst) begin
        hsync_out  <= 0;
        vsync_out  <= 0;
        hblnk_out  <= 0;
        vblnk_out  <= 0;
        hcount_out <= 0;
        vcount_out <= 0;
        rgb_out    <= 0;
    end
    else begin
        hsync_out  <= hsync_nxt;
        vsync_out  <= vsync_nxt;
        hblnk_out  <= hblnk_nxt;
        vblnk_out  <= vblnk_nxt;
        hcount_out <= hcount_nxt;
        vcount_out <= vcount_nxt;
        rgb_out    <= rgb_nxt;
    end 
end

always @* begin
    hsync_nxt                   = hsync_in;
    vsync_nxt                   = vsync_in;
    hblnk_nxt                   = hblnk_in;
    vblnk_nxt                   = vblnk_in;
    hcount_nxt                  = hcount_in;
    vcount_nxt                  = vcount_in;  
    rgb_nxt                     = 12'h3_f_0;
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
                
                //M 
                //verticals
                else if ((hcount_in >= 170 && hcount_in <= 210 && vcount_in >= 90 && vcount_in <= 250) ||       // left
                (hcount_in >= 330 && hcount_in <= 370 && vcount_in >= 90 && vcount_in <= 250) ||                //right
                //diagonals
                (hcount_in >= 170 && hcount_in <= 270 && vcount_in >= 90 && vcount_in <= 250 && hcount_in-vcount_in >= 80 && hcount_in-vcount_in <= 120 ) ||    // "\"
                (hcount_in >= 270 && hcount_in <= 370 && vcount_in >= 90 && vcount_in <= 250 && hcount_in + vcount_in >= 420 && hcount_in + vcount_in <= 460))  // "/"
                    rgb_nxt <= 12'hf_f_f;
                //E
                else if ((hcount_in >= 410 && hcount_in <= 450 && vcount_in >= 90 && vcount_in <= 250) ||         // vertical
                (hcount_in >= 450 && hcount_in <= 510 && vcount_in >= 90 && vcount_in <= 120) ||                  //top "-"
                (hcount_in >= 450 && hcount_in <= 510 && vcount_in >= 155 && vcount_in <= 185) ||                 //mid "-"
                (hcount_in >= 450 && hcount_in <= 510 && vcount_in >= 220 && vcount_in <= 250))                   //bot "-"
                    rgb_nxt = 12'hf_f_f;
                //N
                //verticals
                else if ((hcount_in >= 550 && hcount_in <= 590 && vcount_in >= 90 && vcount_in <= 250) ||       // left
                (hcount_in >= 670 && hcount_in <= 710 && vcount_in >= 90 && vcount_in <= 250) ||                //right
                //diagonals
                (hcount_in >= 550 && hcount_in <= 710 && vcount_in >= 90 && vcount_in <= 250 && ((4*hcount_in)/3)-vcount_in >= 643 && ((4*hcount_in)/3)-vcount_in <= 697 ))    // "\"
                    rgb_nxt <= 12'hf_f_f;
                //U
                // straights
                else if ((hcount_in >= 750 && hcount_in <= 790 && vcount_in >= 90 && vcount_in <= 210)||    //left
                (hcount_in >= 870 && hcount_in <= 910 && vcount_in >= 90 && vcount_in <= 210) ||            //right
                (hcount_in >= 790 && hcount_in <= 870 && vcount_in >= 210 && vcount_in <= 250) ||         //bottom floor 
                // diagonals
                (hcount_in >= 750 && hcount_in <= 830 && vcount_in >= 90 && vcount_in <= 250 && hcount_in-vcount_in >= 540 && hcount_in-vcount_in <= 600) ||        //"\"
                (hcount_in >= 830 && hcount_in <= 910 && vcount_in >= 90 && vcount_in <= 250 && hcount_in + vcount_in >= 1060 && hcount_in + vcount_in <= 1120) )   //"/"
                    rgb_nxt <= 12'hf_f_f;

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
           
            // V
            if ((hcount_in >= 56 && hcount_in <= 176 && vcount_in >= 100 && vcount_in <= 300 && (3*hcount_in)-vcount_in >=70 && (3*hcount_in)-vcount_in <=100) ||
                (hcount_in >= 56 && hcount_in <= 200 && vcount_in >= 100 && vcount_in <= 300 && (3*hcount_in)+vcount_in >=666 && (3*hcount_in)+vcount_in <=696)) rgb_nxt = 12'hf_f_f;
            // I    
            else if ((hcount_in >= 224 && hcount_in <= 232 && vcount_in >= TOPBORDER && vcount_in <= BOTBORDER)) rgb_nxt = 12'hf_f_f;
            // C
            else if ((hcount_in >= 320 && hcount_in <= 380 && vcount_in >= TOPBORDER && vcount_in <= TOPBORDER + 8 ) ||
                (hcount_in >= 260 && hcount_in <= 380 && vcount_in >= 100 && vcount_in <= 300 && hcount_in + vcount_in >= 418 && hcount_in + vcount_in <=428) ||
                (hcount_in >= 260 && hcount_in <= 268 && vcount_in >= 160 && vcount_in <= 240) || 
                (hcount_in >= 260 && hcount_in <= 380 && vcount_in >= 100 && vcount_in <= 300 && hcount_in - vcount_in >= 18 && hcount_in - vcount_in <=28) ||
                (hcount_in >= 320 && hcount_in <= 380 && vcount_in >= BOTBORDER - 8 && vcount_in <= BOTBORDER )) rgb_nxt = 12'hf_f_f; 
            // T
            else if ((hcount_in >= 458 && hcount_in <= 466 && vcount_in >= TOPBORDER && vcount_in < BOTBORDER) ||
                (hcount_in >= 412 && hcount_in < 532 && vcount_in >= TOPBORDER && vcount_in <= TOPBORDER + 8)) rgb_nxt = 12'hf_f_f;   
            // O
            else if ((hcount_in >= 584 && hcount_in <= 644 && vcount_in >= TOPBORDER && vcount_in <= TOPBORDER + 8 ) ||
                (hcount_in >= 554 && hcount_in <= 562 && vcount_in >= 175 && vcount_in <= 235 ) ||
                (hcount_in >= 584 && hcount_in <= 644 && vcount_in >= BOTBORDER - 8 && vcount_in <= BOTBORDER ) ||
                (hcount_in >= 666 && hcount_in <= 674 && vcount_in >= 175 && vcount_in <= 232 ) ||
                (hcount_in >= 554 && hcount_in <= 674 && vcount_in >= 100 && vcount_in <= 300 && (3*hcount_in) - vcount_in >= 1825 && (3*hcount_in) - vcount_in <= 1855) ||
                (hcount_in >= 554 && hcount_in <= 674 && vcount_in >= 100 && vcount_in <= 300 && (3*hcount_in) + vcount_in >= 1832 && (3*hcount_in) + vcount_in <= 1862) ||
                (hcount_in >= 554 && hcount_in <= 674 && vcount_in >= 100 && vcount_in <= 300 && (3*hcount_in) - vcount_in >= 1429 && (3*hcount_in) - vcount_in <= 1459) ||
                (hcount_in >= 554 && hcount_in <= 674 && vcount_in >= 100 && vcount_in <= 300 && (3*hcount_in) + vcount_in >= 2225 && (3*hcount_in) + vcount_in <= 2255)) rgb_nxt = 12'hf_f_f;
            // R
            else if (( hcount_in >= 716 && hcount_in <= 724 && vcount_in >= TOPBORDER && vcount_in <= BOTBORDER ) ||
                (hcount_in >= 716 && hcount_in <= 806 && vcount_in >= TOPBORDER && vcount_in <= TOPBORDER +8) ||
                (hcount_in >= 828 && hcount_in <= 836 && vcount_in >= 130 && vcount_in <= 170) ||
                (hcount_in >= 716 && hcount_in <= 806 && vcount_in >= 190 && vcount_in <= 198) || 
                (hcount_in >= 716 && hcount_in <= 836 && vcount_in >= 100 && vcount_in <= 300 && hcount_in - vcount_in >= 696 && hcount_in - vcount_in <=706) || 
                (hcount_in >= 716 && hcount_in <= 836 && vcount_in >= 100 && vcount_in <= 198 && hcount_in + vcount_in >= 996 && hcount_in + vcount_in <=1006) ||
                (hcount_in >= 716 && hcount_in <= 836 && vcount_in >= 100 && vcount_in <= 300 && hcount_in - vcount_in >= 520 && hcount_in - vcount_in <=530)) rgb_nxt = 12'hf_f_f;
            // Y
            else if ((hcount_in >= 848 && hcount_in <= 968 && vcount_in >= 100 && vcount_in <= 225 && (3*hcount_in)-vcount_in >= 2476 && (3*hcount_in)-vcount_in <=2506) ||
                (hcount_in >= 848 && hcount_in <= 968 && vcount_in >= 100 && vcount_in <= 225 && (3*hcount_in)+vcount_in >=2938 && (3*hcount_in)+vcount_in <=2968) || 
                (hcount_in >= 902 && hcount_in < 914 && vcount_in >= 225 && vcount_in < BOTBORDER)) rgb_nxt = 12'hf_f_f;                
            
            else rgb_nxt = 12'h2_f_2;
            
        end

        GAME_OVER: begin  
        
            // D
            if ((hcount_in >= 66 && hcount_in <= 126 && vcount_in >= TOPBORDER && vcount_in <= TOPBORDER + 8 ) ||
                (hcount_in >= 66 && hcount_in <= 74 && vcount_in >= TOPBORDER && vcount_in <= BOTBORDER) ||
                (hcount_in >= 66 && hcount_in <= 186 && vcount_in >= 100 && vcount_in <= 300 && hcount_in + vcount_in >= 416 && hcount_in + vcount_in <=426) ||
                (hcount_in >= 178 && hcount_in <= 186 && vcount_in >= 160 && vcount_in <= 240) || 
                (hcount_in >= 66 && hcount_in <= 186 && vcount_in >= 100 && vcount_in <= 300 && hcount_in - vcount_in >= 16 && hcount_in - vcount_in <=26) ||
                (hcount_in >= 66 && hcount_in <= 126 && vcount_in >= BOTBORDER - 8 && vcount_in <= BOTBORDER )) rgb_nxt = 12'hf_f_f; 
            // E
            else if((hcount_in >= 220 && hcount_in <= 228 && vcount_in >= TOPBORDER && vcount_in <= BOTBORDER) ||
                (hcount_in >= 220 && hcount_in <= 340 && vcount_in >= TOPBORDER && vcount_in <= TOPBORDER + 8) ||
                (hcount_in >= 220 && hcount_in <= 340 && vcount_in >= 194 && vcount_in <= 204) ||
                (hcount_in >= 220 && hcount_in <= 340 && vcount_in >= BOTBORDER - 8 && vcount_in <= BOTBORDER)) rgb_nxt = 12'hf_f_f;
            // F    
            else if((hcount_in >= 374 && hcount_in <= 382 && vcount_in >= TOPBORDER && vcount_in <= BOTBORDER) ||
                (hcount_in >= 374 && hcount_in <= 494 && vcount_in >= TOPBORDER && vcount_in <= TOPBORDER + 8) ||
                (hcount_in >= 374 && hcount_in <= 494 && vcount_in >= 194 && vcount_in <= 204)) rgb_nxt = 12'hf_f_f;
            //E    
            else if((hcount_in >= 528 && hcount_in <= 536 && vcount_in >= TOPBORDER && vcount_in <= BOTBORDER) ||
                (hcount_in >= 528 && hcount_in <= 648 && vcount_in >= TOPBORDER && vcount_in <= TOPBORDER + 8) ||
                (hcount_in >= 528 && hcount_in <= 648 && vcount_in >= 194 && vcount_in <= 204) ||
                (hcount_in >= 528 && hcount_in <= 648 && vcount_in >= BOTBORDER - 8 && vcount_in <= BOTBORDER)) rgb_nxt = 12'hf_f_f;
            // A   
            else if ((hcount_in >= 0 && hcount_in <= 1024 && vcount_in >= 100 && vcount_in <= 300 && (3*hcount_in)-vcount_in >=2126 && (3*hcount_in)-vcount_in <=2156) ||
                (hcount_in >= 0 && hcount_in <= 1024 && vcount_in >= 100 && vcount_in <= 300 && (3*hcount_in)+vcount_in >=2316 && (3*hcount_in)+vcount_in <=2346) ||
                (hcount_in >= 715 && hcount_in <= 777 && vcount_in >= 194 && vcount_in <= 204)) rgb_nxt = 12'hf_f_f; 
            // T
            else if ((hcount_in >= 892 && hcount_in < 900 && vcount_in >= TOPBORDER && vcount_in <= BOTBORDER) ||
                (hcount_in >= 836 && hcount_in < 956 && vcount_in >= TOPBORDER && vcount_in <= TOPBORDER + 8)) rgb_nxt = 12'hf_f_f;
            
            else rgb_nxt = 12'hf_2_2;    
                    
        end
    
        //wait for 2nd player if multiplayer mode selected
        MULTI_WAIT: begin
      
            // W
            if ((hcount_in >= 66 && hcount_in <= 266 && vcount_in >= 100 && vcount_in <= 300 && (4*hcount_in)-vcount_in >=264 && (4*hcount_in)-vcount_in <=304) ||
                (hcount_in >= 66 && hcount_in <= 266 && vcount_in >= 100 && vcount_in <= 300 && (4*hcount_in)+vcount_in >=864 && (4*hcount_in)+vcount_in <=904) || 
                (hcount_in >= 66 && hcount_in <= 266 && vcount_in >= 100 && vcount_in <= 300 && (4*hcount_in)-vcount_in >=664 && (4*hcount_in)-vcount_in <=704) ||
                (hcount_in >= 66 && hcount_in <= 300 && vcount_in >= 100 && vcount_in <= 300 && (4*hcount_in)+vcount_in >=1264 && (4*hcount_in)+vcount_in <=1304) ) rgb_nxt = 12'hf_f_f;
            // A
            else if ((hcount_in >= 0 && hcount_in <= 1000 && vcount_in >= 100 && vcount_in <= 300 && (2*hcount_in)-vcount_in >=786 && (2*hcount_in)-vcount_in <= 806) ||
                (hcount_in >= 0 && hcount_in <= 1000 && vcount_in >= 100 && vcount_in <= 300 && (2*hcount_in)+vcount_in >=986 && (2*hcount_in)+vcount_in <=1006) ||
                (hcount_in >= 396 && hcount_in <= 500 && vcount_in >= 196 && vcount_in <= 204)) rgb_nxt = 12'hf_f_f;
            // I 
            else if (hcount_in >= 626 && hcount_in <= 634 && vcount_in >= TOPBORDER && vcount_in <= BOTBORDER) rgb_nxt = 12'hf_f_f;            
            // T
            else if ((hcount_in >= 818 && hcount_in < 826 && vcount_in >= TOPBORDER && vcount_in <= BOTBORDER) ||
                (hcount_in >= 712 && hcount_in < 912 && vcount_in >= TOPBORDER && vcount_in <= TOPBORDER + 8)) rgb_nxt = 12'hf_f_f;
                
            else rgb_nxt = 12'h2_2_f;
            
        end
                
        default begin
        
            rgb_nxt = rgb_out;
            
        end
     
    endcase     
end

endmodule
