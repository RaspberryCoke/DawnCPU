`include "define.v"
`timescale 1ns/1ps

module memory_tb;

    reg clk_i;
    reg [3:0] icode_i;
    reg [63:0] valA_i;
    reg [63:0] valE_i;
    reg [63:0] valP_i;
    wire [63:0] valM_o;  // 输出信号为 wire 类型
    wire dmem_error_o;   // 输出信号为 wire 类型

    // 实例化 memory_access 模块
    memory memory_access(
        .clk_i(clk_i),
        .icode_i(icode_i),
        .valA_i(valA_i),
        .valE_i(valE_i),
        .valP_i(valP_i),
        .valM_o(valM_o),      // 输出 valM_o
        .dmem_error_o(dmem_error_o)
    );

    // 初始化时，模拟 RAM 的值
    integer i;
    initial begin
        for(i = 0; i < 255; i = i + 1) begin
            memory_access.rams[i] = i;  // 将内存设置为某些值
        end
    end

    // 设置输入信号
    initial begin
        valA_i = 64'd8;
        valE_i = 64'd16;
        valP_i = 64'd32;
        #5
        icode_i = `IRMMOVQ;  // 设定指令
        $display("valM_o = %h", valM_o);  // 显示 valM_o 的值
        #10;
    end

    // 时钟生成
    initial begin
        clk_i = 0;
        forever #1 clk_i = ~clk_i;  // 时钟周期为 10ns
    end

    // 启动仿真
    initial begin
        clk_i = 0;
        #5; // 等待初始时钟脉冲
    end

endmodule
