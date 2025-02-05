`timescale 1ns/1ps
module test_fetch();

reg clk_i;
reg rst_n_i;

initial begin 
    clk_i=0;
    rst_n_i=0;
    $display("reg=%d",f_reg.predPC);
    #1 clk_i=1;
    #1 rst_n_i=1;
    $display("reg=%d",f_reg.predPC);
    #8 $display("----------begin--------");
    forever begin
        #10 clk_i=~clk_i;
        $monitor("Time=%0t|F_predPC_o=%4d|f_reg=%4d|f_pc_o=%4d|icode=%h|ifun=%h|rA=%h|rB=%h.",
        $time, F_predPC_o,f_reg.predPC,f_pc_o,f_icode_o, f_ifun_o,f_rA_o, f_rB_o);
    end
end

initial begin
    #100 $finish;
end

wire F_stall_i;
wire F_bubble_i;
wire [63:0] F_predPC_o;//初始化为0
wire [63:0] f_predPC_o;//初始化为0
assign F_stall_i=0;
assign F_bubble_i=0;

F_pipe_reg f_reg(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .F_stall_i(F_stall_i),
    .F_bubble_i(F_bubble_i),
    .f_predPC_i(f_predPC_o),
    .F_predPC_o(F_predPC_o)
);

wire [3:0] M_icode_o;
wire [3:0] W_icode_o;
wire [63:0] M_valA_o;
wire [63:0] W_valM_o;
wire [63:0] f_pc_o;//输出，为最后的PC值。
wire M_cnd_o;

assign M_icode_o=4'b0;
assign W_icode_o=4'b0;
assign M_valA_o=64'b0;
assign W_valM_o=64'b0;
assign M_cnd_o=0;

//时序逻辑，f_pc_o=F_predPC_o
select_pc select_pc_module  (
    .F_predPC_i(F_predPC_o),
    .M_icode_i(M_icode_o),//=0
    .W_icode_i(W_icode_o),//=0
    .M_valA_i(M_valA_o),//ignore
    .W_valM_i(W_valM_o),//ignore
    .M_cnd_i(M_cnd_o),//=0
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
assign D_stall_i=0;
wire D_bubble_i;
assign D_bubble_i=0;
wire[3:0]D_icode_o;
wire[3:0]D_ifun_o;
wire[63:0]D_valC_o;
wire[63:0]D_valP_o;
wire[63:0]D_pc_o;
wire[2:0]D_stat_o;
wire[3:0]D_rA_o;
wire[3:0]D_rB_o;


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
assign e_dstE_o=4'b0;
wire[63:0] e_valE_o;
assign e_valE_o=64'b0;
wire[3:0] M_dstM_o;
assign M_dstM_o=4'b0;
wire[63:0] m_valM_o;
assign m_valM_o=64'b0;
wire[3:0] M_dstE_o;
assign M_dstE_o=4'b0;
wire[63:0] M_valE_o;
assign M_valE_o=64'b0;
wire[3:0] W_dstM_o;
assign W_dstM_o=4'b0;
//wire[63:0] W_valM_o;//已存在
wire[3:0] W_dstE_o;
assign W_dstE_o=4'b0;
wire[63:0] W_valE_o;
assign W_valE_o=64'b0;
wire decode_stall_i;
assign decode_stall_i=0;
wire decode_bubble_i;
assign decode_bubble_i=0;

wire[63:0] d_valA_o;
wire[63:0] d_valB_o;
wire[3:0] d_dstE_o;
wire[3:0] d_dstM_o;
wire[3:0] d_srcA_o;
wire[3:0] d_srcB_o;
wire[2:0] d_stat_o;

decode decode_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
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

endmodule