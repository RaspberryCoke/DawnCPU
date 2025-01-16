`timescale 1ns/1ps
`include "defines.v"

module fetch_tb(
    input wire[63:0] PC_i,

    output wire [3:0] icode_o,
    output wire [3:0] ifun_o,
    output wire[3:0] rA_o,
    output wire [3:0] rB_o,
    output wire [63:0] valC_o ,
    output wire [63:0] valP_o ,
    output wire       instr_valid_o,
    output wire       imem_error_o 
);

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
        //手动填充指令
        //30 F8 08 00 00 00 00 00 00 00
        //由第一个字节的icode分析出后面有立即数，
        //立即数采用了小端存储，也就是在指令里面，是逆序的。

        //irmovq 0x8 %r8
        instr_mem[0]=8'h30;
        instr_mem[1]=8'hF8;
        instr_mem[2]=8'h08;
        instr_mem[3]=8'h00;
        instr_mem[4]=8'h00;
        instr_mem[5]=8'h00;
        instr_mem[6]=8'h00;
        instr_mem[7]=8'h00;
        instr_mem[8]=8'h00;
        instr_mem[9]=8'h00;

        //irmovq 0x21 %rbx
        instr_mem[10]=8'h30;
        instr_mem[11]=8'hf3;
        instr_mem[12]=8'h15;
        instr_mem[13]=8'h00;
        instr_mem[14]=8'h00;
        instr_mem[15]=8'h00;
        instr_mem[16]=8'h00;
        instr_mem[17]=8'h00;
        instr_mem[18]=8'h00;
        instr_mem[19]=8'h00;




    end



endmodule