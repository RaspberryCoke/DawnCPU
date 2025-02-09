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
    input wire [2:0] stat_i,

    output wire [63:0] valM_o,
    output wire [63:0] valE_o,
    output wire [3:0] dstE_o,
    output wire [3:0] dstM_o,
    output wire [3:0] icode_o,
    output wire [2:0] stat_o
);
reg[2:0]stat;
reg[3:0]icode;

reg[63:0]valE;
reg[63:0]valM;

reg[3:0]dstE;
reg[3:0]dstM;

always@(posedge clk_i)begin 
    if(~rst_n_i)begin
        stat<=`SAOK;
        icode<=`INOP;
        valE<=0;
        valM<=0;
        dstE<=`RNONE;
        dstM<=`RNONE;
    end else if(bubble_i)begin 
        stat<=`SAOK;
        icode<=`INOP;
        valE<=0;
        valM<=0;
        dstE<=`RNONE;
        dstM<=`RNONE;
    end else if(~stall_i) begin 
        stat<=stat_i;
        icode<=icode_i;
        valE<=valE_i;
        valM<=valM_i;
        dstE<=dstE_i;
        dstM<=dstM_i;
    end
end

assign valE_o=valE;
assign valM_o=valM;//与之前有不同，需要之前的检查正确性！
assign dstE_o=dstE;
assign dstM_o=dstM;
assign icode_o=icode;
assign stat_o=stat;//


//触发条件：icode_o==`IHALT ,  PC_i改变
always@(*)begin 
    //$display($time,".fetch.v running.PC_i:%h.icode:%h.",PC_i,icode_o);
    if(icode==`IHALT)begin 
        $display($time,".fetch.v IHALT.icode:%h.",icode);
        $display($time,".HALT.");
        $display("");
        $display("----------------.HALT.------------------");
        $display("-----------.Succeed to HALT.-------------");
        $display("-----------------------------------------");
        $display("------------Congratulations!-------------");
        $display("");
        $stop;
    end
end


endmodule