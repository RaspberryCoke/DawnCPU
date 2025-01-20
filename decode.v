`include "define.v"

module decode(
    input wire clk_i,
    input wire rst_n_i,

    input [3:0] rA,
    input [3:0] rB,
    input [3:0] icode,

    input wire[63:0] valE_i,
    input wire[63:0] valM_i,

    //input wire cnd_i,

    output wire[63:0] valA_o,
    output wire[63:0] valB_o
);


reg [3:0] srcA=0;
reg [3:0] srcB=0;
reg [3:0] dstE=0;
reg [3:0] dstM=0;

always@(*)begin
    case(icode)
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
            srcA=rA;
            srcB=rB;
            dstE=rB;
            dstM=4'hf;
        end

        `IIRMOVQ:begin 
            srcA=4'hf;
            srcB=rB;
            dstE=rB;
            dstM=4'hf;
        end

        `IRMMOVQ:begin 
            srcA=rA;
            srcB=rB;
            dstE=4'hf;
            dstM=4'hf;
        end

        `IMRMOVQ:begin 
            srcA=rA;
            srcB=rB;
            dstE=4'hf;
            dstM=rA;
        end

        `IOPQ:begin 
            srcA=rA;
            srcB=rB;
            dstE=rB;
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
            srcA=rA;
            srcB=4'hf;
            dstE=4'h4;
            dstM=4'hf;
        end

        `IPOPQ:begin 
            srcA=rA;
            srcB=4'hf;
            dstE=4'h4;
            dstM=rA;
        end

        default: begin 
            srcA=4'hf;
            srcB=4'hf;
            dstE=4'hf;
            dstM=4'hf;
        end

    endcase


end


// //假设这里是 r0 r1 r2 r3 .... r14
// reg [63:0] regfile[14:0];
// module regs(
//     input clk_i,
//     input [3:0] srcA,
//     input [3:0] srcB,
//     input [3:0] dstA,
//     input [3:0] dstB,
//     input [63:0] dstA_data,
//     input [63:0] dstB_data,

//     output  [63:0] valA,
//     output  [63:0] valB
// );

regs regfile(
    .clk_i(clk_i),
    .srcA(srcA),
    .srcB(srcB),
    .dstA(dstE),
    .dstB(dstM),
    .dstA_data(valE_i),
    .dstB_data(valM_i),
    .valA(valA),
    .valB(valB)
);

endmodule
