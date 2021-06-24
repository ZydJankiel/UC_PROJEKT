`timescale 1ns / 1ps
module monostable (
        input wire clk,
        input wire reset,
        input wire trigger,
        output reg pulse = 0
);
        reg [1:0] state,state_nxt;
        reg count, count_nxt;
        reg pulse_nxt;
        
        localparam IDLE = 2'b00;
        localparam PULSE_STATE = 2'b01;
        localparam WAIT = 2'b10;
                   
 always @(posedge clk) begin
    if (reset) begin
        state = IDLE;
        count <= 0;
        pulse <= 0;
        end
    else begin
        pulse <= pulse_nxt;
        count <= count_nxt;
        state <= state_nxt;
        end
end
    
always @* begin
    case(state)
        IDLE: begin
            count_nxt = 0;
            pulse_nxt = 0;
            state_nxt = trigger ? PULSE_STATE : IDLE;
        end
        PULSE_STATE: begin
            if (count == 1) begin
                pulse_nxt = 0;
                state_nxt = WAIT;
            end
            else begin
                pulse_nxt = 1;
                state_nxt = PULSE_STATE;
            end   
            count_nxt = count + 1;                   
        end
        WAIT: begin
            pulse_nxt = 0;
            count_nxt = 0;
            state_nxt = !trigger ? IDLE : WAIT;
        end
    endcase
end
       
endmodule
