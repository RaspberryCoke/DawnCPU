//注意：后续需要修改

module predictPC(
    input wire[63:0] valC_i,
    input wire[63:0] valP_i,
    output wire[63:0] predPC_o
);

assign predPC_o=valP_i;//注意：后续需要修改，这里假设永远不跳转

endmodule