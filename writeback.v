module writeback(
    input wire [3:0] icode,
    input wire [63:0] valE_i,
    input wire [63:0] valM_i,

    input wire instr_valid_i,
    input wire hlt_i,
    input wire instr_error_i,
    input wire imem_error_i, 

    output wire [63:0] valE_o,
    output wire [63:0] valM_o,

    output wire [1:0]stat_o
);

assign valE_o=valE_i;
assign valM_o=valE_i;

stat_module stat(
    .instr_valid_i(instr_valid_i),
    .hlt_i(hlt_i),
    .instr_error_i(instr_error_i),
    .imem_error_i(imem_error_i),
    .stat_o(stat_o)
);


endmodule