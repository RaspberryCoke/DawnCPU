`include "define.v"
module fetch(
    input wire[63:0] PC_i,

    output wire[3:0] icode_o,
    output wire[3:0] ifun_o,
    output wire[3:0] rA_o,
    output wire[3:0] rB_o,
    output wire[63:0] valC_o,
    output wire[63:0] valP_o,
    output wire[63:0] predPC_o,//new
    output wire[2:0] stat_o     
);

wire[63:0] predPC;

//内置的内存
reg[7:0] instr_mem[0:1023];

wire[79:0] instr;
wire need_regids;
wire need_valC;

assign imem_error=(PC_i>1023);//检查越界  --  这个检查恐怕不完善

//对二维数组的访问，instr_mem[0]为地址最低的8bit。

//instr可以把PC指向的地址的十个8bit读出来。

//注意：文件写入的时候，按照instr_mem[]从0到1023，所以不用颠倒顺序。

assign instr=imem_error==0?{instr_mem[PC_i+9],instr_mem[PC_i+8],
    instr_mem[PC_i+7],instr_mem[PC_i+6],instr_mem[PC_i+5],
    instr_mem[PC_i+4],instr_mem[PC_i+3],instr_mem[PC_i+2],
    instr_mem[PC_i+1],instr_mem[PC_i+0]}:64'b0;

//人类的惯性思维下，icode应该在低4bit。但实际上读入文件的时候，按照字节读入，
//所以实际上icode就放在了高位。

assign icode_o=instr[7:4];
assign ifun_o=instr[3:0];

assign instr_valid=(icode_o<4'hC);//检查指令是否出错

//是否需要寄存器位，1B  
assign need_regids=(icode_o==`ICMOVQ)||(icode_o==`IIRMOVQ)||(icode_o==`IRMMOVQ)||
(icode_o==`IMRMOVQ)||(icode_o==`IOPQ)||(icode_o==`IPUSHQ)||(icode_o==`IPOPQ);
//是否需要立即数
assign need_valC=(icode_o==`IIRMOVQ)||(icode_o==`IRMMOVQ)||
        (icode_o==`IMRMOVQ)||(icode_o==`IJXX)||(icode_o==`ICALL);

//给出寄存器AB的索引值（如果用到了的话）

assign rA_o=need_regids?{instr[15:12]}:4'hf;
assign rB_o=need_regids?{instr[11:8]}:4'hf;

assign valC_o=need_valC?(need_regids?instr[79:16]:instr[71:8]):64'b0;
assign valP_o=PC_i+1+8*need_valC+need_regids;

assign stat_o=imem_error?`SADR:
                (!instr_valid)?`SINS:
                (icode_o==`IHALT)?`SHLT:`SAOK;

assign predPC_o=(icode_o==`IJXX||icode_o==`ICALL)?valC_o:valP_o;//语句实现了predictPC的功能。预测全部跳转。



//触发条件：icode_o==`IHALT ,  PC_i改变
always@(*)begin 
    //$display($time,".fetch.v running.PC_i:%h.icode:%h.",PC_i,icode_o);
    if(icode_o==`IHALT)begin 
        $display($time,".fetch.v IHALT.PC_i:%h.icode:%h.",PC_i,icode_o);
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
        instr_mem[i]=8'h10;
    end  


    //手动填充指令
    //立即数采用了小端存储，也就是在指令里面，是逆序的。

    // irmovq 0x2 %rdx               %rdx=2   
    // 30 F2 02 00 00 00 00 00 00 00
    instr_mem[0]=8'h30;
    instr_mem[1]=8'hF2;
    instr_mem[2]=8'h02;
    instr_mem[3]=8'h00;
    instr_mem[4]=8'h00;
    instr_mem[5]=8'h00;
    instr_mem[6]=8'h00;
    instr_mem[7]=8'h00;
    instr_mem[8]=8'h00;
    instr_mem[9]=8'h00;

    // irmovq 0x1 %rcx               %rcx=1
    // 30 F1 01 00 00 00 00 00 00 00
    instr_mem[10]=8'h30;
    instr_mem[11]=8'hf1;
    instr_mem[12]=8'h01;
    instr_mem[13]=8'h00;
    instr_mem[14]=8'h00;
    instr_mem[15]=8'h00;
    instr_mem[16]=8'h00;
    instr_mem[17]=8'h00;
    instr_mem[18]=8'h00;
    instr_mem[19]=8'h00;

    // irmovq 0x3 %rbx               %rbx=3
    // 30 F3 03 00 00 00 00 00 00 00
    instr_mem[20]=8'H30;
    instr_mem[21]=8'HF3;
    instr_mem[22]=8'H03;
    instr_mem[23]=8'H00;
    instr_mem[24]=8'H00;
    instr_mem[25]=8'H00;
    instr_mem[26]=8'H00;
    instr_mem[27]=8'H00;
    instr_mem[28]=8'H00;
    instr_mem[29]=8'H00;
    // irmovq 0x90 %rsp(.4)          %rsp=0x90
    // 30 f4 90 00 00 00 00 00 00 00
    instr_mem[30]=8'H30;
    instr_mem[31]=8'HF4;
    instr_mem[32]=8'H90;
    instr_mem[33]=8'H00;
    instr_mem[34]=8'H00;
    instr_mem[35]=8'H00;
    instr_mem[36]=8'H00;
    instr_mem[37]=8'H00;
    instr_mem[38]=8'H00;
    instr_mem[39]=8'H00;
    // irmovq 0x8 %r8                %r8=0x8
    // 30 F8 08 00 00 00 00 00 00 00
    instr_mem[40]=8'H30;
    instr_mem[41]=8'HF8;
    instr_mem[42]=8'H08;
    instr_mem[43]=8'H00;
    instr_mem[44]=8'H00;
    instr_mem[45]=8'H00;
    instr_mem[46]=8'H00;
    instr_mem[47]=8'H00;
    instr_mem[48]=8'H00;
    instr_mem[49]=8'H00;
    // irmovq 0x21 %r9               %r9=0x21
    // 30 f9 21 00 00 00 00 00 00 00
    instr_mem[50]=8'H30;
    instr_mem[51]=8'HF9;
    instr_mem[52]=8'H21;
    instr_mem[53]=8'H00;
    instr_mem[54]=8'H00;
    instr_mem[55]=8'H00;
    instr_mem[56]=8'H00;
    instr_mem[57]=8'H00;
    instr_mem[58]=8'H00;
    instr_mem[59]=8'H00;
    // irmovq 0x4 %r14               %r14=0x4
    // 30 fe 21 00 00 00 00 00 00 00
    instr_mem[60]=8'H30;
    instr_mem[61]=8'HFE;
    instr_mem[62]=8'H21;
    instr_mem[63]=8'H00;
    instr_mem[64]=8'H00;
    instr_mem[65]=8'H00;
    instr_mem[66]=8'H00;
    instr_mem[67]=8'H00;
    instr_mem[68]=8'H00;
    instr_mem[69]=8'H00;
    // rrmovq %r8 %r10               %r10=%r8=0x8     
    // 20 8A
    instr_mem[70]=8'H20;
    instr_mem[71]=8'H8A;
    // rrmovq %rcx %r11              %r11=%rcx=0x1      
    // 20 1B
    instr_mem[72]=8'H20;
    instr_mem[73]=8'H1B;
    // rrmovq %rdx %r12              %r12=%rdx=0x2      
    // 20 2C
    instr_mem[74]=8'H20;
    instr_mem[75]=8'H2C;
    // rrmovq %rbx %r13              %r13=%rbx=0x3      
    // 20 3D
    instr_mem[76]=8'H20;
    instr_mem[77]=8'H3D;



    // addq %r8 %r10                 %r10=%r8+%r10=0x10
    // 60 8A
    instr_mem[78]=8'H60;
    instr_mem[79]=8'H8A;
    // subq  %r8 %r10                %r10=%r10-%r8=0x8
    // 61 8A
    instr_mem[80]=8'H61;
    instr_mem[81]=8'H8A;
    // jle  0x300(error)
    // 71 00 03 00 00 00 00 00 00
    instr_mem[82]=8'h71;
    instr_mem[83]=8'h00;
    instr_mem[84]=8'h03;
    instr_mem[85]=8'h00;
    instr_mem[86]=8'h00;
    instr_mem[87]=8'h00;
    instr_mem[88]=8'h00;
    instr_mem[89]=8'h00;
    instr_mem[90]=8'h00;
    // subq  %r8 %r10                %r10=%r10-%r8=0
    // 61 8A
    instr_mem[91]=8'h61;
    instr_mem[92]=8'h8A;
    // jne  0x300(error)
    // 74 00 03 00 00 00 00 00 00
    instr_mem[93]=8'h74;
    instr_mem[94]=8'h00;
    instr_mem[95]=8'h03;
    instr_mem[96]=8'h00;
    instr_mem[97]=8'h00;
    instr_mem[98]=8'h00;
    instr_mem[99]=8'h00;
    instr_mem[100]=8'h00;
    instr_mem[101]=8'h00;
    // xorq %r12(=2) %rdx(=2)        %rdx=0
    // 63 C2
    instr_mem[102]=8'h63;
    instr_mem[103]=8'hC2;
    // jne  0x300(error)
    // 74 00 03 00 00 00 00 00 00
    instr_mem[104]=8'h74;
    instr_mem[105]=8'h00;
    instr_mem[106]=8'h03;
    instr_mem[107]=8'h00;
    instr_mem[108]=8'h00;
    instr_mem[109]=8'h00;
    instr_mem[110]=8'h00;
    instr_mem[111]=8'h00;
    instr_mem[112]=8'h00;
    instr_mem[113]=8'h00;
    // andq %r14(=4) %rbx(=3)        %rbx=0
    // 62 E3
    instr_mem[114]=8'h62;
    instr_mem[115]=8'hE3;
    // jne  0x300(error)
    // 74 00 03 00 00 00 00 00 00
    instr_mem[116]=8'h74;
    instr_mem[117]=8'h00;
    instr_mem[118]=8'h03;
    instr_mem[119]=8'h00;
    instr_mem[120]=8'h00;
    instr_mem[121]=8'h00;
    instr_mem[122]=8'h00;
    instr_mem[123]=8'h00;
    instr_mem[124]=8'h00;
    instr_mem[125]=8'h00;



    // pushq (rA=)%r12=2  (rB=F)     %rsp=0x88,M[0x88]=%r12=2 --
    // a0 Cf
    instr_mem[126]=8'hA0;
    instr_mem[127]=8'hCF;
    // popq (rA=)%rax(.0=0) (rB=F)     %rax=M[0x88]=2,%rsp=0x90
    // b0 0f
    instr_mem[128]=8'hB0;
    instr_mem[129]=8'h0F;
    // xorq %r12(=2) %rax(=2)        %rax=0
    // 63 C0
    instr_mem[130]=8'h63;
    instr_mem[131]=8'hC0;
    // jne  0x300(error)
    // 74 00 03 00 00 00 00 00 00
    instr_mem[132]=8'h74;
    instr_mem[133]=8'h00;
    instr_mem[134]=8'h03;
    instr_mem[135]=8'h00;
    instr_mem[136]=8'h00;
    instr_mem[137]=8'h00;
    instr_mem[138]=8'h00;
    instr_mem[139]=8'h00;
    instr_mem[140]=8'h00;
    instr_mem[141]=8'h00;



    // # 访存
    // rmmovq %r13(=3) (%rdx(.2)(=0)+8)   rmmovq ra D(rb) M[0x8]=3
    // 40 D2 08 00 00 00 00 00 00 00
    instr_mem[142]=8'h40;
    instr_mem[143]=8'hD2;
    instr_mem[144]=8'h08;
    instr_mem[145]=8'h00;
    instr_mem[146]=8'h00;
    instr_mem[147]=8'h00;
    instr_mem[148]=8'h00;
    instr_mem[149]=8'h00;
    instr_mem[150]=8'h00;
    instr_mem[151]=8'h00;
    // mrmovq (%rdx(.2)(=0)+8) %rbx(.3)     mrmovq D(rb) ra  %rbx=M[0x8]=3
    // 50 32 08 00 00 00 00 00 00 00
    instr_mem[152]=8'h50;
    instr_mem[153]=8'h32;
    instr_mem[154]=8'h08;
    instr_mem[155]=8'h00;
    instr_mem[156]=8'h00;
    instr_mem[157]=8'h00;
    instr_mem[158]=8'h00;
    instr_mem[159]=8'h00;
    instr_mem[160]=8'h00;
    instr_mem[161]=8'h00;
    // xorq %r13(=3) %rbx(=3)        %rbx=0
    // 63 D3
    instr_mem[162]=8'h63;
    instr_mem[163]=8'hD3;
    // jne  0x300(error)             (9字节)
    // 74 00 03 00 00 00 00 00 00
    instr_mem[164]=8'h74;
    instr_mem[165]=8'h00;
    instr_mem[166]=8'h03;
    instr_mem[167]=8'h00;
    instr_mem[168]=8'h00;
    instr_mem[169]=8'h00;
    instr_mem[170]=8'h00;
    instr_mem[171]=8'h00;
    instr_mem[172]=8'h00;

    // # 跳转
    // subq %rax %rbx  %rbx=%rbx-%rax=0-0=0
    // 61 03
    instr_mem[173]=8'h61;
    instr_mem[174]=8'h03;
    // jg=76 0x300(error)            (9字节)
    // 76 00 03 00 00 00 00 00 00
    instr_mem[175]=8'h76;
    instr_mem[176]=8'h00;
    instr_mem[177]=8'h03;
    instr_mem[178]=8'h00;
    instr_mem[179]=8'h00;
    instr_mem[180]=8'h00;
    instr_mem[181]=8'h00;
    instr_mem[182]=8'h00;
    instr_mem[183]=8'h00;
    // jl=2 0x300(error)            (9字节)
    // 72 00 03 00 00 00 00 00 00
    instr_mem[184]=8'h72;
    instr_mem[185]=8'h00;
    instr_mem[186]=8'H03;
    instr_mem[187]=8'h00;
    instr_mem[188]=8'h00;
    instr_mem[189]=8'h00;
    instr_mem[190]=8'h00;
    instr_mem[191]=8'h00;
    instr_mem[192]=8'h00;
    // je=73 0xD4=212                (9字节) # 跳转到call ret
    // 73 D4 00 00 00 00 00 00 00
    instr_mem[193]=8'h73;
    instr_mem[194]=8'hD4;
    instr_mem[195]=8'h00;
    instr_mem[196]=8'h00;
    instr_mem[197]=8'h00;
    instr_mem[198]=8'h00;
    instr_mem[199]=8'h00;
    instr_mem[200]=8'h00;
    instr_mem[201]=8'h00;
    // XOR %rax %rax
    // 63 00
    instr_mem[202]=8'h63;
    instr_mem[203]=8'h00;
    // XOR %rax %rax
    // 63 00
    instr_mem[204]=8'h63;
    instr_mem[205]=8'h00;
    // XOR %rax %rax
    // 63 00
    instr_mem[206]=8'h63;
    instr_mem[207]=8'h00;
  


//地址



    //     ---从0xD4=212开始
    // # call ret 地址0x60
    // call=80 0x120=288                 (9字节)
    // 80 20 01 00 00 00 00 00 00
    instr_mem[212]=8'h80;
    instr_mem[213]=8'h20;
    instr_mem[214]=8'h01;
    instr_mem[215]=8'h00;
    instr_mem[216]=8'h00;
    instr_mem[217]=8'h00;
    instr_mem[218]=8'h00;
    instr_mem[219]=8'h00;
    instr_mem[220]=8'h00;


    // # ret到这里，jmp到正常退出
    // jmp=70 0x100                  (9字节)
    // 70 00 01 00 00 00 00 00 00
    instr_mem[221]=8'h70;
    instr_mem[222]=8'h00;
    instr_mem[223]=8'h01;
    instr_mem[224]=8'h00;
    instr_mem[225]=8'h00;
    instr_mem[226]=8'h00;
    instr_mem[227]=8'h00;
    instr_mem[228]=8'h00;
    instr_mem[229]=8'h00;
    // XOR %rax %rax
    // 63 00
    instr_mem[230]=8'h63;
    instr_mem[231]=8'h00;
    // XOR %rax %rax
    // 63 00
    instr_mem[232]=8'h63;
    instr_mem[233]=8'h00;
    // XOR %rax %rax
    // 63 00
    instr_mem[234]=8'h63;
    instr_mem[235]=8'h00;
    // XOR %rax %rax
    // 63 00
    instr_mem[236]=8'h63;
    instr_mem[237]=8'h00;
    // XOR %rax %rax
    // 63 00
    instr_mem[238]=8'h63;
    instr_mem[239]=8'h00;



//地址

    //     # 正常退出：地址 0x100
    // hlt=00  {instr_mem[256]=8'h00;}
    instr_mem[256]=8'h00;
    // hlt=00
    instr_mem[257]=8'h00;
    // hlt=00
    instr_mem[258]=8'h00;
    // hlt=00
    instr_mem[259]=8'h00;
    // hlt=00
    instr_mem[260]=8'h00;



//地址
    
    // ---从0x120=288开始
    // # 执行多个XOR指令后ret 地址0x80，
    // # 通过是否执行XOR来判断是否正确执行
    // XOR %rax %rax   {instr_mem[288]=8'h63;}
    // 63 00
    instr_mem[288]=8'h63;
    instr_mem[289]=8'H00;
    // XOR %rax %rax
    // 63 00
    instr_mem[290]=8'h63;
    instr_mem[291]=8'h00;
    // XOR %rax %rax
    // 63 00
    instr_mem[292]=8'h63;
    instr_mem[293]=8'h00;
    // XOR %rax %rax
    // 63 00
    instr_mem[294]=8'h63;
    instr_mem[295]=8'h00;
    // XOR %rax %rax
    // 63 00
    instr_mem[296]=8'h63;
    instr_mem[297]=8'h00;
    // ret=90  
    // 90
    instr_mem[298]=8'h90;
    // jmp 0x300(error)              ret失败
    // 70 00 03 00 00 00 00 00 00
    instr_mem[299]=8'h70;
    instr_mem[300]=8'h00;
    instr_mem[301]=8'h03;
    instr_mem[302]=8'h00;
    instr_mem[303]=8'h00;
    instr_mem[304]=8'h00;
    instr_mem[305]=8'h00;
    instr_mem[306]=8'h00;
    instr_mem[307]=8'h00;
    instr_mem[308]=8'h00;

    // # 错误处理：地址 0x300
    // //nop=10
    // instr_mem[768]=8'h10;  注意：0x300=768
    // 注：不需要写，因为内存初始化为0x10.

//instr_mem[]=8'h;
end


endmodule