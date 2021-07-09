`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2021 12:50:16
// Design Name: 
// Module Name: multi_char_rom_16x16
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


module multi_char_rom_16x16(
    output reg [6:0] multi_char_code,
    
    input wire [7:0] multi_char_xy
    );

     
    always@*
            case(multi_char_xy) 
                8'h0: multi_char_code = 7'h20; //
                8'h1: multi_char_code = 7'h20; //
                8'h2: multi_char_code = 7'h20; //
                8'h3: multi_char_code = 7'h20; //
                8'h4: multi_char_code = 7'h20; //
                8'h5: multi_char_code = 7'h20; //
                8'h6: multi_char_code = 7'h20; //
                8'h7: multi_char_code = 7'h20; // 
                8'h8: multi_char_code = 7'h20; //
                8'h9: multi_char_code = 7'h20; //
                8'hA: multi_char_code = 7'h20; // 
                8'hB: multi_char_code = 7'h20; //
                8'hC: multi_char_code = 7'h20; //
                8'hD: multi_char_code = 7'h20; //
                8'hE: multi_char_code = 7'h20; //
                8'hF: multi_char_code = 7'h20; //
                8'h10: multi_char_code = 7'h20; //
                8'h11: multi_char_code = 7'h20; //
                8'h12: multi_char_code = 7'h20; //
                8'h13: multi_char_code = 7'h20; //
                8'h14: multi_char_code = 7'h20; // 
                8'h15: multi_char_code = 7'h20; //
                8'h16: multi_char_code = 7'h20; //
                8'h17: multi_char_code = 7'h20; //
                8'h18: multi_char_code = 7'h20; //
                8'h19: multi_char_code = 7'h20; //
                8'h1A: multi_char_code = 7'h20; // 
                8'h1B: multi_char_code = 7'h20; //
                8'h1C: multi_char_code = 7'h20; //
                8'h1D: multi_char_code = 7'h20; //
                8'h1E: multi_char_code = 7'h20; // 
                8'h1F: multi_char_code = 7'h20; //
                8'h20: multi_char_code = 7'h20; //
                8'h21: multi_char_code = 7'h20; // 
                8'h22: multi_char_code = 7'h20; //
                8'h23: multi_char_code = 7'h20; //
                8'h24: multi_char_code = 7'h20; //
                8'h25: multi_char_code = 7'h20; //
                8'h26: multi_char_code = 7'h4d; //M
                8'h27: multi_char_code = 7'h55; //U
                8'h28: multi_char_code = 7'h4C; //L
                8'h29: multi_char_code = 7'h54; //T
                8'h2A: multi_char_code = 7'h49; //I
                8'h2B: multi_char_code = 7'h20; //
                8'h2C: multi_char_code = 7'h20; // 
                8'h2D: multi_char_code = 7'h20; //
                8'h2E: multi_char_code = 7'h20; //
                8'h2F: multi_char_code = 7'h20; // 
                8'h30: multi_char_code = 7'h20; //
                8'h31: multi_char_code = 7'h20; //
                8'h32: multi_char_code = 7'h20; //
                8'h33: multi_char_code = 7'h20; //
                8'h34: multi_char_code = 7'h20; //
                8'h35: multi_char_code = 7'h20; // 
                8'h36: multi_char_code = 7'h20; //
                8'h37: multi_char_code = 7'h20; //
                8'h38: multi_char_code = 7'h20; // 
                8'h39: multi_char_code = 7'h20; //
                8'h3A: multi_char_code = 7'h20; //
                8'h3B: multi_char_code = 7'h20; // 
                8'h3C: multi_char_code = 7'h20; //
                8'h3D: multi_char_code = 7'h20; //
                8'h3E: multi_char_code = 7'h20; //
                8'h3F: multi_char_code = 7'h20; // 
                8'h40: multi_char_code = 7'h20; //
                8'h41: multi_char_code = 7'h20; //
                8'h42: multi_char_code = 7'h20; //
                8'h43: multi_char_code = 7'h20; //
                8'h44: multi_char_code = 7'h20; //
                8'h45: multi_char_code = 7'h20; //
                8'h46: multi_char_code = 7'h20; //
                8'h47: multi_char_code = 7'h20; //
                8'h48: multi_char_code = 7'h20; //
                8'h49: multi_char_code = 7'h20; // 
                8'h4A: multi_char_code = 7'h20; //
                8'h4B: multi_char_code = 7'h20; //
                8'h4C: multi_char_code = 7'h20; //
                8'h4D: multi_char_code = 7'h20; //
                8'h4E: multi_char_code = 7'h20; //
                8'h4F: multi_char_code = 7'h20; //
                8'h50: multi_char_code = 7'h20; //
                8'h51: multi_char_code = 7'h20; // 
                8'h52: multi_char_code = 7'h20; //
                8'h53: multi_char_code = 7'h20; //
                8'h54: multi_char_code = 7'h20; // 
                8'h55: multi_char_code = 7'h20; //
                8'h56: multi_char_code = 7'h20; //
                8'h57: multi_char_code = 7'h20; //
                8'h58: multi_char_code = 7'h20; //
                8'h59: multi_char_code = 7'h20; //
                8'h5A: multi_char_code = 7'h20; //
                8'h5B: multi_char_code = 7'h20; //
                8'h5C: multi_char_code = 7'h20; // 
                8'h5D: multi_char_code = 7'h20; //
                8'h5E: multi_char_code = 7'h20; //
                8'h5F: multi_char_code = 7'h20; //
                8'h60: multi_char_code = 7'h20; //
                8'h61: multi_char_code = 7'h20; //
                8'h62: multi_char_code = 7'h20; //
                8'h63: multi_char_code = 7'h20; //
                8'h64: multi_char_code = 7'h20; //
                8'h65: multi_char_code = 7'h20; //
                8'h66: multi_char_code = 7'h20; //
                8'h67: multi_char_code = 7'h20; //
                8'h68: multi_char_code = 7'h20; //
                8'h69: multi_char_code = 7'h20; //
                8'h6A: multi_char_code = 7'h20; // 
                8'h6B: multi_char_code = 7'h20; //
                8'h6C: multi_char_code = 7'h20; //
                8'h6D: multi_char_code = 7'h20; //
                8'h6E: multi_char_code = 7'h20; //
                8'h6F: multi_char_code = 7'h20; //
                8'h70: multi_char_code = 7'h20; //
                8'h71: multi_char_code = 7'h20; // 
                8'h72: multi_char_code = 7'h20; //
                8'h73: multi_char_code = 7'h20; //
                8'h74: multi_char_code = 7'h20; //
                8'h75: multi_char_code = 7'h20; //
                8'h76: multi_char_code = 7'h20; // 
                8'h77: multi_char_code = 7'h20; //
                8'h78: multi_char_code = 7'h20; //
                8'h79: multi_char_code = 7'h20; //
                8'h7A: multi_char_code = 7'h20; // 
                8'h7B: multi_char_code = 7'h20; //
                8'h7C: multi_char_code = 7'h20; //
                8'h7D: multi_char_code = 7'h20; //
                8'h7E: multi_char_code = 7'h20; //
                8'h7F: multi_char_code = 7'h20; // 
                8'h80: multi_char_code = 7'h20; //
                8'h81: multi_char_code = 7'h20; //
                8'h82: multi_char_code = 7'h20; //
                8'h83: multi_char_code = 7'h20; // 
                8'h84: multi_char_code = 7'h20; //
                8'h85: multi_char_code = 7'h20; //
                8'h86: multi_char_code = 7'h20; //
                8'h87: multi_char_code = 7'h20; //
                8'h88: multi_char_code = 7'h20; //
                8'h89: multi_char_code = 7'h20; //
                8'h8A: multi_char_code = 7'h20; //
                8'h8B: multi_char_code = 7'h20; //
                8'h8C: multi_char_code = 7'h20; // 
                8'h8D: multi_char_code = 7'h20; //
                8'h8E: multi_char_code = 7'h20; // 
                8'h8F: multi_char_code = 7'h20; //
                8'h90: multi_char_code = 7'h20; //
                8'h91: multi_char_code = 7'h20; //
                8'h92: multi_char_code = 7'h20; //
                8'h93: multi_char_code = 7'h20; // 
                8'h94: multi_char_code = 7'h20; //
                8'h95: multi_char_code = 7'h20; //
                8'h96: multi_char_code = 7'h20; // 
                8'h97: multi_char_code = 7'h20; //
                8'h98: multi_char_code = 7'h20; //
                8'h99: multi_char_code = 7'h20; // 
                8'h9A: multi_char_code = 7'h20; //
                8'h9B: multi_char_code = 7'h20; //
                8'h9C: multi_char_code = 7'h20; //
                8'h9D: multi_char_code = 7'h20; //
                8'h9E: multi_char_code = 7'h20; //
                8'h9F: multi_char_code = 7'h20; //
                8'hA0: multi_char_code = 7'h20; //
                8'hA1: multi_char_code = 7'h20; //
                8'hA2: multi_char_code = 7'h20; // 
                8'hA3: multi_char_code = 7'h20; //
                8'hA4: multi_char_code = 7'h20; //
                8'hA5: multi_char_code = 7'h20; //
                8'hA6: multi_char_code = 7'h20; // 
                8'hA7: multi_char_code = 7'h20; //
                8'hA8: multi_char_code = 7'h20; //
                8'hA9: multi_char_code = 7'h20; //
                8'hAA: multi_char_code = 7'h20; // 
                8'hAB: multi_char_code = 7'h20; //
                8'hAC: multi_char_code = 7'h20; //
                8'hAD: multi_char_code = 7'h20; //
                8'hAE: multi_char_code = 7'h20; //
                8'hAF: multi_char_code = 7'h20; // 
                8'hB0: multi_char_code = 7'h20; //
                8'hB1: multi_char_code = 7'h20; //
                8'hB2: multi_char_code = 7'h20; // 
                8'hB3: multi_char_code = 7'h20; //
                8'hB4: multi_char_code = 7'h20; //
                8'hB5: multi_char_code = 7'h20; //
                8'hB6: multi_char_code = 7'h20; //
                8'hB7: multi_char_code = 7'h20; //
                8'hB8: multi_char_code = 7'h20; //
                8'hB9: multi_char_code = 7'h20; //
                8'hBA: multi_char_code = 7'h20; //
                8'hBB: multi_char_code = 7'h20; //
                8'hBC: multi_char_code = 7'h20; //
                8'hBD: multi_char_code = 7'h20; // 
                8'hBE: multi_char_code = 7'h20; //
                8'hBF: multi_char_code = 7'h20; //
                8'hC0: multi_char_code = 7'h20; //
                8'hC1: multi_char_code = 7'h20; //
                8'hC2: multi_char_code = 7'h20; //
                8'hC3: multi_char_code = 7'h20; //
                8'hC4: multi_char_code = 7'h20; //
                8'hC5: multi_char_code = 7'h20; // 
                8'hC6: multi_char_code = 7'h20; //
                8'hC7: multi_char_code = 7'h20; //
                8'hC8: multi_char_code = 7'h20; //
                8'hC9: multi_char_code = 7'h20; // 
                8'hCA: multi_char_code = 7'h20; //
                8'hCB: multi_char_code = 7'h20; // 
                8'hCC: multi_char_code = 7'h20; //
                8'hCD: multi_char_code = 7'h20; //
                8'hCE: multi_char_code = 7'h20; //
                8'hCF: multi_char_code = 7'h20; // 
                8'hD0: multi_char_code = 7'h20; //
                8'hD1: multi_char_code = 7'h20; //
                8'hD2: multi_char_code = 7'h20; //
                8'hD3: multi_char_code = 7'h20; //
                8'hD4: multi_char_code = 7'h20; // 
                8'hD5: multi_char_code = 7'h20; //
                8'hD6: multi_char_code = 7'h20; //
                8'hD7: multi_char_code = 7'h20; //
                8'hD8: multi_char_code = 7'h20; //
                8'hD9: multi_char_code = 7'h20; //
                8'hDA: multi_char_code = 7'h20; // 
                8'hDB: multi_char_code = 7'h20; //
                8'hDC: multi_char_code = 7'h20; //
                8'hDD: multi_char_code = 7'h20; //
                8'hDE: multi_char_code = 7'h20; // 
                8'hDF: multi_char_code = 7'h20; //
                8'hE0: multi_char_code = 7'h20; //
                8'hE1: multi_char_code = 7'h20; // 
                8'hE2: multi_char_code = 7'h20; //
                8'hE3: multi_char_code = 7'h20; // 
                8'hE4: multi_char_code = 7'h20; //
                8'hE5: multi_char_code = 7'h20; //
                8'hE6: multi_char_code = 7'h20; // 
                8'hE7: multi_char_code = 7'h20; //
                8'hE8: multi_char_code = 7'h20; //
                8'hE9: multi_char_code = 7'h20; // 
                8'hEA: multi_char_code = 7'h20; //
                8'hEB: multi_char_code = 7'h20; //
                8'hEC: multi_char_code = 7'h20; //
                8'hED: multi_char_code = 7'h20; // 
                8'hEE: multi_char_code = 7'h20; //
                8'hEF: multi_char_code = 7'h20; //
                8'hF0: multi_char_code = 7'h20; //
                8'hF1: multi_char_code = 7'h20; //
                8'hF2: multi_char_code = 7'h20; //
                8'hF3: multi_char_code = 7'h20; //
                8'hF4: multi_char_code = 7'h20; //
                8'hF5: multi_char_code = 7'h20; // 
                8'hF6: multi_char_code = 7'h20; //
                8'hF7: multi_char_code = 7'h20; //
                8'hF8: multi_char_code = 7'h20; //
                8'hF9: multi_char_code = 7'h20; //
                8'hFA: multi_char_code = 7'h20; //
                8'hFB: multi_char_code = 7'h20; //
                8'hFC: multi_char_code = 7'h20; //
                8'hFD: multi_char_code = 7'h20; // 
                8'hFE: multi_char_code = 7'h20; //
                8'hFF: multi_char_code = 7'h20; //  
            endcase
    

endmodule
