`include "define.v"
module writeback(
    input wire clk_i,
    input wire rst_n_i,
    input wire stall_i,
    input wire bubble_i,

    input wire [3:0] icode_i,
    input wire [63:0] valE_i,
    input wire [63:0] valM_i,
    input wire [3:0] dstE_i,
    input wire [3:0] dstM_i,
    output wire [3:0] stat_i,

    output wire [63:0] valM_o,
    output wire [63:0] valE_o,
    output wire [3:0] dstE_o,
    output wire [3:0] dstM_o,
    output wire [3:0] icode_o,
    output wire [3:0] stat_o
);
reg[2:0]stat;
reg[3:0]icode;

reg[63:0]valE;
reg[63:0]valM;

reg[3:0]dstE;
reg[3:0]dstM;

always@(posedge clk_i)begin 
    if(~rst_n_i)begin
        stat<=`STAT_RESET;
        icode<=0;
        valE<=0;
        valM<=0;
        dstE<=0;
        dstM<=0;
    end else if(stall_i)begin 
        stat<=`STAT_STALL;
    end else if(bubble_i)begin 
        stat<=`STAT_BUBBLE;
        icode<=0;
        valE<=0;
        valM<=0;
        dstE<=0;
        dstM<=0;
    end else begin 
        stat<=`STAT_OK;
        icode<=icode_i;
        valE<=valE_i;
        valM<=valM_i;
        dstE<=dstE_i;
        dstM<=dstM_i;
    end
end

assign valE_o=valE;
assign valM_o=valM;//与之前有不同，需要之前的检查正确性！
assign dstE_o=dstE_i;
assign dstM_o=dstM_i;
assign icode_o=icode_i;
assign stat_o=stat_i;

endmodule