`include "define.V"
module selectA(
    input wire[3:0]icode_i,
    input wire[63:0]valA_i,
    input wire[63:0]valP_i,
    output wire[63:0]valA_o
);
assign valA_o=(icode_i==`ICALL)?valP_i:valA_i;
endmodule