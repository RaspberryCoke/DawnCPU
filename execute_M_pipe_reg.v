`include "define.v"
module execute_M_pipe_reg(
    input wire clk_i,
    input wire M_stall_i,
    input wire M_bubble_i,

    input wire[2:0]e_stat_i,
    input wire[63:0]e_pc_i,
    input wire[3:0]e_icode_i,
    input wire[3:0]e_ifun_i,
    input wire      e_cnd_i,
    input wire[63:0]e_valE_i,
    input wire[63:0]e_valA_i,
    input wire[3:0]e_dstE_i,
    input wire[3:0]e_dstM_i,

    output reg[2:0]M_stat_o,
    output reg[63:0]M_pc_o,//?
    output reg[3:0]M_icode_o,
    output reg[3:0]M_ifun_o,
    output reg      M_cnd_o,
    output reg[63:0]M_valE_o,
    output reg[63:0]M_valA_o,
    output reg[3:0]M_dstE_o,
    output reg[3:0]M_dstM_o
);

always@(posedge clk_i)begin
    if(M_bubble_i)begin 
        M_stat_o<=e_stat_i;//?
        M_pc_o<=64'b0;
        M_icode_o<=`INOP;
        M_ifun_o<=4'b0;
        M_cnd_o<=1'b0;
        M_valE_o<=64'b0;
        M_valA_o<=64'b0;
        M_dstE_o<=`RNONE;
        M_dstM_o<=`RNONE;
    end 
    else if(~M_stall_i)begin 
        M_stat_o<=e_stat_i;//?
        M_pc_o<=e_pc_i;
        M_icode_o<=e_icode_i;
        M_ifun_o<=e_ifun_i;
        M_cnd_o<=e_cnd_i;
        M_valE_o<=e_valE_i;
        M_valA_o<=e_valA_i;
        M_dstE_o<=e_dstE_i;
        M_dstM_o<=e_dstM_i;
    end
end

endmodule