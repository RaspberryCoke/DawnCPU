`timescale 1ns/1ps
module top_five_module();

reg clk_i=1;
reg rst_n_i=1;
wire [63:0] PC_i;
//PC(reg type)is in pc_update module.

initial begin 
    #10;
    forever begin
        #1 clk_i=~clk_i;
    end
end

initial begin
    //reset
    rst_n_i = 0;
    #10 rst_n_i = 1;
    $monitor("Time=%0t | PC=%h | icode=%b | ifun=%b", $time, PC_i, icode_o, ifun_o);

    //end time
    #100 $finish;
end


/*
    fetch module
*/

wire[3:0] icode_o;
wire [3:0] ifun_o;

wire[3:0] rA_o;
wire [3:0] rB_o;

wire [63:0] valC_o ;
wire [63:0] valP_o ;
wire instr_valid_o;
wire imem_error_o ;

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

/*
    decode module
*/


wire[63:0] valE_i;
wire[63:0] valM_i;

wire[63:0] valA_o;
wire[63:0] valB_o;

decode decode_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .rA_i(rA_o),
    .rB_i(rB_o),
    .icode_i(icode_o),
    .valE_i(valE_i),
    .valM_i(valM_i),
    .valA_o(valA_o),//out
    .valB_o(valB_o)//out
);


/*
    execute module
*/


wire signed[63:0] valE_o;
wire cnd_o;

execute execute_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .icode_i(icode_o),
    .ifun_i(ifun_o),

    .valA_i(valA_o),
    .valB_i(valB_o),
    .valC_i(valC_o),

    .valE_o(valE_o),
    .cnd_o(cnd_o)
);


/*
    memory module
*/


wire [63:0]valM_o;
wire dmem_error_o;

memory_access memory_module(
.clk_i(clk_i),
.icode_i(icode_o),
.valA_i(valA_o),
.valE_i(valE_o),
.valP_i(valP_o),
.valM_o(valM_o),
.dmem_error_o(dmem_error_o)
);


/*
    writeback module
*/


wire stat_o;

writeback writeback_module(
    .icode_i(icode_o),
    .valE_i(valE_o),
    .valM_i(valM_o),
    .instr_valid_i(instr_valid_o),
    .imem_error_i(imem_error_o),
    .dmem_error_i(dmem_error_o),
    .valE_o(valE_i),
    .valM_o(valM_i),
    .stat_o(stat_o)
);


/*
    pc_update module
*/

pc_update pc_update_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .instr_valid_i(instr_valid_o),
    .cnd_i(cnd_o),
    .icode_i(icode_o),
    .valC_i(valC_o),
    .valP_i(valP_o),
    .valM_i(valM_o),
    .pc_o(PC_i)
);





//// test code
// initial begin
//     rst_n_i=0;
//     #1 rst_n_i=1;
//     #10 PC_i=64'D0; 
//     $monitor("Time=%0t|PC=%4d|icode=%h|ifun=%h|rA=%h|rB=%h|valA=%h|valB=%h|valC=%h|valE=%h|valP=%h|instr_valid=%h|imem_error_o=%h|cnd=%h|npc=%d.",
//                 $time, PC_i, icode_o, ifun_o,rA_o, rB_o, valA_o, valB_o,valC_o,valE_o, valP_o, instr_valid_o,imem_error_o,cnd_o,pc_o);
//     #10 PC_i=64'D10;
//     #10 PC_i=64'D20;
//     #10 PC_i=64'D22;
//     #10 PC_i=64'D24;
//     #10 PC_i=64'D26;
//     #10 PC_i=64'D28;
//     #10 PC_i=64'D30;
//     #10 PC_i=64'D32;
//     #10 PC_i=64'D42;
//     #10 PC_i=64'D44;
//     #10 PC_i=64'D46;
//     #10 PC_i=64'D56;
//     #10 PC_i=64'D66;
//     #10 PC_i=64'D80;
//     #10 PC_i=64'D82;
//     #10 PC_i=64'D96;
//     #10 PC_i=64'D128;
//     #10 PC_i=64'D105;
//     #10 PC_i=64'D129;
// end


endmodule