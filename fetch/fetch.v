`include "define.v"
module fetch(
    input clk_i,//new
    input rst_n_i,//new
    input stall_i,//new
    input bubble_i,//new

    input wire[63:0] predPC_i,//new


    input wire[63:0]M_valA_i,//new
    input wire[63:0]W_valM_i,//new

    output wire [3:0] icode_o,
    output wire [3:0] ifun_o,
    output wire[3:0] rA_o,
    output wire [3:0] rB_o,
    output wire [63:0] valC_o ,
    output wire [63:0] valP_o ,
    output wire instr_valid_o,
    output wire imem_error_o 
);

reg[63:0] predPC;

// module predictPC(
//     input wire[63:0] valC_i,
//     input wire[63:0] valP_i,
//     output wire[63:0] valC_o,//tmp
//     output wire[63:0] valP_o,//tmp
//     output wire[63:0] predPC_o
// );
// module selectPC(
//     input rst_n_i,

//     input wire[63:0] predPC_i,
//     input wire[63:0] valC_i,//tmp
//     input wire[63:0] valP_i,//tmp
//     input wire[3:0] icode_i,//tmp
//     input wire[63:0] M_valA_i,
//     input wire[63:0] W_valM_i,
//     input wire[63:0] M_Cnd_i,
//     output wire[63:0] f_pc_o
// );

wire[63:0] f_pc;//new
wire[63:0] valC_i=valC_o;//tmp
wire[63:0] valP_i=valP_o;//tmp

selectPC selectPC_module(
    .rst_n_i(rst_n_i),
    .predPC_i(predPC_i),
    .valC_i(valC_i),//tmp
    .valP_i(valP_i),//tmp
    .icode_i(icode_o),//tmp
    .M_valA_i(M_valA_i),
    .W_valM_i(W_valM_i),
    .M_Cnd_i(M_Cnd_i),
    .f_pc_o(f_pc)
);

reg[7:0] instr_mem[0:1023];

wire[79:0] instr;
wire need_regids;
wire need_valC;

assign imem_error_o=(f_pc>1023);//检查越界  --  这个检查恐怕不完善

//对二维数组的访问，instr_mem[0]为地址最低的8bit。

//instr可以把PC指向的地址的十个8bit读出来。

//注意：文件写入的时候，按照instr_mem[]从0到1023，所以不用颠倒顺序。

assign instr={instr_mem[f_pc+9],instr_mem[f_pc+8],
    instr_mem[f_pc+7],instr_mem[f_pc+6],instr_mem[f_pc+5],
    instr_mem[f_pc+4],instr_mem[f_pc+3],instr_mem[f_pc+2],
    instr_mem[f_pc+1],instr_mem[f_pc+0]};

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

assign rA_o=need_regids?{instr[15:12]}:4'hf;
assign rB_o=need_regids?{instr[11:8]}:4'hf;

assign valC_o=need_valC?(need_regids?instr[79:16]:instr[71:8]):64'b0;

assign valP_o=f_pc+1+8*need_valC+need_regids;

// module predictPC(
//     input wire[63:0] valC_i,
//     input wire[63:0] valP_i,
//     output wire[63:0] valC_o,//tmp
//     output wire[63:0] valP_o,//tmp
//     output wire[63:0] predPC_o
// );
wire[63:0] predPC_o;

predictPC predictPC_module(
    .valC_i(valC_i),
    .valP_i(valP_i),
    .valC_o(valC_o),//tmp
    .valP_o(valP_o),//tmp
    .predPC_o(predPC_o)
);

always@(*)begin 
    $display($time,".fetch.v running.f_pc:%h.icode:%h.",f_pc,icode_o);
    if(icode_o==`IHALT)begin 
        $display($time,".fetch.v IHALT.f_pc:%h.icode:%h.",f_pc,icode_o);
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


integer i;

    initial begin
        $display("fetch.v:instr_mem initial...");
        for(i=0;i<1023;i=i+1)begin 
            instr_mem[i]=0;
        end  


        //手动填充指令
        //30 F8 08 00 00 00 00 00 00 00
        //由第一个字节的icode分析出后面有立即数，
        //立即数采用了小端存储，也就是在指令里面，是逆序的。

        //irmovq 0x8 %r8    30 f8 08
        //pc=0
        //%r8=0x8
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

        //irmovq 0x21 %r9 30 f9 21
        //pc=10
        //%r9=0x21
        instr_mem[10]=8'h30;
        instr_mem[11]=8'hf9;
        instr_mem[12]=8'h21;
        instr_mem[13]=8'h00;
        instr_mem[14]=8'h00;
        instr_mem[15]=8'h00;
        instr_mem[16]=8'h00;
        instr_mem[17]=8'h00;
        instr_mem[18]=8'h00;
        instr_mem[19]=8'h00;

        //rrmovq %r8 %r10 
        //pc=20
        //%r10=%r8=0x8
        instr_mem[20]=8'h20;
        instr_mem[21]=8'h8A;

        //addq %r8 %r10
        //pc=22
        //%r10=0x10
        instr_mem[22]=8'h60;
        instr_mem[23]=8'h8A;

        //subq  %r8 %r10
        //pc=24
        //%10=8
        instr_mem[24]=8'h61;
        instr_mem[25]=8'h8A;

        //subq %r10 %r8
        //pc=26
        //%r8=0
        instr_mem[26]=8'h61;
        instr_mem[27]=8'h8A;

        //xorq %rax(=0) %rdx(=2)   63 02 
        //pc=28
        //%rdx=2
        instr_mem[28]=8'h63;
        instr_mem[29]=8'h20;

        //andq %rcx(=1) %rbx(=3)   62 13 
        //pc=30
        //%rbx=1
        instr_mem[30]=8'h62;
        instr_mem[31]=8'h13;

        //irmovq 0x90 %rsp(.4) 30 f4 90
        //pc=32
        //%rsp=0x90
        instr_mem[32]=8'h30;
        instr_mem[33]=8'hf4;
        instr_mem[34]=8'h90;
        instr_mem[35]=8'h00;
        instr_mem[36]=8'h00;
        instr_mem[37]=8'h00;
        instr_mem[38]=8'h00;
        instr_mem[39]=8'h00;
        instr_mem[40]=8'h00;
        instr_mem[41]=8'h00;

        //pushq %rdx=2,%rsp(.4)=0x90
        //pc=42
        //D[0x88]=2,%rsp=0x88
        instr_mem[42]=8'ha0;
        instr_mem[43]=8'h2f;

        //popq %rax(.0)   b0 ra F
        //pc=44
        //%rax=D[0x88]=2,%rsp=0x90
        instr_mem[44]=8'hb0;
        instr_mem[45]=8'h0f;

        //rmmovq ra D(rb) rmmovq %rax=2 (%rdx(.2)(=2)+6)
        //  40   ra=0   rb=2  D=6
        //pc=46
        //D[0X8]=2
        instr_mem[46]=8'h40;
        instr_mem[47]=8'h02;
        instr_mem[48]=8'h06;
        instr_mem[49]=8'h00;
        instr_mem[50]=8'h00;
        instr_mem[51]=8'h00;
        instr_mem[52]=8'h00;
        instr_mem[53]=8'h00;
        instr_mem[54]=8'h00;
        instr_mem[55]=8'h00;

        //mrmovq D(rb) ra mrmovq (%rax(.0)(=2)+6) %rbx(.3)
        //  50   ra=rbx=3   rb=rax=0  D=6
        //pc=56
        //D[0X8]=2
        instr_mem[56]=8'h50;
        instr_mem[57]=8'h30;
        instr_mem[58]=8'h06;
        instr_mem[59]=8'h00;
        instr_mem[60]=8'h00;
        instr_mem[61]=8'h00;
        instr_mem[62]=8'h00;
        instr_mem[63]=8'h00;
        instr_mem[64]=8'h00;
        instr_mem[65]=8'h00;

        //jmp=70 0x50=80
        instr_mem[66]=8'h70;
        instr_mem[67]=8'h50;
        instr_mem[68]=8'h00;
        instr_mem[69]=8'h00;
        instr_mem[70]=8'h00;
        instr_mem[71]=8'h00;
        instr_mem[72]=8'h00;
        instr_mem[73]=8'h00;
        instr_mem[74]=8'h00;

        instr_mem[75]=8'h10;
        instr_mem[76]=8'h10;
        instr_mem[77]=8'h10;
        instr_mem[78]=8'h10;
        instr_mem[79]=8'h10;

        //subq %r11 %r12  61 bc
        //pc=80
        //%r12=1
        instr_mem[80]=8'h61;
        instr_mem[81]=8'hbc;

        //jg=76 0x60=96
        instr_mem[82]=8'h76;
        instr_mem[83]=8'h60;
        instr_mem[84]=8'h00;
        instr_mem[85]=8'h00;
        instr_mem[86]=8'h00;
        instr_mem[87]=8'h00;
        instr_mem[88]=8'h00;
        instr_mem[89]=8'h00;
        instr_mem[90]=8'h00;

        instr_mem[91]=8'h10;
        instr_mem[92]=8'h10;
        instr_mem[93]=8'h10;
        instr_mem[94]=8'h10;
        instr_mem[95]=8'h10;

        //call=80 0x80
        //pc=96
        //%rsp=0x90
        //%rsp-8=0x88
        //D[0x88]=pc(96D)+9=105D
        instr_mem[96]=8'h80;
        instr_mem[97]=8'h80;
        instr_mem[98]=8'h00;
        instr_mem[99]=8'h00;
        instr_mem[100]=8'h00;
        instr_mem[101]=8'h00;
        instr_mem[102]=8'h00;
        instr_mem[103]=8'h00;
        instr_mem[104]=8'h00;

        //jmp=70 0x81
        instr_mem[105]=8'h70;
        instr_mem[106]=8'h81;
        instr_mem[107]=8'h00;
        instr_mem[108]=8'h00;
        instr_mem[109]=8'h00;
        instr_mem[110]=8'h00;
        instr_mem[111]=8'h00;
        instr_mem[112]=8'h00;
        instr_mem[113]=8'h00;


        instr_mem[114]=8'h10;
        instr_mem[115]=8'h10;
        instr_mem[116]=8'h10;
        instr_mem[117]=8'h10;
        instr_mem[118]=8'h10;
        instr_mem[119]=8'h10;
        instr_mem[120]=8'h10;
        instr_mem[121]=8'h10;
        instr_mem[122]=8'h10;
        instr_mem[123]=8'h10;
        instr_mem[124]=8'h10;
        instr_mem[125]=8'h10;
        instr_mem[126]=8'h10;
        instr_mem[127]=8'h10;

        //ret=90
        instr_mem[128]=8'h90;

        //hlt=00
        instr_mem[129]=8'h00;


 
//instr_mem[]=8'h;
    end


endmodule