`timescale 1ns / 1ps
module sim_top();
reg stop_flag = 0;
 
localparam FILE_TXT = "instructions.txt";

integer fd;

integer char_num;

integer i;

integer j;

integer k;

reg [7:0]   fbuf = 0;

reg [7:0] byte_h=0;
reg [7:0] byte_l=0;

reg [7:0] buff[1023:0];
reg [1023:0] buff_i;

reg [63:0] pc_mem [0:1023];

reg [1024:0] pc_i;

reg [3:0]temp4_1;
reg [3:0]temp4_2;
reg [3:0]temp4_3;
reg [3:0]temp4_4;

reg [7:0]temp8_1;
reg [7:0]temp8_2;
reg [7:0]temp8_3;
reg [7:0]temp8_4;


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
            buff[buff_i][7:4]=hex_to_decimal(fbuf);
            

            char_num=$fgets(fbuf,fd);
            $display("getting num :  %h  ",hex_to_decimal(fbuf)) ;

            temp4_2=hex_to_decimal(fbuf);
            buff[buff_i][3:0]=hex_to_decimal(fbuf);
            buff_i=buff_i+1;
            //获取数据结束

            //1.可能到文件结尾了。
            //2.后续还有数据行。
            //3.后续是另外一条指令的#行
            char_num=$fgets(fbuf,fd);


            if(char_num==0)begin 
                $display("file end...or format wrong...");
            end

            if((fbuf!=8'd10))
                $display("char_num= %d ...fbuf=%c...",char_num,fbuf);
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
        $display("\n  %h:%h",buff[j][7:4],buff[j][3:0]);
        j=j+1;


    end
    

 
    // char_num = $fgets(fbuf,fd);
    // i = i + 1;
    
    // while (char_num != 0)
    // begin
    //     //$write("%s", fbuf) ;
    //     if((fbuf!=8'd10))begin//&&(fbuf!=8'd13)
    //         buff[j]=fbuf;
    //         j=j+1;
    //     end

    //     #10;
    //     char_num = $fgets(fbuf,fd);
    //     i = i + 1;
    // end

    // k=0;

    $display("\n ============= file middle... ============= ") ;

    #10;
    $fclose(fd) ;
    $display("\n ============= file closed... ============= ") ;
    stop_flag = 1;
 
    #100;
    $stop;
end
    
 
    
endmodule