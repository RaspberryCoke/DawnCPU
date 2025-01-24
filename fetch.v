`include "define.v"
module fetch(
    input clk_i,
    input rst_n_i,
    input wire[63:0] PC_i,


    output wire [3:0] icode_o,
    output wire [3:0] ifun_o,
    output wire[3:0] rA_o,
    output wire [3:0] rB_o,
    output wire [63:0] valC_o ,
    output wire [63:0] valP_o ,
    output wire        instr_valid_o,
    output wire       imem_error_o 
);


reg [7:0] rams[1023:0];
wire[79:0] instruction_i;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg stop_flag = 0;
 
localparam FILE_TXT = "instructions.txt";

integer fd;
integer char_num;
integer i;
integer j;


reg [7:0]   fbuf = 0;


reg [31:0] buff_i;
reg [63:0] pc_mem [0:1023];
reg [1024:0] pc_i;
reg [3:0]temp4_1;
reg [3:0]temp4_2;

  // 函数：将16进制字符转换为其对应的真实值
  function [3:0] hex_to_decimal;
    input [7:0] hex_char;  // 输入字符
    begin
      case (hex_char)
        "0": hex_to_decimal = 4'd0;
        "1": hex_to_decimal = 4'd1;
        "2": hex_to_decimal = 4'd2;
        "3": hex_to_decimal = 4'd3;
        "4": hex_to_decimal = 4'd4;
        "5": hex_to_decimal = 4'd5;
        "6": hex_to_decimal = 4'd6;
        "7": hex_to_decimal = 4'd7;
        "8": hex_to_decimal = 4'd8;
        "9": hex_to_decimal = 4'd9;
        "A": hex_to_decimal = 4'd10;
        "B": hex_to_decimal = 4'd11;
        "C": hex_to_decimal = 4'd12;
        "D": hex_to_decimal = 4'd13;
        "E": hex_to_decimal = 4'd14;
        "F": hex_to_decimal = 4'd15;
        default: hex_to_decimal = 4'd0;  // 默认处理
      endcase
    end
  endfunction


// always@(negedge rst_n_i) begin
initial begin
//     fbuf=8'h3f;
// $display("low: %d , high : %d...",fbuf[3:0],fbuf[7:4]);

    buff_i=0;
    pc_i=0;
    i = 0;
    j=0;
    char_num = 0;
    fd = $fopen(FILE_TXT, "r");
    if(fd == 0)
    begin
        $display("$open file failed") ;
        $stop;
    end
    $display("\n ============= file opened... ============= ") ;

    //进入文件，查看是否为空，以及第一个字符是否为#
    char_num = $fgets(fbuf,fd);
    if(char_num==0||fbuf!=8'd35) //8'd35 #
    begin 
        $display("\n file is empty or file not begin with '#' ") ;
        $stop;
    end
   
    while(char_num!=0)begin
        $display("enter main loop...") ;
        //先跳过#行
        $display("----------------skip # hang-------------- \n",pc_i) ;
        while(char_num!=0&&fbuf!=8'd10)begin //8'b10 换行
            $display("skip # hang ,this char is %c .",fbuf) ;
            char_num=$fgets(fbuf,fd);
        end



        //现在fbuf='\n'
        $display("----------------set pc = %d -------------",pc_i) ;
        pc_mem[pc_i]=i;

        char_num=$fgets(fbuf,fd);
        $display("getting num :  %h  ",hex_to_decimal(fbuf)) ;

        $monitor("buff_i is %d",buff_i);

        while(char_num!=0&&fbuf!=8'd35)begin //8'd35 #

            //开始获取一行指令数据
            temp4_1=hex_to_decimal(fbuf);
            rams[buff_i][7:4]=hex_to_decimal(fbuf);
            

            char_num=$fgets(fbuf,fd);
            $display("getting num :  %h  ",hex_to_decimal(fbuf)) ;

            temp4_2=hex_to_decimal(fbuf);
            rams[buff_i][3:0]=hex_to_decimal(fbuf);
            buff_i=buff_i+1;
            //获取数据结束

            //1.可能到文件结尾了。
            //2.后续还有数据行。
            //3.后续是另外一条指令的#行
            char_num=$fgets(fbuf,fd);


            if(char_num==0)begin 
                $display("file end...or format wrong...");
            end

            if((fbuf!=8'd10))begin
                $display("char_num= %d ...fbuf=%c...",char_num,fbuf);
                disable loop;
            end
            char_num=$fgets( fbuf,fd);
            //可能是  数据，也可能是  #
            
        end
    end
end

    initial begin:loop
    #100;
    j=0;
    $display("begin to output:....buff_i is %d.",buff_i);
    while(j<buff_i)begin
        $display("\n  %h:%h",rams[j][7:4],rams[j][3:0]);
        j=j+1;
    end
    
    $fclose(fd) ;
    $display("\n ============= file closed... ============= ") ;
   
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





always @(PC_i) begin
    // 根据 PC_i 读取指令数据并更新相关信号
    instruction_i = {rams[PC_i+9], rams[PC_i+8], rams[PC_i+7], rams[PC_i+6], rams[PC_i+5], rams[PC_i+4], 
                     rams[PC_i+3], rams[PC_i+2], rams[PC_i+1], rams[PC_i]}; // 按顺序组装指令
    icode_o = instruction_i[7:4]; // 提取 icode
    ifun_o = instruction_i[3:0]; // 提取 ifun
end










// ICHCHE

integer i2;

wire addr_i=PC_i;

assign read_instruction_o={rams[addr_i+9],rams[addr_i+8],rams[addr_i+7],rams[addr_i+6],rams[addr_i+5],rams[addr_i+4],
   rams[addr_i+3],rams[addr_i+2],rams[addr_i+1],rams[addr_i]};

assign instruction_i=read_instruction_o;

// //for reset
// always@(*)begin 
//     if(~rst_n_i)begin 
//         $display("ram.v: initial...");
//         for(i2=0;i2<1024;i2=i2+1)begin 
//             rams[i2]<=8'b0;
//        end
//     end 
// end

// ICHCHE end

wire     need_regids;
wire     need_valC;

assign imem_error_o=(PC_i>1023-9);//检查越界  --  这个检查恐怕不完善
//人类的惯性思维下，icode应该在低4bit。但实际上读入文件的时候，按照字节读入，
//所以实际上icode就放在了高位。

assign icode_o=instruction_i[7:4];
assign ifun_o=instruction_i[3:0];

 assign instr_valid_o=(icode_o<4'hC);//检查指令是否出错

//是否需要寄存器位，1B  
assign need_regids=(icode_o==`ICMOVQ)||(icode_o==`IIRMOVQ)||(icode_o==`IRMMOVQ)||(icode_o==`IMRMOVQ)||(icode_o==`IOPQ)||(icode_o==`IPUSHQ)||(icode_o==`IPOPQ);

//是否需要立即数
assign need_valC=(icode_o==`IIRMOVQ)||(icode_o==`IRMMOVQ)||
        (icode_o==`IMRMOVQ)||(icode_o==`IJXX)||(icode_o==`ICALL);

//给出寄存器AB的索引值（如果用到了的话）

assign rA_o=need_regids?{instruction_i[15:12]}:4'hf;
assign rB_o=need_regids?{instruction_i[11:8]}:4'hf;

assign valC_o=need_valC?(need_regids?instruction_i[79:16]:instruction_i[71:8]):64'B0;

assign valP_o=PC_i+1+8*need_valC+need_regids;



endmodule

//     initial begin
//         //手动填充指令
//         //30 F8 08 00 00 00 00 00 00 00
//         //由第一个字节的icode分析出后面有立即数，
//         //立即数采用了小端存储，也就是在指令里面，是逆序的。

//         //irmovq 0x8 %r8    30 f8 08
//         instr_mem[0]=8'h30;
//         instr_mem[1]=8'hF8;
//         instr_mem[2]=8'h08;
//         instr_mem[3]=8'h00;
//         instr_mem[4]=8'h00;
//         instr_mem[5]=8'h00;
//         instr_mem[6]=8'h00;
//         instr_mem[7]=8'h00;
//         instr_mem[8]=8'h00;
//         instr_mem[9]=8'h00;

//         //irmovq 0x21 %r9 30 f9 21
//         instr_mem[10]=8'h30;
//         instr_mem[11]=8'hf9;
//         instr_mem[12]=8'h21;
//         instr_mem[13]=8'h00;
//         instr_mem[14]=8'h00;
//         instr_mem[15]=8'h00;
//         instr_mem[16]=8'h00;
//         instr_mem[17]=8'h00;
//         instr_mem[18]=8'h00;
//         instr_mem[19]=8'h00;

//         //rrmovq %r8 %r10 
//         instr_mem[20]=8'h20;
//         instr_mem[21]=8'h8A;

//         //addq %8 %10
//         instr_mem[22]=8'h60;
//         instr_mem[23]=8'h8A;

//         //subq %10 %8
//         instr_mem[24]=8'h00;
//         instr_mem[25]=8'h00;
//         instr_mem[26]=8'h00;
//         instr_mem[27]=8'h00;
//         instr_mem[28]=8'h00;
//         instr_mem[29]=8'h00;

//         //subq %rdx %rbx   61 23 
//         instr_mem[30]=8'h61;
//         instr_mem[31]=8'h23;


//         //pushq %rdx
//         instr_mem[32]=8'ha0;
//         instr_mem[33]=8'h2f;

//         //popq %rax
//         instr_mem[34]=8'hb0;
//         instr_mem[35]=8'h0f;

 
// //instr_mem[]=8'h;
    // end


