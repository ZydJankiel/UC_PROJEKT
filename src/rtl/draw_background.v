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
        BORDER           = 10,
        
        PLAY_BOX_X_POS   = 432,
        PLAY_BOX_Y_POS   = 400,
        PLAY_BOX_Y_SIZE  = 80,
        PLAY_BOX_X_SIZE  = 128,
        
        MULTI_BOX_X_POS  = 432,
        MULTI_BOX_Y_POS  = 540,
        MULTI_BOX_Y_SIZE = 80,
        MULTI_BOX_X_SIZE = 128,
        
        MENU_BOX_X_POS   = 432,
        MENU_BOX_Y_POS   = 520,
        MENU_BOX_Y_SIZE  = 80,
        MENU_BOX_X_SIZE  = 128
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
        input wire game_on,
        input wire menu_on,
        input wire game_over,
        input wire victory,
        input wire [11:0] xpos,
        input wire [11:0] ypos,
        input wire mouse_left,
        input wire opponent_ready,
        
        output reg [11:0] vcount_out,
        output reg vsync_out,
        output reg vblnk_out,
        output reg [11:0] hcount_out,
        output reg hsync_out,
        output reg hblnk_out,
        output reg [11:0] rgb_out,
        output reg play_selected,
        output reg [2:0] mouse_mode,
        output reg display_buttons_m_and_s,
        output reg player_ready,
        output reg display_menu_button,
        output reg multiplayer
    );
reg [11:0] rgb_nxt;
reg [11:0] vcount_nxt, hcount_nxt;
reg vsync_nxt, vblnk_nxt, hsync_nxt, hblnk_nxt;
reg [2:0] state, state_nxt; 
reg mouse_mode_nxt, play_selected_nxt, display_buttons_m_and_s_nxt, player_ready_nxt, display_menu_button_nxt;
reg multiplayer_nxt, multi_reg, multi_reg_nxt;

localparam MENU_MODE    = 3'b000,
           GAME_MODE    = 3'b001,
           VICTORY_MODE = 3'b010,
           GAME_OVER    = 3'b011,
           MULTI_WAIT   = 3'b100;
           
always @(posedge clk) begin
    if (rst) begin
        state <= MENU_MODE;
        hsync_out               <= 0;
        vsync_out               <= 0;
        hblnk_out               <= 0;
        vblnk_out               <= 0;
        hcount_out              <= 0;
        vcount_out              <= 0;
        rgb_out                 <= 0;
        mouse_mode              <= MENU_MODE; 
        play_selected           <= 0;
        display_buttons_m_and_s <= 0;  
        player_ready            <= 0;
        display_menu_button     <= 0;
        multiplayer             <= 0;
        multi_reg               <= 0;
    end
    else begin
        state                   <= state_nxt;
        hsync_out               <= hsync_nxt;
        vsync_out               <= vsync_nxt;
        hblnk_out               <= hblnk_nxt;
        vblnk_out               <= vblnk_nxt;
        hcount_out              <= hcount_nxt;
        vcount_out              <= vcount_nxt;
        rgb_out                 <= rgb_nxt;
        mouse_mode              <= mouse_mode_nxt;
        play_selected           <= play_selected_nxt;
        display_buttons_m_and_s <= display_buttons_m_and_s_nxt;
        player_ready            <= player_ready_nxt;
        display_menu_button     <= display_menu_button_nxt;
        multiplayer             <= multiplayer_nxt;
        multi_reg               <= multi_reg_nxt;
    end 
end

always @* begin
    hsync_nxt                   = hsync_in;
    vsync_nxt                   = vsync_in;
    hblnk_nxt                   = hblnk_in;
    vblnk_nxt                   = vblnk_in;
    hcount_nxt                  = hcount_in;
    vcount_nxt                  = vcount_in;  
    play_selected_nxt           = 0;  
    mouse_mode_nxt              = MENU_MODE;
    display_buttons_m_and_s_nxt = 0;
    player_ready_nxt            = 0;
    display_menu_button_nxt     = 0;
    multiplayer_nxt             = 0;
    multi_reg_nxt               = multi_reg;
    
    case (state)
        MENU_MODE: begin
        
            if (game_on) 
                state_nxt = GAME_MODE;   
            else if (xpos >= PLAY_BOX_X_POS - 10 && xpos <= PLAY_BOX_X_SIZE + PLAY_BOX_X_POS -5 && ypos >= PLAY_BOX_Y_POS - 10 && ypos <= PLAY_BOX_Y_SIZE + PLAY_BOX_Y_POS) begin
                if (mouse_left) begin
                    state_nxt = GAME_MODE;
                    multi_reg_nxt = 0;
                end
                else
                    state_nxt = MENU_MODE;
            end
            else if (xpos >= MULTI_BOX_X_POS - 10 && xpos <= MULTI_BOX_X_SIZE + MULTI_BOX_X_POS -5 && ypos >= MULTI_BOX_Y_POS - 10 && ypos <= MULTI_BOX_Y_SIZE + MULTI_BOX_Y_POS) begin
                if (mouse_left) begin
                    state_nxt = MULTI_WAIT;
                    multi_reg_nxt = 1;
                end
                else
                    state_nxt = MENU_MODE;
            end                 
            else if (game_over)
                state_nxt = GAME_OVER;
            else if (victory)
                state_nxt = VICTORY_MODE;
            else
                state_nxt = MENU_MODE;                
            
            display_buttons_m_and_s_nxt = 1;
            
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
                
                //triangle test
                  //downwards spike
                else if (hcount_in >= 120 && hcount_in <= 160 && vcount_in >= 300 && vcount_in <= 350 && ((3 * hcount_in) + vcount_in) <= 770 && ((3 * hcount_in) - vcount_in) >= 70)   
                //in last 2 comps - more in <= and less in >= makes triangle bigger , multiplying hcount gives bigger slope     
                    rgb_nxt = 12'h0_f_f;
                    /*
                else if (hcount_in >= 120 && hcount_in <= 160 && vcount_in >= 500 && vcount_in <= 550 && ((3 * hcount_in) + vcount_in) <= 970 && ((3 * hcount_in) - vcount_in) >= -130)
                    rgb_nxt = 12'h0_f_f;  
                else if (hcount_in >= 120 && hcount_in <= 160 && vcount_in >= 600 && vcount_in <= 650 && ((3 * hcount_in) + vcount_in) <= 1070 && ((3 * hcount_in) - vcount_in) >= -230)
                    rgb_nxt = 12'h0_f_f;  
                else if (hcount_in >= 420 && hcount_in <= 460 && vcount_in >= 300 && vcount_in <= 350 && ((3 * hcount_in) + vcount_in) <= 1670 && ((3 * hcount_in) - vcount_in) >= 970)
                    rgb_nxt = 12'hf_0_f;  
                else if (hcount_in >= 420 && hcount_in <= 460 && vcount_in >= 500 && vcount_in <= 550 && ((3 * hcount_in) + vcount_in) <= 1870 && ((3 * hcount_in) - vcount_in) >= 770)
                    rgb_nxt = 12'hf_0_f; 
                //to move spike downwards in <= add difference and in >= subtract
                //when moving spike sideways add (or subtract) to both <= and >= value of 3*x_difference     
                */
                //rightwards spike
                else if (hcount_in >= 361 && hcount_in <= 411 && vcount_in >= 300 && vcount_in <= 340 && (((3 * hcount_in)/10) + vcount_in) <= 440 && (((3 * hcount_in)/10) - vcount_in) <= -200)
                    rgb_nxt = 12'hf_0_f; 
                /*    
                else if (hcount_in >= 361 && hcount_in <= 411 && vcount_in >= 500 && vcount_in <= 540 && ((3 * hcount_in)/10 + vcount_in) <= 640 && ((3 * hcount_in)/10 - vcount_in) <= -400)
                    rgb_nxt = 12'hf_0_f; 
                else if (hcount_in >= 561 && hcount_in <= 611 && vcount_in >= 500 && vcount_in <= 540 && ((3 * hcount_in)/10 + vcount_in) <= 700 && ((3 * hcount_in)/10 - vcount_in) <= -340)
                    rgb_nxt = 12'hf_0_f; 
                //to move down add to 1st comparison and subtarct from 2nd
                // to move right add to both comparisons 0,3*x_difference
                */
                //leftwardsspike    
                else if (hcount_in >= 611 && hcount_in <= 661 && vcount_in >= 300 && vcount_in <= 340 && (((3 * hcount_in)/10) + vcount_in) >= 505 && (((3 * hcount_in)/10) - vcount_in) >= -135)
                    rgb_nxt = 12'hf_f_0;
                    /*
                else if (hcount_in >= 611 && hcount_in <= 661 && vcount_in >= 400 && vcount_in <= 440 && (((3 * hcount_in)/10) + vcount_in) >= 605 && (((3 * hcount_in)/10) - vcount_in) >= -235)
                    rgb_nxt = 12'hf_f_0;
                else if (hcount_in >= 361 && hcount_in <= 411 && vcount_in >= 400 && vcount_in <= 440 && (((3 * hcount_in)/10) + vcount_in) >= 530 && (((3 * hcount_in)/10) - vcount_in) >= -310)
                        rgb_nxt = 12'hf_f_0;                
                //to move down add to 1st comparison and subtract in 2nd comparison  
                //to move left subtract from both comparisions 0,3*x_difference
                */
                //upwards spike
                else if (hcount_in >= 400 && hcount_in <= 440 && vcount_in >= 567 && vcount_in <= 617 && ((3 * hcount_in) + vcount_in) >= 1830 && ((3 * hcount_in) - vcount_in) <= 690)   
                    rgb_nxt = 12'hf_0_0;
                    /*
                else if (hcount_in >= 400 && hcount_in <= 440 && vcount_in >= 317 && vcount_in <= 367 && ((3 * hcount_in) + vcount_in) >= 1580 && ((3 * hcount_in) - vcount_in) <= 940)   
                    rgb_nxt = 12'hf_0_0;
                else if (hcount_in >= 300 && hcount_in <= 340 && vcount_in >= 567 && vcount_in <= 617 && ((3 * hcount_in) + vcount_in) >= 1530 && ((3 * hcount_in) - vcount_in) <= 390)   
                    rgb_nxt = 12'hf_0_0;
                //to move spike downwards in <= subtract difference and in >= add
                //when moving spike sideways add (or subtract) to both <= and >= value of 3*x_difference 
                */  
                else rgb_nxt = 12'h0_0_0;
            end  
              
        end
        
        GAME_MODE: begin
        
            if (multi_reg)
                multiplayer_nxt = 1;
            else
                multiplayer_nxt = 0;
                
            if (menu_on) 
                state_nxt = MENU_MODE;
            else if (game_over)
                state_nxt = GAME_OVER;
            else if (victory)
                state_nxt = VICTORY_MODE;
            else
                state_nxt = GAME_MODE;
            
            play_selected_nxt = 1;
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
                      
        end
        
        VICTORY_MODE: begin
        
            if (game_on) 
                state_nxt = GAME_MODE;
            else if (menu_on)
                state_nxt = MENU_MODE;
            else if (xpos >= PLAY_BOX_X_POS - 10 && xpos <= PLAY_BOX_X_SIZE + PLAY_BOX_X_POS -5 && ypos >= PLAY_BOX_Y_POS - 10 && ypos <= PLAY_BOX_Y_SIZE + PLAY_BOX_Y_POS) begin
                if (mouse_left) begin
                    state_nxt = GAME_MODE;
                    multi_reg_nxt = 0;
                end
                else
                    state_nxt = VICTORY_MODE;
            end
            else if (xpos >= MULTI_BOX_X_POS - 10 && xpos <= MULTI_BOX_X_SIZE + MULTI_BOX_X_POS -5 && ypos >= MULTI_BOX_Y_POS - 10 && ypos <= MULTI_BOX_Y_SIZE + MULTI_BOX_Y_POS) begin
                if (mouse_left) begin
                    state_nxt = MULTI_WAIT;
                    multi_reg_nxt = 1;
                end
                else
                    state_nxt = VICTORY_MODE;
            end           
            else if (mouse_left)
                state_nxt = MENU_MODE;
            else
                state_nxt = VICTORY_MODE; 
            
            display_buttons_m_and_s_nxt = 1;           
            rgb_nxt = 12'h2_f_2;
            
        end
        
        //to go to menu from game over screen press left mouse button anywhere on the screen,  
        //to play the game again press PLAY button on gameover screen
        GAME_OVER: begin  
                 
            if (game_on) 
                state_nxt = GAME_MODE;
            else if (menu_on)
                    state_nxt = MENU_MODE;
            else if (xpos >= PLAY_BOX_X_POS - 10 && xpos <= PLAY_BOX_X_SIZE + PLAY_BOX_X_POS -5 && ypos >= PLAY_BOX_Y_POS - 10 && ypos <= PLAY_BOX_Y_SIZE + PLAY_BOX_Y_POS) begin
                if (mouse_left) begin
                    state_nxt = GAME_MODE;
                    multi_reg_nxt = 0;
                end
                else
                    state_nxt = GAME_OVER;
            end
            else if (xpos >= MULTI_BOX_X_POS - 10 && xpos <= MULTI_BOX_X_SIZE + MULTI_BOX_X_POS -5 && ypos >= MULTI_BOX_Y_POS - 10 && ypos <= MULTI_BOX_Y_SIZE + MULTI_BOX_Y_POS) begin
                if (mouse_left) begin
                    state_nxt = MULTI_WAIT;
                    multi_reg_nxt = 1;
                end
                else
                    state_nxt = GAME_OVER;
            end                    
            else if (mouse_left)
                state_nxt = MENU_MODE;
            else
                state_nxt = GAME_OVER; 
            
            display_buttons_m_and_s_nxt = 1;    
            rgb_nxt = 12'hf_2_2;    
                    
        end
    
        //wait for 2nd player if multiplayer mode selected
        MULTI_WAIT: begin
        
            if (opponent_ready)
                state_nxt = GAME_MODE;
            else if (xpos >= MENU_BOX_X_POS - 10 && xpos <= MENU_BOX_X_SIZE + MENU_BOX_X_POS -5 && ypos >= MENU_BOX_Y_POS - 10 && ypos <= MENU_BOX_Y_SIZE + MENU_BOX_Y_POS) begin
                if (mouse_left)
                    state_nxt = MENU_MODE;
                else
                    state_nxt = MULTI_WAIT;
            end
            else
                state_nxt = MULTI_WAIT;
                
            multiplayer_nxt = 1;
            player_ready_nxt = 1;
            display_menu_button_nxt = 1;
            rgb_nxt = 12'h2_2_f;
            
        end
                
        default begin
        
            state_nxt = state;
            rgb_nxt = rgb_out;
            display_menu_button_nxt = 1;
            
        end
     
    endcase     
end

endmodule
