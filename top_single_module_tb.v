`timescale 1ns/1ps
module top_single_module_tb;





// 10ns周期时钟
reg clk_i;
always begin
    #5 clk_i = ~clk_i;  
end

// 复位信号初始化为低
// 15ns后复位信号置高
reg rst_n_i;
initial begin
    rst_n_i = 1'b0;  
    #15 rst_n_i = 1'b1;  
end

// 初始化模块
top_single_module t1(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i)
);

// 1000ns后结束仿真
initial begin
    #1000 $finish;  
end


//初始化内存
//t1.ram_module.rams
initial begin 

end


///////////////////////////////////////////////////////////////////////////////////
localparam FILE_TXT = "instructions.txt";

integer fd;
integer char_num;

integer i;
integer j;

reg [7:0]   fbuf = 0;



reg [1023:0] buff_i;

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


initial begin

    buff_i=0;
    pc_i=0;
    i = 0;
    j=0;
    char_num = 0;
    fd = $fopen(FILE_TXT, "r");
    //打开文件
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
   
   //主循环
    while(char_num!=0)begin
        $display("enter main loop...") ;


        //先跳过#行
        $display("----------------skip # hang-------------- \n") ;
        while(char_num!=0&&fbuf!=8'd10)begin //8'b10 换行
            $display("skip # hang ,this char is %c .",fbuf) ;
            char_num=$fgets(fbuf,fd);
        end


        //现在fbuf='\n'
        $display("----------------set pc = %d -------------",pc_i) ;
        pc_mem[pc_i]=buff_i;
        pc_i=pc_i+1;


        char_num=$fgets(fbuf,fd);
        $display("getting num :  %h  ",hex_to_decimal(fbuf)) ;

        $monitor("buff_i is %d",buff_i);

        while(char_num!=0&&fbuf!=8'd35)begin //8'd35 #

            //开始获取一行指令数据
            temp4_1=hex_to_decimal(fbuf);
            t1.ram_module.rams[buff_i][7:4]=hex_to_decimal(fbuf);
            

            char_num=$fgets(fbuf,fd);
            $display("getting num :  %h  ",hex_to_decimal(fbuf)) ;

            temp4_2=hex_to_decimal(fbuf);
            t1.ram_module.rams[buff_i][3:0]=hex_to_decimal(fbuf);
            buff_i=buff_i+1;
            //获取数据结束

            //1.可能到文件结尾了。
            //2.后续还有数据行。
            //3.后续是另外一条指令的#行
            char_num=$fgets(fbuf,fd);


            if(char_num==0)begin 
                $display("-----------------file end--------------");
                disable loop;
            end

            if((fbuf!=8'd10))//8'b10 换行
                $display("--------------wrong with fbuf = %c ---------",fbuf);
                disable loop;

            char_num=$fgets( fbuf,fd);
            //可能是  数据，也可能是  #
            
        end

    end

end

    initial begin:loop
    j=0;
    $display("begin to output:....buff_i is %d.",buff_i);
        while(j<buff_i)begin
            $display("\nram：  %h:%h",t1.ram_module.rams[j][7:4],t1.ram_module.rams[j][3:0]);
            j=j+1;
        j=0;
        // while(j<pc_i)begin 
        //     $display("\n  the %d instr begin at %d",j,pc_mem[j]);
        //     j=j+1;
        // end

        end
    $stop;
    end

/////////////////////////////////////////////////////////////////////////////////////

endmodule