`include "define.v"
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


    initial begin
        //手动填充指令
        //30 F8 08 00 00 00 00 00 00 00
        //由第一个字节的icode分析出后面有立即数，
        //立即数采用了小端存储，也就是在指令里面，是逆序的。

        //irmovq 0x8 %r8
        instr_mem[0]=8'h30;
        instr_mem[1]=8'hF8;
        instr_mem[2]=8'h08;
        instr_mem[3]=8'h00;
        instr_mem[4]=8'h00;
        instr_mem[5]=8'h00;
        instr_mem[6]=8'h00;
        instr_mem[7]=8'h00;
        instr_mem[8]=8'h00;
        instr_mem[9]=8'h00;

        //irmovq 0x21 %rbx
        instr_mem[10]=8'h30;
        instr_mem[11]=8'hf3;
        instr_mem[12]=8'h15;
        instr_mem[13]=8'h00;
        instr_mem[14]=8'h00;
        instr_mem[15]=8'h00;
        instr_mem[16]=8'h00;
        instr_mem[17]=8'h00;
        instr_mem[18]=8'h00;
        instr_mem[19]=8'h00;




    end

endmodule
