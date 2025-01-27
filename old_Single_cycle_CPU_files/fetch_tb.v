`timescale 1ns/1ps
`include "define.v"

module fetch_tb;

reg[63:0] PC_i;

wire [3:0] icode_o;
wire [3:0] ifun_o;
wire[3:0] rA_o;
wire [3:0] rB_o;
wire [63:0] valC_o;
wire [63:0] valP_o ;
wire       instr_valid_o;
wire       imem_error_o ;


fetch fetch_tb(
    .PC_i(PC_i),
    .icode_o(icode_o),
    .ifun_o(ifun_o),
    .rA_o(rA_o),
    .rB_o(rB_o),
    .valC_o(valC_o),
    .valP_o(valP_o),
    .instr_valid_o(instr_valid_o),
    .imem_error_o(imem_error_o)
);

initial begin
    PC_i=0;
    #10 PC_i=10;
    #10 PC_i=20;
end

initial begin

$monitor("PC=%d\t,icode=%h\t,rA=%h\t,rB=%h\t,valC=%h\t,valP=%d\t,instr_valid_o=%h\t,imem_error=%h\t",
PC_i,icode_o,ifun_o,rA_o,rB_o,valC_o,valP_o,instr_valid_o,imem_error_o);

end




endmodule