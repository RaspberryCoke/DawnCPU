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


endmodule