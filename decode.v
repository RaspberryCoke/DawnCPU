`include "define.v"

module decode(
    input wire clk_i,
    input wire rst_n_i,

    input [3:0] rA_i,
    input [3:0] rB_i,
    input [3:0] icode_i,

    input wire[63:0] valE_i,
    input wire[63:0] valM_i,

    //input wire cnd_i,

    output wire[63:0] valA_o,
    output wire[63:0] valB_o
);

reg [63:0] regfile[14:0];  //regfile

integer i;

always@(negedge rst_n_i)begin 
    $display("regs.v: initial...");
    for(i=0;i<15;i=i+1)begin
        regfile[i]<=64'b0;
    end
end




reg [3:0] srcA=0;
reg [3:0] srcB=0;
reg [3:0] dstE=0;
reg [3:0] dstM=0;

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
            srcB=rB_i;
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
            srcB=4'hf;
            dstE=4'h4;
            dstM=4'hf;
        end

        `IRET:begin 
            srcA=4'hf;
            srcB=4'hf;
            dstE=4'h4;
            dstM=4'hf;
        end

        `IPUSHQ:begin 
            srcA=rA_i;
            srcB=4'hf;
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


assign valA_o=(rA_i==4'hf)?64'b0:regfile[rA_i];
assign valB_o=(rB_i==4'hf)?64'b0:regfile[rB_i];

always@(posedge clk_i)begin 
    if(dstE!=4'hf)begin
        regfile[dstE]<=valE_i;
    end
    if(dstM!=4'hf)begin
        regfile[dstM]<=valM_i;
    end
end

endmodule
