`include "define.v"

module decode(
    input wire clk_i,

    input [3:0] D_icode_i,
    input [3:0] D_rA_i,
    input [3:0] D_rB_i,
    input [63:0] D_valP_i,

    input wire[3:0] e_dstE_i,
    input wire[63:0] e_valE_i,
    input wire[3:0] M_dstM_i,
    input wire[63:0] m_valM_i,
    input wire[3:0] M_dstE_i,
    input wire[63:0] M_valE_i,
    input wire[3:0] W_dstM_i,
    input wire[63:0] W_valM_i,
    input wire[3:0] W_dstE_i,
    input wire[63:0] W_valE_i,


    output wire[63:0] d_valA_o,
    output wire[63:0] d_valB_o,
    output wire[3:0] d_dstE_o,
    output wire[3:0] d_dstM_o,
    output wire[3:0] d_srcA_o,
    output wire[3:0] d_srcB_o
);
wire[63:0]d_rvalA;
wire[63:0]d_rvalB;
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

assign d_valA_o=d_rvalA;
assign d_valB_o=d_rvalB;
endmodule
