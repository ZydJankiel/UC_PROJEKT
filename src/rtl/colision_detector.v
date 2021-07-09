`timescale 1 ns / 1 ps
/*
* PWJ Added function for detecting hit and sending information to HP module.
* When player is hit he have 1 second of immortality to correct his mistake.
*
* MO - reduced invulnerability to 0,5 sec - it had potential to skip whole obstacles during 1 sec 
* and it is faster to test.
*/
module colision_detector (
    input wire pclk,
    input wire rst,
    input wire [11:0] obstacle_x_in,
    input wire [11:0] obstacle_y_in,
    input wire [11:0] mouse_x_in,
    input wire [11:0] mouse_y_in,
    output reg damage_out
    );
  
    reg damage_out_nxt;
    reg state, state_nxt;
    reg [27:0] counter, counter_nxt;

    localparam CHECK_DAMAGE = 0,
               COUNT = 1;

    localparam MAX_COUNT = 32500000;

    always @(posedge pclk) begin
        if (rst) begin
            state <= CHECK_DAMAGE;
            damage_out <= 0;
            counter <= 0;
        end
        else begin
            state <= state_nxt;
            damage_out <= damage_out_nxt;
            counter <= counter_nxt;
        end
    end
    
    always @* begin 
        damage_out_nxt = 0;
        counter_nxt = counter;
        state_nxt = state;
        case (state)
            CHECK_DAMAGE:
                begin
                    if ( (mouse_x_in == obstacle_x_in && mouse_y_in == obstacle_y_in) ||
                    (mouse_x_in + 16 == obstacle_x_in && mouse_y_in == obstacle_y_in) ||
                    (mouse_x_in == obstacle_x_in && mouse_y_in + 16 == obstacle_y_in) ||
                    (mouse_x_in +16 == obstacle_x_in && mouse_y_in + 16 == obstacle_y_in) ) begin
                        damage_out_nxt = 1;
                        state_nxt = COUNT;
                    end
                    else begin
                        damage_out_nxt = 0;
                        state_nxt = CHECK_DAMAGE;
                    end
                end
            COUNT:
                begin
                    if (counter >= MAX_COUNT) begin
                        counter_nxt = 0;
                        state_nxt = CHECK_DAMAGE;
                    end
                    else begin
                        counter_nxt = counter + 1;
                        state_nxt = COUNT;
                    end
                end
        endcase
    end
endmodule
