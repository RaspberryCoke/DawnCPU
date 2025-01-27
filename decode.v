`include "define.v"

module decode(
    input wire clk_i,
    input wire rst_n_i,
    input wire stall_i,
    input wire bubble_i,

    input [3:0] rA_i,
    input [3:0] rB_i,
    input [3:0] icode_i,
    input [3:0] ifun_i,
    input [63:0] valC_i,
    input [63:0] valP_i,
    input wire[2:0] stat_i,
    input wire[63:0] W_valE_i,
    input wire[63:0] W_valM_i,

    output wire[3:0] icode_o,
    output wire[3:0] ifun_o,
    output wire[2:0] stat_o,
    output wire[63:0] valA_o,
    output wire[63:0] valB_o,
    output wire[63:0] valC_o,

    output wire[3:0] dstE_o,
    output wire[3:0] dstM_o,
    output wire[3:0] srcA_o,
    output wire[3:0] srcB_o
);

//所有的赋值、赋初值都在always块中完成

reg [3:0] rA;//初始 0xf
reg [3:0] rB;//初始 0xf
reg [3:0] icode;//初始 0x0
reg [3:0] ifun;//初始 0x0
reg [63:0] valC;//初始 0x0
reg [63:0] valP;//初始 0x0
reg [2:0] stat;//初始 0x0



reg [63:0] regfile[14:0];  //regfile //初始 0x0

//这里千万不要赋初值为0xf,更不要为0x0，否则导致竞态。访问0号寄存器失败。
reg [3:0] srcA;//初始 0xf
reg [3:0] srcB;//初始 0xf
reg [3:0] dstE;//初始 0xf
reg [3:0] dstM;//初始 0xf

integer i;

always@(posedge stall_i,bubble_i,clk_i or negedge rst_n_i)begin 
    if(~rst_n_i)begin
        stat<=`STAT_RESET;
        rA<=4'hf;
        rB<=4'hf;
        icode<=0;
        ifun<=0;
        valC<=0;
        valP<=0;
        srcA<=4'hf;
        srcB<=4'hf;
        dstE<=4'hf;
        dstM<=4'hf;
        for(i=0;i<15;i=i+1)begin
            regfile[i]<=0;
        end
    end else if(stall_i)begin 
        stat<=`STAT_STALL;
    end else if(bubble_i)begin 
        stat<=`STAT_BUBBLE;
        rA<=4'hf;
        rB<=4'hf;
        icode<=0;
        ifun<=0;
        valC<=0;
        valP<=0;
        srcA<=4'hf;
        srcB<=4'hf;
        dstE<=4'hf;
        dstM<=4'hf;
        for(i=0;i<15;i=i+1)begin
            regfile[i]<=0;
        end
    end else begin 
        stat<=`STAT_OK;
        rA<=rA_i;
        rB<=rB_i;
        icode<=icode_i;
        ifun<=ifun_i;
        valC<=valC_i;
        valP<=valP_i;
        regfile[dstE]<=W_valE_i;
        regfile[dstM]<=W_valM_i;
    end
end

always@(*)begin
    case(icode_i)
        `IHALT:begin 
            srcA=4'hf;
            srcB=4'hf;
            dstE=4'hf;
            dstM=4'hf;
        end

        `INOP:begin 
           srcA=4'hf;
           srcB=4'hf;
           dstE=4'hf;
           dstM=4'hf;
        end

        `IRRMOVQ:begin 
            srcA=rA_i;
            srcB=4'hf;
            //srcB=rB_i;
            dstE=rB_i;
            dstM=4'hf;
        end

        `IIRMOVQ:begin 
            srcA=4'hf;
            srcB=rB_i;
            dstE=rB_i;
            dstM=4'hf;
        end

        `IRMMOVQ:begin 
            srcA=rA_i;
            srcB=rB_i;
            dstE=4'hf;
            dstM=4'hf;
        end

        `IMRMOVQ:begin 
            srcA=rA_i;
            srcB=rB_i;
            dstE=4'hf;
            dstM=rA_i;
        end

        `IOPQ:begin 
            srcA=rA_i;
            srcB=rB_i;
            dstE=rB_i;
            dstM=4'hf;
        end

        `IJXX:begin 
            srcA=4'hf;
            srcB=4'hf;
            dstE=4'hf;
            dstM=4'hf;
        end

        `ICALL:begin 
            srcA=4'hf;
            srcB=4'h4;
            dstE=4'h4;
            dstM=4'hf;
        end

        `IRET:begin 
            srcA=4'h4;
            srcB=4'h4;
            dstE=4'h4;
            dstM=4'hf;
        end

        `IPUSHQ:begin 
            srcA=rA_i;
            srcB=4'h4;//%rsp
            dstE=4'h4;
            dstM=4'hf;
        end

        `IPOPQ:begin 
            srcA=rA_i;
            srcB=4'hf;
            dstE=4'h4;
            dstM=rA_i;
        end

        default: begin 
            srcA=4'hf;
            srcB=4'hf;
            dstE=4'hf;
            dstM=4'hf;
        end
    endcase
end


assign valA_o=(srcA==4'hf)?64'b0:regfile[srcA];
assign valB_o=(srcB==4'hf)?64'b0:regfile[srcB];
assign icode_o=icode;
assign ifun_o=ifun;
assign stat_o=stat;
assign valC_o=valC;
assign dstE_o=dstE;
assign dstM_o=dstM;
assign srcA_o=srcA;
assign srcB_o=srcB;


endmodule
