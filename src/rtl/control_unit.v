`timescale 1 ns / 1 ps

module control_unit 
    #( parameter 
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

        output reg [2:0] state,
        output reg play_selected,
        output reg [2:0] mouse_mode,
        output reg display_buttons_m_and_s,
        output reg player_ready,
        output reg display_menu_button,
        output reg multiplayer
    );

reg [2:0] state_nxt; 
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
            
        end
                
        default begin
        
            state_nxt = state;
            display_menu_button_nxt = 1;
            
        end
     
    endcase     
end

endmodule