`include "define.v"

module decode(
    input wire clk_i,
    input wire rst_n_i,

    input [3:0] rA_i,
    input [3:0] rB_i,
    input [3:0] icode_i,

    input wire[63:0] valE_i,
    input wire[63:0] valM_i,

    output wire[63:0] valA_o,
    output wire[63:0] valB_o
);

reg [63:0] regfile[14:0];  //regfile

integer i;

always@(negedge rst_n_i)begin 
    $display("decode.v: regfile initial...");
    for(i=0;i<15;i=i+1)begin
        regfile[i]<=i;
    end
end



//这里千万不要赋初值为0，否则导致竞态。访问0号寄存器失败。
reg [3:0] srcA;
reg [3:0] srcB;
reg [3:0] dstE;
reg [3:0] dstM;



always@(*)begin
    $display($time,".decode.v running.icode:%h.",icode_i);
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

always@(posedge clk_i)begin 
    if(dstE!=4'hf)begin
        regfile[dstE]<=valE_i;
    end
    if(dstM!=4'hf)begin
        regfile[dstM]<=valM_i;
    end
end

endmodule
