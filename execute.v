`include "define.v"
module execute(
    input wire clk_i,
    input wire rst_n_i,

    input wire[3:0] icode_i,
    input wire [3:0] ifun_i,

    input wire signed[63:0] valA_i,
    input wire signed[63:0] valB_i,
    input wire signed[63:0] valC_i,

    output reg signed[63:0] valE_o,

    output wire Cnd_o
);

reg [63:0] aluA;
reg[63:0] aluB;
reg [3:0] alu_fun;
reg[2:0]new_cc;
reg[2:0]cc;
wire set_cc;
wire sf;
wire of;
wire zf;
assign of=cc[0];
assign sf=cc[1];
assign zf=cc[2];

assign set_cc=icode_i==`IOPQ;

always @(*) begin
    case (icode_i)
        `ICMOVQ:begin 
            aluA=valA_i;
           aluB=0; 
        end
        `IIRMOVQ:begin 
            aluA=valC_i;
            aluB=0;
        end
        `IRMMOVQ:begin 
            aluA=valC_i;
            aluB=valB_i;
        end
        `IMRMOVQ:begin 
            aluA=valC_i;
            aluB=valB_i;
        end
        `IOPQ:begin 
            aluA=valA_i;
            aluB=valB_i;
        end
        `ICALL:begin 
            aluA=-8;
            aluB=valB_i;
        end
        `IRET:begin 
            aluA=8;
            aluB=valB_i;
        end
        `IPUSHQ:begin 
            aluA=-8;
            aluB=valB_i;
        end
        `IPOPQ:begin 
            aluA=8;
            aluB=valB_i;
        end

        default:begin 
            aluA=0;
            aluB=0;
        end
    endcase
end

always@(*)begin
    if(icode_i==`IOPQ)
        alu_fun=ifun_i;
    else
        alu_fun=`ALUADD;
end

always@(*)begin 
    case(alu_fun)
        `ALUADD:begin 
            valE_o=aluA+aluB;
        end
        `ALUSUB:begin 
            valE_o=aluB-aluA;
        end
        `ALUAND:begin 
            valE_o=aluA& aluB;
        end
        `ALUXOR:begin 
            valE_o=aluA^aluB;
        end
    endcase
end

always@(*)begin 
    if(~rst_n_i)begin 
        new_cc[2]=1;
        new_cc[1]=0;
        new_cc[0]=0;
    end
    else if(alu_fun==`FADDL)begin 
        new_cc[2]=(valE_o==0)?1:0;
        new_cc[1]=valE_o[63];
        if(alu_fun==`ALUADD)begin 
            new_cc[0]=(aluA[63]==aluB[63])&(aluA[63]!=valE_o[63]);
        end
        else if(alu_fun==`ALUSUB)begin 
            new_cc[0]=(~aluA[63]==aluB[63])&(aluB[63]!=valE_o[63]);
        end else new_cc[0]=0;
    end
end

assign set_cc=(icode_i==`IOPQ)?1:0;

always@(posedge clk_i)begin 
    if(~rst_n_i)
        cc<=3'b100;
    else if(set_cc)
        cc<=new_cc;
end


assign Cnd_o=
    (ifun_i==`C_YES)|
    (ifun_i==`C_LE & ((sf^of)|zf))|
    (ifun_i==`C_L &(sf^of))|
    (ifun_i==`C_E & zf)|
    (ifun_i==`C_NE & ~zf)|
    (ifun_i==`C_GE & ~(sf ^ of))|
    (ifun_i==`C_G & (~(sf ^ of)&~zf));

endmodule