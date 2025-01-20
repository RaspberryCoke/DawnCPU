`timescale 1ns / 1ps

module fetch_tb;
    reg [63:0] PC_i;
    wire [3:0] icode_o;
    wire [3:0] ifun_o;
    wire [3:0] rA_o;
    wire [3:0] rB_o;
    wire [63:0] valC_o;
    wire [63:0] valP_o;
    wire instr_valid_o;
    wire imem_error_o;

    // 实例化 fetch 模块
    fetch uut (
        .PC_i(PC_i),
        .icode_o(icode_o),
        .ifun_o(ifun_o),
        .rA_o(rA_o),
        .rB_o(rB_o),
        .valC_o(valC_o),
        .valP_o(valP_o),
        .instr_valid_o(instr_valid_o),
        .imem_error_o(imem_error_o)
    );

    // 用于存储指令的PC值
    reg [63:0] pc_mem [0:1023];
    integer i, pc, instr_len, file;
    reg [7:0] line ;//[0:255]; // 用于存储每一行的内容
    reg [7:0] instr_buffer [0:255]; // 用于存储当前指令的字节
    integer line_length;
    integer instr_index;

    // 初始化信号
    initial begin
        pc = 0;                          // 初始化PC为0
        instr_index = 0;                 // 初始化指令索引
        file = $fopen("instructions.txt", "r"); // 打开文件读取指令

        if (file == 0) begin
            $display("无法打开文件！");
            $finish;
        end

        // 逐行读取文件并处理
        while (!$feof(file)) begin
            // 读取一行
            line_length = $fgets(line, file);

            // 如果是以#开头的注释行，跳过
            if (line[0] != "#") begin
                // 否则，读取指令
                // 读取指令的字节直到遇到下一个以#开头的注释行或者超过10字节
                instr_len = 0;
                while (line[0] != "#" && !($feof(file))) begin
                    // 读取指令的每个字节
                    instr_buffer[instr_len] = line[0];  // 存储当前字节
                    instr_len = instr_len + 1;

                    // 如果指令超过10字节，报错停止
                    if (instr_len > 10) begin
                        $display("指令长度超过10字节，仿真停止!");
                        $finish;
                    end

                    // 继续读取下一个字节
                    line_length = $fgets(line, file);
                end

                // 存储指令到instr_mem
                for (i = 0; i < instr_len; i = i + 1) begin
                    uut.instr_mem[instr_index] = instr_buffer[i]; // 存储指令字节
                    pc_mem[instr_index] = pc; // 记录PC值
                    pc = pc + 1;  // 更新PC
                    instr_index = instr_index + 1;  // 增加指令索引
                end
            end
        end

        // 文件读取完毕，仿真结束
        $fclose(file);
        $display("文件加载完成，仿真结束");
    end

    // // 设置PC
    // always begin
    //     #10 PC_i = pc_mem[PC_i];  // 每10个时间单位，更新PC
    // end

    // // 监视输出，查看指令的输出值
    // initial begin
    //     $monitor("At time %t, PC = %h, icode_o = %h, ifun_o = %h, rA_o = %h, rB_o = %h, valC_o = %h, valP_o = %h, instr_valid_o = %b, imem_error_o = %b", 
    //              $time, PC_i, icode_o, ifun_o, rA_o, rB_o, valC_o, valP_o, instr_valid_o, imem_error_o);
    // end

    // // 仿真结束时输出PC数组内容和指令存储
    // initial begin
    //     #100;  // 等待仿真完成
    //     $display("指令存储和PC记录：");
    //     for (i = 0; i < instr_index; i = i + 1) begin
    //         $display("PC[%0d] = %0d, 指令: %h", i, pc_mem[i], uut.instr_mem[i]);
    //     end
    // end

endmodule
