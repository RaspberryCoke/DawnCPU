//注意：后续需要修改

module predictPC(
    input wire[63:0] valC_i,
    input wire[63:0] valP_i,
    output wire[63:0] valC_o,//tmp
    output wire[63:0] valP_o,//tmp
    output wire[63:0] predPC_o
);

assign predPC_o=64'b0;//注意：后续需要修改
assign valC_o=valC_i;
assign valP_o=valP_i;

endmodule