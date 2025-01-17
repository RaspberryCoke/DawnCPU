module stat_module(
    input wire instr_valid_i,
    input wire hlt_i,
    input wire instr_error_i,
    input wire imem_error_i,
    output wire [1:0]  stat_o
);

assign stat_o=(instr_valid_i==1'b1)?2'b0:
        ((hlt_i==1'b1)?2'b1:
        ((instr_error_i==1'b1)?2'b10:2'b11));


endmodule