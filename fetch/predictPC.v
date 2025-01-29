`include "define.v"
module predictPC(
    input wire[3:0]icode_i,
    input wire[63:0] valC_i,
    input wire[63:0] valP_i,
    output wire[63:0] predPC_o
);

assign predPC_o=(icode_i==`IJXX||icode_i==`ICALL)?valC_i:valP_i;

endmodule