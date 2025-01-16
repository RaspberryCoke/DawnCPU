`include "define.v"

module decode(
    input [3:0] rA,
    input [3:0] rB,
    input [3:0] icode,


    output [63:0] valA,
    output [63:0] valB
);

//假设这里是 r0 r1 r2 r3 .... r14
reg [63:0] regfile[14:0];

reg [3:0] srcA=0;
reg [3:0] srcB=0;

always@(*)begin
    case(icode)
        `IHALT:begin 
            srcA=4'hf;
            srcB=4'hf;
        end

        `INOP:begin 
           srcA=4'hf;
           srcB=4'hf;
        end

        `IRRMOVQ:begin 
            srcA=rA;
            srcB=rB;
        end

        `IIRMOVQ:begin 
            srcA=4'hf;
            srcB=rB;
        end

        `IRMMOVQ:begin 
            srcA=rA;
            srcB=rB;
        end

        `IMRMOVQ:begin 
            srcA=rA;
            srcB=rB;
        end

        `IOPQ:begin 
            srcA=rA;
            srcB=rB;
        end

        `IJXX:begin 
            srcA=4'hf;
            srcB=4'hf;
        end

        `ICALL:begin 
            srcA=4'hf;
            srcB=4'hf;
        end

        `IRET:begin 
            srcA=4'hf;
            srcB=4'hf;
        end

        `IPUSHQ:begin 
            srcA=rA;
            srcB=4'hf;
        end

        `IPOPQ:begin 
            srcA=rA;
            srcB=4'hf;
        end

        default: begin 
            srcA=4'hf;
            srcB=4'hf;
        end

    endcase


end

assign valA=(srcA==4'hf)?64'b0:regfile[srcA];
assign valB=(srcB==4'hf)?64'b0:regfile[srcB];

    
endmodule
