`timescale 1ns/1ps
module top_pipeline_module();

reg clk_i=1;
reg rst_n_i=1;
wire [63:0] PC_i;

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

wire F_stall_i;
wire F_bubble_i;
wire [63:0] F_predPC_o;
wire [63:0] f_predPC_o;

F_pipe_reg f_reg(
    .clk_i(clk_i),
    .F_stall_i(F_stall_i),
    .F_bubble_i(F_bubble_i),
    .f_predPC_i(f_predPC_o),
    .F_predPC_o(F_predPC_o)
);

wire [3:0] M_icode_o;
wire [3:0] W_icode_o;
wire [63:0] M_valA_o;
wire [63:0] W_valM_o;
wire [63:0] f_pc_o;
wire [2:0] M_cnd_o;

select_pc select_pc_module  (
    .F_predPC_i(F_predPC_o),
    .M_icode_i(M_icode_o),
    .W_icode_i(W_icode_o),
    .M_valA_i(M_valA_o),
    .W_valM_i(W_valM_),
    .M_cnd_i(M_cnd_o),
    .f_pc_o(f_pc_o)
);



wire[3:0] f_icode_o;
wire[3:0] f_ifun_o;
wire[3:0] f_rA_o;
wire[3:0] f_rB_o;
wire[63:0] f_valC_o;
wire[63:0] f_valP_o;
wire[2:0] f_stat_o;

fetch fetch_module(
    .PC_i(f_pc_o),
    .icode_o(f_icode_o),
    .ifun_o(f_ifun_o),
    .rA_o(f_rA_o),
    .rB_o(f_rB_o),
    .valC_o(f_valC_o),
    .valP_o(f_valP_o) ,
    .predPC_o(f_predPC_o),
    .stat_o(f_stat_o)
);

/*
    decode module
*/
wire D_stall_i;
wire D_bubble_i;
wire[3:0]D_icode_o;
wire[3:0]D_ifun_o;
wire[63:0]D_valC_o;
wire[63:0]D_valP_o;
wire[63:0]D_pc_o;
wire[2:0]D_stat_o;
wire[3:0]D_rA_o;
wire[3:0]D_rB_o;

wire[63:0]W_valE_o;//new

wire[3:0]M_dstE_o;//new
wire[3:0]M_dstM_o;//new

fetch_D_pipe_reg  D_reg (
    .clk_i(clk_i),
    .D_stall_i(D_stall_i),
    .D_bubble_i(D_bubble_i),

    .f_stat_i(f_stat_o),
    .f_pc_i(f_pc_o),
    .f_icode_i(f_icode_o),
    .f_ifun_i(f_ifun_o),
    .f_rA_i(f_rA_o),
    .f_rB_i(f_rB_o),
    .f_valC_i(f_valC_o),
    .f_valP_i(f_valP_o),

    .D_stat_o(D_stat_o),
    .D_pc_o(D_pc_o),
    .D_icode_o(D_icode_o),
    .D_ifun_o(D_ifun_o),
    .D_rA_o(D_rA_o),
    .D_rB_o(D_rB_o),
    .D_valC_o(D_valC_o),
    .D_valP_o(D_valP_o)
);


wire[3:0] e_dstE_o;//前递
wire[63:0] e_valE_o;
//wire[3:0] M_dstM_o;//已存在
wire[63:0] m_valM_o;
//wire[3:0] M_dstE_o;//已存在
wire[63:0] M_valE_o;
wire[3:0] W_dstM_o;
//wire[63:0] W_valM_o;//已存在
wire[3:0] W_dstE_o;
//wire[63:0] W_valE_o;//已存在//

wire decode_stall_i;
wire decode_bubble_i;

wire[63:0] d_valA_o;
wire[63:0] d_valB_o;
wire[3:0] d_dstE_o;
wire[3:0] d_dstM_o;
wire[3:0] d_srcA_o;
wire[3:0] d_srcB_o;
wire[2:0] d_stat_o;

decode decode_module(
    .clk_i(clk_i),
    //.rst_n_i(rst_n_i),
    .decode_stall_i(decode_stall_i),
    .decode_bubble_i(decode_bubble_i),

    .D_icode_i(D_icode_o),
    .D_rA_i(D_rA_o),
    .D_rB_i(D_rB_o),
    .D_valP_i(D_valP_o),
    .D_stat_i(D_stat_o),

    .e_dstE_i(e_dstE_o),//前递
    .e_valE_i(e_valE_o),
    .M_dstM_i(M_dstM_o),
    .m_valM_i(m_valM_o),
    .M_dstE_i(M_dstE_o),
    .M_valE_i(M_valE_o),
    .W_dstM_i(W_dstM_o),
    .W_valM_i(W_valM_o),
    .W_dstE_i(W_dstE_o),
    .W_valE_i(W_valE_o),//
    
    
    .d_valA_o(d_valA_o),
    .d_valB_o(d_valB_o),
    .d_dstE_o(d_dstE_o),
    .d_dstM_o(d_dstM_o),
    .d_srcA_o(d_srcA_o),
    .d_srcB_o(d_srcB_o),
    .d_stat_o(d_stat_o)//这个是可能会变的
);


/*
    execute module
*/

wire E_stall_i;
wire E_bubble_i;


wire[3:0] E_icode_o;
wire signed[63:0] E_valE_o;
wire [63:0] E_valA_o ;
wire[2:0]E_stat_o;
wire[3:0]E_dstE_o;
wire[3:0]E_dstM_o;
wire E_cnd_o;

execute execute_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .stall_i(E_stall_i),
    .bubble_i(E_bubble_i),

    .icode_i(D_icode_o),
    .ifun_i(D_ifun_o),
    .stat_i(D_stat_o),

    .valA_i(D_valA_o),
    .valB_i(D_valB_o),
    .valC_i(D_valC_o),
    .dstE_i(D_dstE_o),
    .dstM_i(D_dstM_o),
    .srcA_i(D_srcA_o),
    .srcB_i(D_srcB_o),

    .icode_o(E_icode_o),
    .stat_o(E_stat_o),
    .valE_o(E_valE_o),
    .valA_o(E_valA_o),
    .dstE_o(E_dstE_o),
    .dstM_o(E_dstM_o),

    .cnd_o(E_cnd_o)
);


/*
    memory module
*/
wire[3:0] M_icode_o;
wire M_stall_i;
wire M_bubble_i;
wire[2:0]M_stat_o;
wire [63:0]M_valM_o;
wire [63:0]M_valE_o;


memory_access memory_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .stall_i(M_stall_i),
    .bubble_i(M_bubble_i),

    .icode_i(E_icode_o),
    .stat_i(E_stat_o),

    .valA_i(E_valA_o),
    .valE_i(E_valE_o),
    .dstE_i(E_dstE_o),
    .dstM_i(E_dstM_o),
    .cnd_i(E_cnd_o),

    
    //有一条从cnd到fetch的虚线。没写
    .icode_o(M_icode_o),
    .stat_o(M_stat_o),
    .valE_o(M_valE_o),
    .valM_o(M_valM_o),
    .dstE_o(M_dstE_o),
    .dstM_o(M_dstM_o),
    .M_valA_o(M_valA_o)

);


/*
    writeback module
*/

wire W_stall_i;
wire W_bubble_i;




writeback writeback_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .stall_i(W_stall_i),
    .bubble_i(W_bubble_i),

    .icode_i(M_icode_o),
    .valE_i(M_valE_o),
    .valM_i(M_valM_o),
    .dstE_i(M_dstE_o),
    .dstM_i(M_dstM_o),

    .valM_o(W_valM_o),
    .valE_o(W_valE_o)
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