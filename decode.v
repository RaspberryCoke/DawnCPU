`include "define.v"

module decode(
    input wire clk_i,
    input wire rst_n_i,
    input wire decode_stall_i,
    input wire decode_bubble_i,

    input [3:0] D_icode_i,
    input [3:0] D_rA_i,
    input [3:0] D_rB_i,
    input [63:0] D_valP_i,
    input [2:0] D_stat_i,

    input wire[3:0] e_dstE_i,//前递
    input wire[63:0] e_valE_i,
    input wire[3:0] M_dstM_i,
    input wire[63:0] m_valM_i,
    input wire[3:0] M_dstE_i,
    input wire[63:0] M_valE_i,//

    input wire[3:0] W_dstM_i,
    input wire[63:0] W_valM_i,
    input wire[3:0] W_dstE_i,
    input wire[63:0] W_valE_i,//


    output wire[63:0] d_valA_o,//综合考虑之后输出的值。fwdA_valA_o
    output wire[63:0] d_valB_o,//综合考虑之后输出的值。fwdA_valB_o
    output wire[3:0] d_dstE_o,
    output wire[3:0] d_dstM_o,
    output wire[3:0] d_srcA_o,
    output wire[3:0] d_srcB_o,
    output wire[2:0] d_stat_o
);
wire[63:0]d_rvalA;
wire[63:0]d_rvalB;
wire[63:0]fwdA_valA_o;
wire[63:0]fwdA_valB_o;
reg [63:0] regfile[14:0];

assign d_srcA_o=(D_icode_i==`IRRMOVQ || D_icode_i==`IRMMOVQ ||
                D_icode_i==`IOPQ ||D_icode_i==`IPUSHQ )?D_rA_i:
                (D_icode_i==`IPOPQ || D_icode_i==`IRET)?`RRSP:`RNONE;
assign d_srcB_o=(D_icode_i==`IOPQ ||D_icode_i==`IRMMOVQ ||D_icode_i==`IMRMOVQ)?D_rB_i:
                (D_icode_i==`ICALL||D_icode_i==`IPUSHQ||D_icode_i==`IRET)?`RRSP:`RNONE;
assign d_dstE_o=(D_icode_i==`IRRMOVQ||D_icode_i==`IIRMOVQ||D_icode_i==`IOPQ)?D_rB_i:
                (D_icode_i==`IPUSHQ||D_icode_i==`IPOPQ||
                D_icode_i==`ICALL||D_icode_i==`IRET)?`RRSP:`RNONE;
assign d_dstM_o=(D_icode_i==`IMRMOVQ||D_icode_i==`IPOPQ)?D_rA_i:`RNONE;
assign d_rvalA=(d_srcA_o==`RNONE)?64'b0:regfile[d_srcA_o];
assign d_rvalB=(d_srcB_o==`RNONE)?64'b0:regfile[d_srcB_o];



assign fwdA_valA_o=((D_icode_i==`ICALL || D_icode_i==`IJXX)?D_valP_i:
                    (d_srcA_o==e_dstE_i)?e_valE_i:
                    (d_srcA_o==M_dstM_i)?m_valM_i:
                    (d_srcA_o==M_dstE_i)?M_valE_i:
                    (d_srcA_o==W_dstM_i)?W_valM_i:
                    (d_srcA_o==W_dstE_i)?W_valE_i:d_rvalA);

assign fwdA_valB_o=(d_srcB_o==e_dstE_i)?e_valE_i:
                    (d_srcB_o==M_dstM_i)?m_valM_i:
                    (d_srcB_o==M_dstE_i)?M_valE_i:
                    (d_srcB_o==W_dstM_i)?W_valM_i:
                    (d_srcB_o==W_dstE_i)?W_valE_i:d_rvalB;
assign d_valA_o=fwdA_valA_o;
assign d_valB_o=fwdA_valB_o;

assign d_stat_o=D_stat_i;

integer i;
always@(posedge clk_i)begin 

    if(~rst_n_i)begin 
        for(i=0;i<14;i=i+1)begin 
            regfile[i]<=64'b0;//注意这里的初始化赋值，和之前的单周期不一样。
        end
    end else if(!decode_stall_i) begin 
        if(W_dstE_i!=`RNONE)begin 
            regfile[W_dstE_i]=W_valE_i;
        end 
        if(W_dstM_i!=`RNONE)begin 
            regfile[W_dstM_i]=W_valM_i;
        end
    end
end

endmodule
