module menu_char_rom_16x16(
    output reg [6:0] menu_char_code,

    input wire [7:0] menu_char_xy
);

 
always@*
        case(menu_char_xy) 
            8'h0: menu_char_code = 7'h20; //
            8'h1: menu_char_code = 7'h20; //
            8'h2: menu_char_code = 7'h20; //
            8'h3: menu_char_code = 7'h20; //
            8'h4: menu_char_code = 7'h20; //
            8'h5: menu_char_code = 7'h20; //
            8'h6: menu_char_code = 7'h20; //
            8'h7: menu_char_code = 7'h20; // 
            8'h8: menu_char_code = 7'h20; //
            8'h9: menu_char_code = 7'h20; //
            8'hA: menu_char_code = 7'h20; // 
            8'hB: menu_char_code = 7'h20; //
            8'hC: menu_char_code = 7'h20; //
            8'hD: menu_char_code = 7'h20; //
            8'hE: menu_char_code = 7'h20; //
            8'hF: menu_char_code = 7'h20; //
            8'h10: menu_char_code = 7'h20; //
            8'h11: menu_char_code = 7'h20; //
            8'h12: menu_char_code = 7'h20; //
            8'h13: menu_char_code = 7'h20; //
            8'h14: menu_char_code = 7'h20; // 
            8'h15: menu_char_code = 7'h20; //
            8'h16: menu_char_code = 7'h20; //
            8'h17: menu_char_code = 7'h20; //
            8'h18: menu_char_code = 7'h20; //
            8'h19: menu_char_code = 7'h20; //
            8'h1A: menu_char_code = 7'h20; // 
            8'h1B: menu_char_code = 7'h20; //
            8'h1C: menu_char_code = 7'h20; //
            8'h1D: menu_char_code = 7'h20; //
            8'h1E: menu_char_code = 7'h20; // 
            8'h1F: menu_char_code = 7'h20; //
            8'h20: menu_char_code = 7'h20; //
            8'h21: menu_char_code = 7'h20; // 
            8'h22: menu_char_code = 7'h20; //
            8'h23: menu_char_code = 7'h20; //
            8'h24: menu_char_code = 7'h20; //
            8'h25: menu_char_code = 7'h20; //
            8'h26: menu_char_code = 7'h4d; //M
            8'h27: menu_char_code = 7'h45; //E
            8'h28: menu_char_code = 7'h4E; //N
            8'h29: menu_char_code = 7'h55; //U
            8'h2A: menu_char_code = 7'h20; //
            8'h2B: menu_char_code = 7'h20; //
            8'h2C: menu_char_code = 7'h20; // 
            8'h2D: menu_char_code = 7'h20; //
            8'h2E: menu_char_code = 7'h20; //
            8'h2F: menu_char_code = 7'h20; // 
            8'h30: menu_char_code = 7'h20; //
            8'h31: menu_char_code = 7'h20; //
            8'h32: menu_char_code = 7'h20; //
            8'h33: menu_char_code = 7'h20; //
            8'h34: menu_char_code = 7'h20; //
            8'h35: menu_char_code = 7'h20; // 
            8'h36: menu_char_code = 7'h20; //
            8'h37: menu_char_code = 7'h20; //
            8'h38: menu_char_code = 7'h20; // 
            8'h39: menu_char_code = 7'h20; //
            8'h3A: menu_char_code = 7'h20; //
            8'h3B: menu_char_code = 7'h20; // 
            8'h3C: menu_char_code = 7'h20; //
            8'h3D: menu_char_code = 7'h20; //
            8'h3E: menu_char_code = 7'h20; //
            8'h3F: menu_char_code = 7'h20; // 
            8'h40: menu_char_code = 7'h20; //
            8'h41: menu_char_code = 7'h20; //
            8'h42: menu_char_code = 7'h20; //
            8'h43: menu_char_code = 7'h20; //
            8'h44: menu_char_code = 7'h20; //
            8'h45: menu_char_code = 7'h20; //
            8'h46: menu_char_code = 7'h20; //
            8'h47: menu_char_code = 7'h20; //
            8'h48: menu_char_code = 7'h20; //
            8'h49: menu_char_code = 7'h20; // 
            8'h4A: menu_char_code = 7'h20; //
            8'h4B: menu_char_code = 7'h20; //
            8'h4C: menu_char_code = 7'h20; //
            8'h4D: menu_char_code = 7'h20; //
            8'h4E: menu_char_code = 7'h20; //
            8'h4F: menu_char_code = 7'h20; //
            8'h50: menu_char_code = 7'h20; //
            8'h51: menu_char_code = 7'h20; // 
            8'h52: menu_char_code = 7'h20; //
            8'h53: menu_char_code = 7'h20; //
            8'h54: menu_char_code = 7'h20; // 
            8'h55: menu_char_code = 7'h20; //
            8'h56: menu_char_code = 7'h20; //
            8'h57: menu_char_code = 7'h20; //
            8'h58: menu_char_code = 7'h20; //
            8'h59: menu_char_code = 7'h20; //
            8'h5A: menu_char_code = 7'h20; //
            8'h5B: menu_char_code = 7'h20; //
            8'h5C: menu_char_code = 7'h20; // 
            8'h5D: menu_char_code = 7'h20; //
            8'h5E: menu_char_code = 7'h20; //
            8'h5F: menu_char_code = 7'h20; //
            8'h60: menu_char_code = 7'h20; //
            8'h61: menu_char_code = 7'h20; //
            8'h62: menu_char_code = 7'h20; //
            8'h63: menu_char_code = 7'h20; //
            8'h64: menu_char_code = 7'h20; //
            8'h65: menu_char_code = 7'h20; //
            8'h66: menu_char_code = 7'h20; //
            8'h67: menu_char_code = 7'h20; //
            8'h68: menu_char_code = 7'h20; //
            8'h69: menu_char_code = 7'h20; //
            8'h6A: menu_char_code = 7'h20; // 
            8'h6B: menu_char_code = 7'h20; //
            8'h6C: menu_char_code = 7'h20; //
            8'h6D: menu_char_code = 7'h20; //
            8'h6E: menu_char_code = 7'h20; //
            8'h6F: menu_char_code = 7'h20; //
            8'h70: menu_char_code = 7'h20; //
            8'h71: menu_char_code = 7'h20; // 
            8'h72: menu_char_code = 7'h20; //
            8'h73: menu_char_code = 7'h20; //
            8'h74: menu_char_code = 7'h20; //
            8'h75: menu_char_code = 7'h20; //
            8'h76: menu_char_code = 7'h20; // 
            8'h77: menu_char_code = 7'h20; //
            8'h78: menu_char_code = 7'h20; //
            8'h79: menu_char_code = 7'h20; //
            8'h7A: menu_char_code = 7'h20; // 
            8'h7B: menu_char_code = 7'h20; //
            8'h7C: menu_char_code = 7'h20; //
            8'h7D: menu_char_code = 7'h20; //
            8'h7E: menu_char_code = 7'h20; //
            8'h7F: menu_char_code = 7'h20; // 
            8'h80: menu_char_code = 7'h20; //
            8'h81: menu_char_code = 7'h20; //
            8'h82: menu_char_code = 7'h20; //
            8'h83: menu_char_code = 7'h20; // 
            8'h84: menu_char_code = 7'h20; //
            8'h85: menu_char_code = 7'h20; //
            8'h86: menu_char_code = 7'h20; //
            8'h87: menu_char_code = 7'h20; //
            8'h88: menu_char_code = 7'h20; //
            8'h89: menu_char_code = 7'h20; //
            8'h8A: menu_char_code = 7'h20; //
            8'h8B: menu_char_code = 7'h20; //
            8'h8C: menu_char_code = 7'h20; // 
            8'h8D: menu_char_code = 7'h20; //
            8'h8E: menu_char_code = 7'h20; // 
            8'h8F: menu_char_code = 7'h20; //
            8'h90: menu_char_code = 7'h20; //
            8'h91: menu_char_code = 7'h20; //
            8'h92: menu_char_code = 7'h20; //
            8'h93: menu_char_code = 7'h20; // 
            8'h94: menu_char_code = 7'h20; //
            8'h95: menu_char_code = 7'h20; //
            8'h96: menu_char_code = 7'h20; // 
            8'h97: menu_char_code = 7'h20; //
            8'h98: menu_char_code = 7'h20; //
            8'h99: menu_char_code = 7'h20; // 
            8'h9A: menu_char_code = 7'h20; //
            8'h9B: menu_char_code = 7'h20; //
            8'h9C: menu_char_code = 7'h20; //
            8'h9D: menu_char_code = 7'h20; //
            8'h9E: menu_char_code = 7'h20; //
            8'h9F: menu_char_code = 7'h20; //
            8'hA0: menu_char_code = 7'h20; //
            8'hA1: menu_char_code = 7'h20; //
            8'hA2: menu_char_code = 7'h20; // 
            8'hA3: menu_char_code = 7'h20; //
            8'hA4: menu_char_code = 7'h20; //
            8'hA5: menu_char_code = 7'h20; //
            8'hA6: menu_char_code = 7'h20; // 
            8'hA7: menu_char_code = 7'h20; //
            8'hA8: menu_char_code = 7'h20; //
            8'hA9: menu_char_code = 7'h20; //
            8'hAA: menu_char_code = 7'h20; // 
            8'hAB: menu_char_code = 7'h20; //
            8'hAC: menu_char_code = 7'h20; //
            8'hAD: menu_char_code = 7'h20; //
            8'hAE: menu_char_code = 7'h20; //
            8'hAF: menu_char_code = 7'h20; // 
            8'hB0: menu_char_code = 7'h20; //
            8'hB1: menu_char_code = 7'h20; //
            8'hB2: menu_char_code = 7'h20; // 
            8'hB3: menu_char_code = 7'h20; //
            8'hB4: menu_char_code = 7'h20; //
            8'hB5: menu_char_code = 7'h20; //
            8'hB6: menu_char_code = 7'h20; //
            8'hB7: menu_char_code = 7'h20; //
            8'hB8: menu_char_code = 7'h20; //
            8'hB9: menu_char_code = 7'h20; //
            8'hBA: menu_char_code = 7'h20; //
            8'hBB: menu_char_code = 7'h20; //
            8'hBC: menu_char_code = 7'h20; //
            8'hBD: menu_char_code = 7'h20; // 
            8'hBE: menu_char_code = 7'h20; //
            8'hBF: menu_char_code = 7'h20; //
            8'hC0: menu_char_code = 7'h20; //
            8'hC1: menu_char_code = 7'h20; //
            8'hC2: menu_char_code = 7'h20; //
            8'hC3: menu_char_code = 7'h20; //
            8'hC4: menu_char_code = 7'h20; //
            8'hC5: menu_char_code = 7'h20; // 
            8'hC6: menu_char_code = 7'h20; //
            8'hC7: menu_char_code = 7'h20; //
            8'hC8: menu_char_code = 7'h20; //
            8'hC9: menu_char_code = 7'h20; // 
            8'hCA: menu_char_code = 7'h20; //
            8'hCB: menu_char_code = 7'h20; // 
            8'hCC: menu_char_code = 7'h20; //
            8'hCD: menu_char_code = 7'h20; //
            8'hCE: menu_char_code = 7'h20; //
            8'hCF: menu_char_code = 7'h20; // 
            8'hD0: menu_char_code = 7'h20; //
            8'hD1: menu_char_code = 7'h20; //
            8'hD2: menu_char_code = 7'h20; //
            8'hD3: menu_char_code = 7'h20; //
            8'hD4: menu_char_code = 7'h20; // 
            8'hD5: menu_char_code = 7'h20; //
            8'hD6: menu_char_code = 7'h20; //
            8'hD7: menu_char_code = 7'h20; //
            8'hD8: menu_char_code = 7'h20; //
            8'hD9: menu_char_code = 7'h20; //
            8'hDA: menu_char_code = 7'h20; // 
            8'hDB: menu_char_code = 7'h20; //
            8'hDC: menu_char_code = 7'h20; //
            8'hDD: menu_char_code = 7'h20; //
            8'hDE: menu_char_code = 7'h20; // 
            8'hDF: menu_char_code = 7'h20; //
            8'hE0: menu_char_code = 7'h20; //
            8'hE1: menu_char_code = 7'h20; // 
            8'hE2: menu_char_code = 7'h20; //
            8'hE3: menu_char_code = 7'h20; // 
            8'hE4: menu_char_code = 7'h20; //
            8'hE5: menu_char_code = 7'h20; //
            8'hE6: menu_char_code = 7'h20; // 
            8'hE7: menu_char_code = 7'h20; //
            8'hE8: menu_char_code = 7'h20; //
            8'hE9: menu_char_code = 7'h20; // 
            8'hEA: menu_char_code = 7'h20; //
            8'hEB: menu_char_code = 7'h20; //
            8'hEC: menu_char_code = 7'h20; //
            8'hED: menu_char_code = 7'h20; // 
            8'hEE: menu_char_code = 7'h20; //
            8'hEF: menu_char_code = 7'h20; //
            8'hF0: menu_char_code = 7'h20; //
            8'hF1: menu_char_code = 7'h20; //
            8'hF2: menu_char_code = 7'h20; //
            8'hF3: menu_char_code = 7'h20; //
            8'hF4: menu_char_code = 7'h20; //
            8'hF5: menu_char_code = 7'h20; // 
            8'hF6: menu_char_code = 7'h20; //
            8'hF7: menu_char_code = 7'h20; //
            8'hF8: menu_char_code = 7'h20; //
            8'hF9: menu_char_code = 7'h20; //
            8'hFA: menu_char_code = 7'h20; //
            8'hFB: menu_char_code = 7'h20; //
            8'hFC: menu_char_code = 7'h20; //
            8'hFD: menu_char_code = 7'h20; // 
            8'hFE: menu_char_code = 7'h20; //
            8'hFF: menu_char_code = 7'h20; //  
        endcase


endmodule