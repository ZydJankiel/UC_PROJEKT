`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.06.2021 12:59:10
// Design Name: 
// Module Name: hp_control
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
* MO - created module to control players HP, 
* despite having parameter to set maxHP/ maxDMG module is set work properlywith 5 states of HP 
* ( each state is 60 pixels wide), for testing player_hit is connected to T17 button
*
* 27.06 changed dmg and state logic in state GAME to take into accoount behaviour after death, now 
* health resets after death and after exiting to menu
*/

module hp_control #( parameter
    TOP_V_LINE     = 367,
    BOTTOM_V_LINE  = 667,
    LEFT_H_LINE    = 361,
    RIGHT_H_LINE   = 661,
    BORDER         = 10,
    MAX_DMG_TAKEN  = 5
    )
    (
    input wire [11:0] rgb_in_hp,
    input wire [11:0] vcount_in_hp,
    input wire vsync_in_hp,
    input wire vblnk_in_hp,
    input wire [11:0] hcount_in_hp,
    input wire hsync_in_hp,
    input wire hblnk_in_hp,
    input wire pclk,
    input wire rst,
    input wire game_on_hp,
    input wire player_hit, //input for future uses to signal control unit that players has taken dmg, currently T17 button
    
    output reg [11:0] vcount_out_hp,
    output reg vsync_out_hp,
    output reg vblnk_out_hp,
    output reg [11:0] hcount_out_hp,
    output reg hsync_out_hp,
    output reg hblnk_out_hp,
    output reg [11:0] rgb_out_hp,
    output reg game_over
    );

localparam TOP_HP = BOTTOM_V_LINE + BORDER + 60,
           BOTTOM_HP = BOTTOM_V_LINE + BORDER + 110,
           LEFT_HP = LEFT_H_LINE,
           RIGHT_HP = RIGHT_H_LINE;
           
localparam GAME = 1'b1, 
           OFF  = 1'b0;
               
reg [11:0] rgb_nxt;
reg [11:0] vcount_nxt, hcount_nxt;
reg vsync_nxt, vblnk_nxt, hsync_nxt, hblnk_nxt;
reg [2:0] curr_dmg, curr_dmg_nxt;
reg game_over_nxt;
reg state, state_nxt;

always @(posedge pclk) begin
    if (rst) begin
        hsync_out_hp        <= 0;
        vsync_out_hp        <= 0;
        hblnk_out_hp        <= 0;
        vblnk_out_hp        <= 0;
        hcount_out_hp       <= 0;
        vcount_out_hp       <= 0;
        rgb_out_hp          <= 0;
        curr_dmg            <= 0;
        game_over           <= 0;
        state               <= OFF;    
        end
    else begin
        hsync_out_hp        <= hsync_in_hp;
        vsync_out_hp        <= vsync_in_hp;
        hblnk_out_hp        <= hblnk_in_hp;
        vblnk_out_hp        <= vblnk_in_hp;
        hcount_out_hp       <= hcount_in_hp;
        vcount_out_hp       <= vcount_in_hp;
        rgb_out_hp          <= rgb_nxt;
        curr_dmg            <= curr_dmg_nxt;
        game_over           <= game_over_nxt;
        state               <= state_nxt;
        end
end

always@(*) begin
    game_over_nxt = 0;
    rgb_nxt = rgb_in_hp;
    curr_dmg_nxt = 0;
    case (state) 
        OFF : begin
            if (game_on_hp) 
                state_nxt = GAME;
            else
                state_nxt = OFF; 
            end

        GAME : begin
            if (!game_on_hp) begin
                state_nxt = OFF;
                end
             else if (curr_dmg == MAX_DMG_TAKEN) begin
                 //You are dead, not big surprise
                state_nxt = OFF;
                game_over_nxt = 1;
                end    
             else if (player_hit) begin
                curr_dmg_nxt = curr_dmg + 1;
                state_nxt = GAME; 
                end  
             else begin   
                curr_dmg_nxt = curr_dmg;
                state_nxt = GAME;
                end  
      
            //drawing   
            // HP BAR FRAME
            if ((hcount_in_hp >= LEFT_HP - BORDER && hcount_in_hp < LEFT_HP && vcount_in_hp >= TOP_HP - BORDER && vcount_in_hp < BOTTOM_HP + BORDER ) ||
                (hcount_in_hp >= LEFT_HP && hcount_in_hp < RIGHT_HP && vcount_in_hp >= TOP_HP - BORDER && vcount_in_hp < TOP_HP ) || 
                (hcount_in_hp >= LEFT_HP && hcount_in_hp < RIGHT_HP&& vcount_in_hp >= BOTTOM_HP && vcount_in_hp < BOTTOM_HP + BORDER) || 
                (hcount_in_hp >= RIGHT_HP  && hcount_in_hp < RIGHT_HP + BORDER && vcount_in_hp >= TOP_HP - BORDER && vcount_in_hp < BOTTOM_HP + BORDER) ) begin
                rgb_nxt = 12'hf_f_f;
                end
                // HP BAR 
                //each HP point is 60 pixels wide - this draws green rectangle with right border calculated based on current HP
            else if (curr_dmg < MAX_DMG_TAKEN && (hcount_in_hp >= LEFT_HP && hcount_in_hp <= (RIGHT_HP - ( curr_dmg*60 ) ) && vcount_in_hp >= TOP_HP && vcount_in_hp <= BOTTOM_HP ) ) begin
                rgb_nxt = 12'h0_f_0;
                end
            else begin
                rgb_nxt = rgb_in_hp; 
                end
            end
    endcase           
end

endmodule
