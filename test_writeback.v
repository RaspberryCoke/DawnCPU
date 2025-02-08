`include"define.v"
`timescale 1ns/1ps
module test_writeback();

reg clk_i;
reg rst_n_i;

integer reg_i;

initial begin 
    #1 clk_i=0;
    #1 rst_n_i=0;

    
    #1 clk_i=1;
    #1 rst_n_i=1;
    #1 clk_i=0;

    #5 $display("----------begin--------");
    forever begin
        
        $display("\n\nTime=%0t\nFetch:\t\tF_stall_i=%1d\nf_icode_o=%4h|f_ifun_o=%4h|f_rA_o=%4h|f_rB_o=%4h\nF_predPC_o=%4d|f_reg=%4d|f_pc_o=%4d\nf_valC_o=%4d|f_valP_o=%4d\n",
            $time, F_stall_i,f_icode_o, f_ifun_o,f_rA_o, f_rB_o,F_predPC_o,f_reg.predPC,f_pc_o,f_valC_o,f_valP_o);

        $display("Decode:\t\tD_stall_i=%1d|D_bubble_i=%1d\nD_stat_o=%4d\nD_icode_o=%4d|D_ifun_o=%4d|D_rA_o=%4d|D_rB_o=%4d\nD_valC_o=%4d|D_valP_o=%4d|D_pc_o=%4d",
            D_stall_i,D_bubble_i,D_stat_o,D_icode_o,D_ifun_o,D_rA_o,D_rB_o,D_valC_o,D_valP_o,D_pc_o);

        $display("d_valA_o=%4d|d_valB_o=%4d|d_dstE_o=%4d|d_dstM_o=%4d|d_srcA_o=%4d|d_srcB_o=%4d\n",d_valA_o,d_valB_o,d_dstE_o,d_dstM_o,d_srcA_o,d_srcB_o);
        $display("FORWARDING:\nW_dstM_o=%4d|W_valM_o=%4d|W_dstE_o=%4d|W_valE_o=%4d\n",W_dstM_o,W_valM_o,W_dstE_o,W_valE_o);

        $display("Execute:\t\tE_bubble_i=%1d\nE_stat_o=%4d|e_stat_o=%4d|cc_debug_o=%4d\nE_icode_o=%4d|E_ifun_o=%4d|E_dstE_o=%4d|E_valA_o=%4d|E_valB_o=%4d|E_valC_o=%4d\ne_valE_o=%4d|e_dstE_o=%4d|e_cnd_o=%4d\n",
            E_bubble_i,E_stat_o ,e_stat_o,cc_debug_o,E_icode_o,E_ifun_o,E_dstE_o,E_valA_o,E_valB_o,E_valC_o,e_valE_o,e_dstE_o,e_cnd_o);

        $display("Memory:\t\tM_bubble_i=%1d\nM_stat_o=%1d\nm_stat_o=%1d\nM_icode_o=%4d|m_valM_o=%4d|M_valE_o=%4d\nM_dstE_o=%4d|M_dstM_o=%4d|M_valA_o=%4d|M_pc_o=%4d\n",
                    M_bubble_i,M_stat_o,m_stat_o,M_icode_o,m_valM_o,M_valE_o,M_dstE_o,M_dstM_o,M_valA_o,M_pc_o);

        $display("WriteBack:\t\tW_stall_i=%1d\nW_stat_o=%1d\nW_icode_o=%4d|W_valM_o=%4d|W_valE_o=%4d|W_dstE_o=%4d|W_dstM_o=%4d\n",
        W_stall_i,W_stat_o,W_icode_o,W_valM_o,W_valE_o,W_dstE_o,W_dstM_o);

        $display("controller:\nD_icode_o=%4d|d_srcA_o=%4d|d_srcB_o=%4d\nE_icode_o=%4d|E_dstM_o=%4d|e_cnd_o=%4d\nM_icode_o=%4d|m_stat_o=%1d|W_stat_o=%4d\n"
        ,D_icode_o,d_srcA_o,d_srcB_o,E_icode_o,E_dstM_o,e_cnd_o,M_icode_o,m_stat_o,W_stat_o);

        for(reg_i=0;reg_i<16;reg_i=reg_i+1)begin
            $display("r%d--%d",reg_i,decode_module.regfile[reg_i]);
        end

        #5 clk_i=~clk_i;
        #5 clk_i=~clk_i;
    end
end

initial begin
    #600 $finish;
end

wire F_stall_i;
wire F_bubble_i;
assign F_bubble_i=0;
wire [63:0] F_predPC_o;//初始化为0
wire [63:0] f_predPC_o;//初始化为0


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
wire D_bubble_i;
wire[3:0]D_icode_o;
wire[3:0]D_ifun_o;
wire[63:0]D_valC_o;
wire[63:0]D_valP_o;
wire[63:0]D_pc_o;
wire[2:0]D_stat_o;
wire[3:0]D_rA_o;
wire[3:0]D_rB_o;


fetch_D_pipe_reg  D_reg (
    .clk_i(clk_i),//有确切值
    .rst_n_i(rst_n_i),
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
    .D_valP_o(D_valP_o)//
);


wire[3:0] e_dstE_o;//前递
wire[63:0] e_valE_o;
wire[3:0] M_dstM_o;
wire[63:0] m_valM_o;
wire[3:0] M_dstE_o;
wire[63:0] M_valE_o;
wire[3:0] W_dstM_o;
//wire[63:0] W_valM_o;//已存在
wire[3:0] W_dstE_o;
wire[63:0] W_valE_o;
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
    .W_dstM_i(W_dstM_o),//
    .W_valM_i(W_valM_o),
    .W_dstE_i(W_dstE_o),
    .W_valE_i(W_valE_o),//
    
    
    .d_valA_o(d_valA_o),
    .d_valB_o(d_valB_o),
    .d_dstE_o(d_dstE_o),
    .d_dstM_o(d_dstM_o),
    .d_srcA_o(d_srcA_o),
    .d_srcB_o(d_srcB_o),
    .d_stat_o(d_stat_o)//这个是可能会变的.不对，应该不会变。多余。
);

/*
    execute module
*/
// decode_E_pipe_reg Inputs
wire E_stall_i;
assign E_stall_i=0;
wire E_bubble_i;
// decode_E_pipe_reg Outputs
wire[2:0]E_stat_o;
wire[63:0]E_pc_o;
wire[3:0]E_icode_o;
wire[3:0]E_ifun_o;
wire[63:0]E_valA_o;
wire[63:0]E_valB_o;
wire[63:0]E_valC_o;
wire[3:0]E_dstE_o;
wire[3:0]E_dstM_o;
wire[3:0]E_srcA_o;
wire[3:0]E_srcB_o;

decode_E_pipe_reg  E_reg (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .E_stall_i(E_stall_i),
    .E_bubble_i(E_bubble_i),

    .d_stat_i(D_stat_o),
    .d_pc_i(D_pc_o),
    .d_icode_i(D_icode_o),
    .d_ifun_i(D_ifun_o),
    .d_valC_i(D_valC_o),
    .d_valA_i(d_valA_o),
    .d_valB_i(d_valB_o),
    .d_dstE_i(d_dstE_o),
    .d_dstM_i(d_dstM_o),
    .d_srcA_i(d_srcA_o),
    .d_srcB_i(d_srcB_o),

    .E_stat_o(E_stat_o),
    .E_pc_o(E_pc_o),
    .E_icode_o(E_icode_o),
    .E_ifun_o(E_ifun_o),
    .E_valA_o(E_valA_o),
    .E_valB_o(E_valB_o),
    .E_valC_o(E_valC_o),
    .E_dstE_o(E_dstE_o),
    .E_dstM_o(E_dstM_o),
    .E_srcA_o(E_srcA_o),
    .E_srcB_o(E_srcB_o)
);

wire[2:0]m_stat_o;
wire[2:0]W_stat_o;
wire[2:0]e_stat_o;

wire e_cnd_o;
wire [2:0]cc_debug_o;

execute execute_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .execute_stall_i(E_stall_i),
    .execute_bubble_i(E_bubble_i),

    .icode_i(E_icode_o),
    .ifun_i(E_ifun_o),
    .stat_i(E_stat_o),
    .E_dstE_i(E_dstE_o),

    .valA_i(E_valA_o),
    .valB_i(E_valB_o),
    .valC_i(E_valC_o),

    .m_stat_i(m_stat_o),
    .W_stat_i(W_stat_o),

    .valE_o(e_valE_o),
    .dstE_o(e_dstE_o),
    .e_cnd_o(e_cnd_o),
    .stat_o(e_stat_o),
    .cc_debug(cc_debug_o)
);



// execute_M_pipe_reg Inputs

wire   M_stall_i;
assign M_stall_i=0;
wire   M_bubble_i;
//wire[2:0]e_stat_o;已存在、、、、、、、


// execute_M_pipe_reg Outputs
wire [2:0]M_stat_o;
wire [63:0]M_pc_o;
//wire [3:0]M_icode_o;已存在
wire [3:0]M_ifun_o;
//wire  M_cnd_o;已存在
//wire [63:0]M_valE_o;已存在
//wire  [63:0]M_valA_o;已存在
//wire [3:0]M_dstE_o;已存在
//wire  [3:0]M_dstM_o;已存在

execute_M_pipe_reg  M_reg (
    .clk_i( clk_i),
    .rst_n_i( rst_n_i),
    .M_stall_i( M_stall_i),
    .M_bubble_i( M_bubble_i),

    .e_stat_i(E_stat_o),
    .e_pc_i(E_pc_o),
    .e_icode_i(E_icode_o),
    .e_ifun_i(E_ifun_o),
    .e_cnd_i(e_cnd_o),
    .e_valE_i(e_valE_o),
    .e_valA_i(E_valA_o),
    .e_dstE_i(e_dstE_o),
    .e_dstM_i(E_dstM_o),

    .M_stat_o(M_stat_o),
    .M_pc_o(M_pc_o),
    .M_icode_o(M_icode_o),
    .M_ifun_o(M_ifun_o),
    .M_cnd_o(M_cnd_o),
    .M_valE_o(M_valE_o),
    .M_valA_o(M_valA_o),
    .M_dstE_o(M_dstE_o),
    .M_dstM_o(M_dstM_o)
);

wire [3:0]   m_icode_o;
wire [63:0]   m_valE_o;
wire [63:0]   m_valA_o;
wire [3:0]   m_dstE_o;
wire [3:0]   m_dstM_o;

memory_access memory_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .stall_i(M_stall_i),
    .bubble_i(M_bubble_i),

    .icode_i(M_icode_o),
    .stat_i(M_stat_o),

    .valA_i(M_valA_o),
    .valE_i(M_valE_o),
    .dstE_i(M_dstE_o),
    .dstM_i(M_dstM_o),
    .cnd_i(M_cnd_o),

    .icode_o(m_icode_o),
    .stat_o(m_stat_o),
    .valM_o(m_valM_o),
    .valE_o(m_valE_o),//
    .dstE_o(m_dstE_o),
    .dstM_o(m_dstM_o),
    .M_valA_o(m_valA_o)
);

wire W_stall_i;
wire W_bubble_i;
assign W_bubble_i=0;

writeback writeback_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .stall_i(W_stall_i),
    .bubble_i(W_bubble_i),

    .icode_i(m_icode_o),
    .valE_i(M_valE_o),
    .valM_i(m_valM_o),
    .dstE_i(M_dstE_o),
    .dstM_i(M_dstM_o),
    .stat_i(m_stat_o),

    .valM_o(W_valM_o),
    .valE_o(W_valE_o),
    .dstE_o(W_dstE_o),
    .dstM_o(W_dstM_o),
    .icode_o(W_icode_o),
    .stat_o(W_stat_o)
);


controller controller_module(
    .D_icode_i(D_icode_o),
    .d_srcA_i(d_srcA_o),
    .d_srcB_i(d_srcB_o),
    .E_icode_i(E_icode_o),
    .E_dstM_i(E_dstM_o),
    .e_Cnd_i(e_cnd_o),
    .M_icode_i(M_icode_o),
    .m_stat_i(m_stat_o),
    .W_stat_i(W_stat_o),
    .F_stall_o(F_stall_i),
    .D_bubble_o(D_bubble_i),
    .D_stall_o(D_stall_i),
    .E_bubble_o(E_bubble_i),
    .M_bubble_o(M_bubble_i),
    .W_stall_o(W_stall_i)
);


endmodule