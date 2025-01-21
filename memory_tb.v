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
    memory_access memory_module(
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
        for(i = 0; i < 1023; i = i + 1) begin
            $display("write data to rams...addr=%h,num=%h",i,i);
            memory_module.rams.rams[i] = i;  // 将内存设置为某些值
        end
    end

    // 设置输入信号
    initial begin
        #100
        valA_i = 64'HA;
        valE_i = 64'HE;
        valP_i = 64'H2;
        
        $display("------------1st instruction rmmov: ----------------");
        $display("M[valE] = valA_o");
        $display("valA_o = %h", valA_i);
        $display("valE_o = %h", valE_i);
        $display("M[valE_o]= %h", memory_module.rams.rams[valE_i]);
        
        #2;
        icode_i = `IRMMOVQ;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        //$display("valM_o = %h", valM_o);
        $display("M[valE_o]= %h", memory_module.rams.rams[valE_i]);
        //$display("valA_o = %h", valA_i);
        $display("------------Finesh--------------------------------------");
        #2;

        $display("------------2nd instruction mrmov: ----------------");
        $display("valM=M[valE]");
        $display("valM_o = %h", valM_o);
        $display("valE_i = %h", valE_i);
        $display("M[valE]= %h", memory_module.rams.rams[valE_i]);
        
        #2;
        icode_i = `IMRMOVQ;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        //$display("valM_o = %h", valM_o);
        //$display("rams[valE_o]= %h", memory_module.rams.rams[valE_i]);
        $display("valM = %h", valM_o);
        $display("------------Finesh--------------------------------------");
        #2;

        $display("------------3rd instruction pushq: ----------------");
        $display("M[valE] = valA_i");
        $display("valA_i = %h", valA_i);
        $display("valE_i = %h", valE_i);
        $display("M[valE]= %h", memory_module.rams.rams[valE_i]);
        
        #2;
        icode_i = `IPUSHQ;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        $display("M[valE_o]= %h", memory_module.rams.rams[valE_i]);
        //$display("valM = %h", valM_o);
        $display("------------Finesh--------------------------------------");
        #2;


        $display("------------4th instruction popq: ----------------");
        $display("valM=M[valA]");
        $display("valM_i = %h", valM_o);
        $display("valA_i = %h", valA_i);
        $display("M[valE]= %h", memory_module.rams.rams[valE_i]);
        
        #2;
        icode_i = `IPOPQ;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        //$display("rams[valE_o]= %h", memory_module.rams.rams[valE_i]);
        $display("valM = %h", valM_o);
        $display("------------Finesh--------------------------------------");
        #2;


        $display("------------5th instruction popq: ----------------");
        $display("valM=M[valA]");
        $display("valM_i = %h", valM_o);
        $display("valA_i = %h", valA_i);
        $display("M[valE]= %h", memory_module.rams.rams[valE_i]);
        
        #2;
        icode_i = `IPOPQ;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        //$display("rams[valE_o]= %h", memory_module.rams.rams[valE_i]);
        $display("valM = %h", valM_o);
        $display("------------Finesh--------------------------------------");
        #2;
        

        $display("------------6th instruction CALL: ----------------");
        $display("M[valE] = valP");
        $display("valP = %h", valP_i);
        $display("valE_i = %h", valE_i);
        $display("rams[valE]= %h", memory_module.rams.rams[valE_i]);
        
        #2;
        icode_i = `ICALL;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        //$display("rams[valE_o]= %h", memory_module.rams.rams[valE_i]);
        $display("M[valE] = %h", memory_module.rams.rams[valE_i]);
        $display("------------Finesh--------------------------------------");
        #2;


        #2;
    end



    // // 初始化时，模拟 RAM 的值
    // integer i;
    // initial begin
    //     for(i = 0; i < 1023; i = i + 1) begin
    //         memory_access.rams[i] = i;  // 将内存设置为某些值
    //     end
    // end




    // 时钟生成
    initial begin
        clk_i = 0;
        forever #1 clk_i = ~clk_i;  // 时钟周期为 10ns
    end

endmodule
