
// PWJ: The picture was drawn on https://www.piskelapp.com and converted to .data file.

module image_rom (
    input wire clk ,
    input wire [15:0] address,  // address = {addry[5:0], addrx[5:0]}
    output reg [11:0] rgb
);


reg [11:0] rom [0:65535] ;// [0:39599];

initial $readmemh("../image/sens.data", rom); 

always @(posedge clk)
    rgb <= rom[address];

endmodule
