`timescale 1ns/1ps
module ram_tb;
    
    reg clk_i;
    reg read_en;
    reg write_en;
    reg [63:0] addr_i;
    reg [63:0] write_data_i;
    wire [63:0] read_data_o;
    wire dmem_error_o;

    ram ram_module(
        .clk_i(clk_i),
        .read_en(read_en),
        .write_en(write_en),
        .addr_i(addr_i),
        .write_data_i(write_data_i),
        .read_data_o(read_data_o),
        .dmem_error_o(dmem_error_o)
    );

    // integer i;
    // integer j;
    // // 写操作控制
    // initial begin 
    //     // 初始化
    //     write_en = 0;
    //     read_en = 0;
    //     addr_i = 0;
    //     write_data_i = {64{1'b0}};  // 初始写入数据为 0

    //     // 写入数据到RAM
    //     for(j = 0; j < 255; j = j + 8) begin
    //         addr_i = j;
    //         write_data_i =j;//{64{1'b1}}; // 写入64个1
    //         $display($time, ", write data to RAM: data is %h, addr is %h", write_data_i, addr_i);
    //         write_en = 1;  // 使能写操作
    //         #2 write_en = 0;  // 写操作结束后禁用写使能
    //         #2;  // 确保信号稳定
    //     end
    // end

    // // 读操作控制
    // initial begin
    //     #130
    //     // 初始化读操作
    //     read_en = 0;
    //     addr_i = 0;

    //     // 读取数据
    //     for(i = 0; i < 255; i = i + 8) begin
    //         addr_i = i;
    //         read_en = 1;  // 使能读操作
    //         #2 //,read_en = 0;  // 读取后禁用读使能
    //         $display($time, ", read data from RAM: data is %h, addr is %h", read_data_o, addr_i);
    //         #2;  // 确保信号稳定
    //         read_en = 0; 
    //     end
    // end

    // // 时钟生成
    // initial begin
    //     clk_i = 0;
    //     forever #1 clk_i = ~clk_i;  // 时钟周期为 10ns
    // end


    integer i;
    initial begin
        for(i = 0; i < 63; i = i + 1) begin
            $display("write data to rams...addr=%h,num=%h",i,i);
            ram_module.rams[i] = i;  // 将内存设置为某些值
        end
    end
    initial begin
        #10 ;
        for(i = 0; i < 63; i = i + 1) begin
            $display("read data to rams...addr=%h,num=%h",i,ram_module.rams[i]);
        end
    end

endmodule
