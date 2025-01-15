`include "defines.v"
module fetch(
    input wire[63:0] PC_i,

    output wire [3:0] icode_o,
    output wire [3:0] ifun_o,
    output wire[3:0] rA_o,
    output wire [3:0] rB_o,
    output wire [63:0] valC_o ,
    output wire [63:0] valP_o ,
    output wire       instr_valid_o,
    output wire       imem_error_o 
);

reg[7:0] instr_mem[0:1023];//指令的填充  --  是否理应放在外面？

wire[79:0] instr;
wire     need_regids;
wire     need_valC;

assign imem_error_o=(PC_i>1023);//检查越界  --  这个检查恐怕不完善

//对二维数组的访问，instr_mem[0]为地址最低的8bit。

//instr可以把PC指向的地址的十个8bit读出来。

//注意：文件写入的时候，按照instr_mem[]从0到1023，所以不用颠倒顺序。

assign instr={instr_mem[PC_i+9],instr_mem[PC_i+8],
    instr_mem[PC_i+7],instr_mem[PC_i+6],instr_mem[PC_i+5],
    instr_mem[PC_i+4],instr_mem[PC_i+3],instr_mem[PC_i+2],
    instr_mem[PC_i+1],instr_mem[PC_i+0]};

//人类的惯性思维下，icode应该在低4bit。但实际上读入文件的时候，按照字节读入，
//所以实际上icode就放在了高位。

assign icode_o=instr[7:4];
assign ifun_o=instr[3:0];


assign instr_valid_o=(icode_o<4'hC);//检查指令是否出错

//是否需要寄存器位，1B  
assign need_regids=(icode_o==`ICMOVQ)||(icode_o==`IIRMOVQ)||(icode_o==`IRMMOVQ)||(icode_o==`IMRMOVQ)||(icode_o==`IOPQ)||(icode_o==`IPUSHQ)||(icode_o==`IPOPQ);

//是否需要立即数
assign need_valC=(icode_o==`IIRMOVQ)||(icode_o==`IRMMOVQ)||
        (icode_o==`IMRMOVQ)||(icode_o==`IJXX)||(icode_o==`ICALL);

//给出寄存器AB的索引值（如果用到了的话）

assign rA_o=need_regids?{instr[11:8]}:4'hf;
assign rB_o=need_regids?{instr[15:12]}:4'hf;

assign valC_o=need_regids?instr[79:16]:instr[71:8];

assign valP_o=PC_i+1+8*need_valC+need_regids;

endmodule
