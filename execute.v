`include "define.v"
module execute(
    input wire clk_i,
    input wire rst_n_i,
    input wire execute_stall_i,
    input wire execute_bubble_i,

    input wire[3:0] icode_i,
    input wire [3:0] ifun_i,
    input wire[2:0] stat_i,
    input wire[3:0] E_dstE_i,

    input wire signed[63:0]valA_i,
    input wire signed[63:0]valB_i,
    input wire signed[63:0]valC_i,

    input wire[2:0]m_stat_i,
    input wire[2:0]W_stat_i,

    output wire signed[63:0] valE_o,//execute保存的结果
    output wire[3:0]dstE_o,//用作cmov的转移
    output wire e_cnd_o,
    output wire[2:0] stat_o
);
wire [63:0] aluA;
wire[63:0] aluB;
wire [3:0] alu_fun;
reg[2:0]new_cc;
reg[2:0]cc;


wire of=cc[0];
wire sf=cc[1];
wire zf=cc[2];

assign aluA=(icode_i==`IRRMOVQ||icode_i==`IOPQ)?valA_i:
            (icode_i==`IIRMOVQ||icode_i==`IRMMOVQ)?valC_i:
            (icode_i==`ICALL||icode_i==`IPUSHQ)?-8:
            (icode_i==`IRET||icode_i==`IPUSHQ)?8:0;
assign aluB=(icode_i==`IRMMOVQ||icode_i==`IMRMOVQ||
            icode_i==`IOPQ||icode_i==`ICALL||
            icode_i==`IPUSHQ||icode_i==`IRET||
            icode_i==`IPOPQ)?valB_i:
            (icode_i==`IRRMOVQ||icode_i==`IIRMOVQ)?0:0;
assign alu_fun=(icode_i==`IOPQ)?ifun_i:`ALUADD;

assign valE_o=(alu_fun==`ALUSUB)?(aluB-aluA):
              (alu_fun==`ALUAND)?(aluB & aluA):
              (alu_fun==`ALUXOR)?(aluB ^ aluA):(aluB+aluA);

always@(*)begin 
    if(~rst_n_i)begin 
        new_cc[2]=1;
        new_cc[1]=0;
        new_cc[0]=0;
    end
    else if((~execute_stall_i) && (icode_i==`IOPQ))begin 
        new_cc[2]=(valE_o==0)?1:0;
        new_cc[1]=valE_o[63];
        new_cc[0]=(alu_fun==`ALUADD)?
                    (aluA[63]==aluB[63])&(aluA[63]!=valE_o[63]):
                    (alu_fun==`ALUSUB)?
                    (~aluA[63]==aluB[63])&(aluB[63]!=valE_o[63]):0;
    end
end

assign set_cc=(icode_i==`IOPQ);

always@(posedge clk_i)begin 
    if(~rst_n_i)
        cc<=3'b100;
    else if( (~execute_stall_i) && set_cc)
        cc<=new_cc;
end

assign e_cnd_o=
    (ifun_i==`C_YES)||
    (ifun_i==`C_LE && ((sf^of)||zf))||
    (ifun_i==`C_L &&(sf^of))||
    (ifun_i==`C_E && zf)||
    (ifun_i==`C_NE && ~zf)||
    (ifun_i==`C_GE && ~(sf ^ of))||
    (ifun_i==`C_G && (~(sf ^ of)&&~zf));

assign dstE_o=((icode_i==`IRRMOVQ)&&!e_cnd_o)?`RNONE:E_dstE_i;
assign stat_o=stat_i;

endmodule