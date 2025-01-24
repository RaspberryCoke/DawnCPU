`timescale 1ns/1ps
module top_single_module2();
//GLOBAL
//global input
reg clk_i=1;
reg rst_n_i=1;
reg[63:0] PC_i;

wire[3:0] icode_o;
wire [3:0] ifun_o;
 wire[3:0] rA_o;
wire [3:0] rB_o;

wire [63:0] valC_o ;
wire [63:0] valP_o ;
wire        instr_valid_o;
wire       imem_error_o ;

fetch fetch_module(
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


module decode(
    input wire clk_i,
    input wire rst_n_i,

    input [3:0] rA_i,
    input [3:0] rB_i,
    input [3:0] icode_i,

    input wire[63:0] valE_i,
    input wire[63:0] valM_i,

    //input wire cnd_i,

    output wire[63:0] valA_o,
    output wire[63:0] valB_o
);




initial begin
    #10


    $monitor("Time=%0t|PC=%d|icode=%h|ifun=%h|rA=%h|rB=%h|valC=%h|valP=%h|instr_valid=%h|imem_error_o=%h",
                $time, PC_i, icode_o, ifun_o,rA_o, rB_o,  valC_o, valP_o, instr_valid_o,imem_error_o);
    // clk_i=1;
    // rst_n_i=1;q

    #10 PC_i=64'D0; 
    $monitor("Time=%0t|PC=%d|icode=%h|ifun=%h|rA=%h|rB=%h|valC=%h|valP=%h|instr_valid=%h|imem_error_o=%h",
                $time, PC_i, icode_o, ifun_o,rA_o, rB_o,  valC_o, valP_o, instr_valid_o,imem_error_o);
    #10 PC_i=64'D10;#10
    $monitor("Time=%0t|PC=%d|icode=%h|ifun=%h|rA=%h|rB=%h|valC=%h|valP=%h|instr_valid=%h|imem_error_o=%h",
                $time, PC_i, icode_o, ifun_o,rA_o, rB_o,  valC_o, valP_o, instr_valid_o,imem_error_o);
    #10 PC_i=64'D20;#10
    $monitor("Time=%0t|PC=%d|icode=%h|ifun=%h|rA=%h|rB=%h|valC=%h|valP=%h|instr_valid=%h|imem_error_o=%h",
                $time, PC_i, icode_o, ifun_o,rA_o, rB_o,  valC_o, valP_o, instr_valid_o,imem_error_o);
    #10 PC_i=64'D22;
    #10 PC_i=64'D24;
    #10 PC_i=64'D26;
    #10 PC_i=64'D28;
    #10 PC_i=64'D30;
    #10 PC_i=64'D32;

end



endmodule