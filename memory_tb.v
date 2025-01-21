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
        $display("M[valE_o]= %h", {memory_module.rams.rams[valE_i+7],
        memory_module.rams.rams[valE_i+6],memory_module.rams.rams[valE_i+5],
        memory_module.rams.rams[valE_i+4],memory_module.rams.rams[valE_i+3],
        memory_module.rams.rams[valE_i+2],memory_module.rams.rams[valE_i+1],
        memory_module.rams.rams[valE_i]});
        
        #2;
        icode_i = `IRMMOVQ;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        $display("M[valE_o]= %h", {memory_module.rams.rams[valE_i+7],
        memory_module.rams.rams[valE_i+6],memory_module.rams.rams[valE_i+5],
        memory_module.rams.rams[valE_i+4],memory_module.rams.rams[valE_i+3],
        memory_module.rams.rams[valE_i+2],memory_module.rams.rams[valE_i+1],
        memory_module.rams.rams[valE_i]});
        $display("------------Finesh--------------------------------------");
        #2;

        $display("------------2nd instruction mrmov: ----------------");
        $display("valM=M[valE]");
        $display("valM_o = %h", valM_o);
        $display("valE_i = %h", valE_i);
        $display("M[valE]= %h", {memory_module.rams.rams[valE_i+7],
        memory_module.rams.rams[valE_i+6],memory_module.rams.rams[valE_i+5],
        memory_module.rams.rams[valE_i+4],memory_module.rams.rams[valE_i+3],
        memory_module.rams.rams[valE_i+2],memory_module.rams.rams[valE_i+1],
        memory_module.rams.rams[valE_i]});
        
        #2;
        icode_i = `IMRMOVQ;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        $display("valM = %h", valM_o);
        $display("------------Finesh--------------------------------------");
        #2;

        memory_module.rams.rams[valE_i]=1;
        $display("------------3rd instruction pushq: ----------------");
        $display("M[valE] = valA_i");
        $display("valA_i = %h", valA_i);
        $display("valE_i = %h", valE_i);
        $display("M[valE]= %h", {memory_module.rams.rams[valE_i+7],
        memory_module.rams.rams[valE_i+6],memory_module.rams.rams[valE_i+5],
        memory_module.rams.rams[valE_i+4],memory_module.rams.rams[valE_i+3],
        memory_module.rams.rams[valE_i+2],memory_module.rams.rams[valE_i+1],
        memory_module.rams.rams[valE_i]});
        
        #2;
        icode_i = `IPUSHQ;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        $display("M[valE_o]= %h", {memory_module.rams.rams[valE_i+7],
        memory_module.rams.rams[valE_i+6],memory_module.rams.rams[valE_i+5],
        memory_module.rams.rams[valE_i+4],memory_module.rams.rams[valE_i+3],
        memory_module.rams.rams[valE_i+2],memory_module.rams.rams[valE_i+1],
        memory_module.rams.rams[valE_i]});
        $display("------------Finesh--------------------------------------");
        #2;


        $display("------------4th instruction popq: ----------------");
        $display("valM=M[valA]");
        $display("valM_o = %h", valM_o);
        $display("valA_i = %h", valA_i);
        $display("M[valA]= %h", {memory_module.rams.rams[valA_i+7],
        memory_module.rams.rams[valA_i+6],memory_module.rams.rams[valA_i+5],
        memory_module.rams.rams[valA_i+4],memory_module.rams.rams[valA_i+3],
        memory_module.rams.rams[valA_i+2],memory_module.rams.rams[valA_i+1],
        memory_module.rams.rams[valA_i]});
        
        #2;
        icode_i = `IPOPQ;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        $display("valM = %h", valM_o);
        $display("------------Finesh--------------------------------------");
        #2;


        $display("------------5th instruction popq: ----------------");
        $display("valM=M[valA]");
        $display("valM_o = %h", valM_o);
        $display("valA_i = %h", valA_i);
        $display("M[valA]= %h", {memory_module.rams.rams[valA_i+7],
        memory_module.rams.rams[valA_i+6],memory_module.rams.rams[valA_i+5],
        memory_module.rams.rams[valA_i+4],memory_module.rams.rams[valA_i+3],
        memory_module.rams.rams[valA_i+2],memory_module.rams.rams[valA_i+1],
        memory_module.rams.rams[valA_i]});
        
        #2;
        icode_i = `IPOPQ;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        $display("valM = %h", valM_o);
        $display("------------Finesh--------------------------------------");
        #2;
        

        $display("------------6th instruction CALL: ----------------");
        $display("M[valE] = valP");
        $display("valP = %h", valP_i);
        $display("valE_i = %h", valE_i);
        $display("M[valE]= %h", {memory_module.rams.rams[valE_i+7],
        memory_module.rams.rams[valE_i+6],memory_module.rams.rams[valE_i+5],
        memory_module.rams.rams[valE_i+4],memory_module.rams.rams[valE_i+3],
        memory_module.rams.rams[valE_i+2],memory_module.rams.rams[valE_i+1],
        memory_module.rams.rams[valE_i]});
        
        #2;
        icode_i = `ICALL;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        $display("M[valE] = %h", {memory_module.rams.rams[valE_i+7],
        memory_module.rams.rams[valE_i+6],memory_module.rams.rams[valE_i+5],
        memory_module.rams.rams[valE_i+4],memory_module.rams.rams[valE_i+3],
        memory_module.rams.rams[valE_i+2],memory_module.rams.rams[valE_i+1],
        memory_module.rams.rams[valE_i]});
        $display("------------Finesh--------------------------------------");
        #2;


        $display("------------7th instruction RET: ----------------");
        $display("valM=M[valA]");
        $display("valA = %h", valA_i);
        $display("valM = %h", valM_o);
        $display("M[valA]= %h", {memory_module.rams.rams[valA_i+7],
        memory_module.rams.rams[valA_i+6],memory_module.rams.rams[valA_i+5],
        memory_module.rams.rams[valA_i+4],memory_module.rams.rams[valA_i+3],
        memory_module.rams.rams[valA_i+2],memory_module.rams.rams[valA_i+1],
        memory_module.rams.rams[valA_i]});
        
        #2;
        icode_i = `IRET;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        $display("valM = %h", valM_o);
        $display("------------Finesh--------------------------------------");
        #2;


        $display("------------8th instruction IRMOV: ----------------");
        $display("NOTHING TO DO...");
        $display("valA = %h", valA_i);
        $display("valE = %h", valE_i);
        $display("valM = %h", valP_i);
        $display("M[valA] = %h", {memory_module.rams.rams[valA_i+7],
        memory_module.rams.rams[valA_i+6],memory_module.rams.rams[valA_i+5],
        memory_module.rams.rams[valA_i+4],memory_module.rams.rams[valA_i+3],
        memory_module.rams.rams[valA_i+2],memory_module.rams.rams[valA_i+1],
        memory_module.rams.rams[valA_i]});
        $display("M[valE] = %h", {memory_module.rams.rams[valE_i+7],
        memory_module.rams.rams[valE_i+6],memory_module.rams.rams[valE_i+5],
        memory_module.rams.rams[valE_i+4],memory_module.rams.rams[valE_i+3],
        memory_module.rams.rams[valE_i+2],memory_module.rams.rams[valE_i+1],
        memory_module.rams.rams[valE_i]});
        $display("M[valM] = %h", memory_module.rams.rams[valM_o]);

        
        #2;
        icode_i = `IIRMOVQ;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        $display("valA = %h", valA_i);
        $display("valE = %h", valE_i);
        $display("valM = %h", valP_i);
        $display("M[valA] = %h", {memory_module.rams.rams[valA_i+7],
        memory_module.rams.rams[valA_i+6],memory_module.rams.rams[valA_i+5],
        memory_module.rams.rams[valA_i+4],memory_module.rams.rams[valA_i+3],
        memory_module.rams.rams[valA_i+2],memory_module.rams.rams[valA_i+1],
        memory_module.rams.rams[valA_i]});
        $display("M[valE] = %h", {memory_module.rams.rams[valE_i+7],
        memory_module.rams.rams[valE_i+6],memory_module.rams.rams[valE_i+5],
        memory_module.rams.rams[valE_i+4],memory_module.rams.rams[valE_i+3],
        memory_module.rams.rams[valE_i+2],memory_module.rams.rams[valE_i+1],
        memory_module.rams.rams[valE_i]});
        $display("M[valM] = %h", memory_module.rams.rams[valM_o]);
        $display("------------Finesh--------------------------------------");
        #2;


        $display("------------9th instruction IOPQ: ----------------");
        $display("NOTHING TO DO...");
        $display("valA = %h", valA_i);
        $display("valE = %h", valE_i);
        $display("valM = %h", valP_i);
        $display("M[valA] = %h", {memory_module.rams.rams[valA_i+7],
        memory_module.rams.rams[valA_i+6],memory_module.rams.rams[valA_i+5],
        memory_module.rams.rams[valA_i+4],memory_module.rams.rams[valA_i+3],
        memory_module.rams.rams[valA_i+2],memory_module.rams.rams[valA_i+1],
        memory_module.rams.rams[valA_i]});
        $display("M[valE] = %h", {memory_module.rams.rams[valE_i+7],
        memory_module.rams.rams[valE_i+6],memory_module.rams.rams[valE_i+5],
        memory_module.rams.rams[valE_i+4],memory_module.rams.rams[valE_i+3],
        memory_module.rams.rams[valE_i+2],memory_module.rams.rams[valE_i+1],
        memory_module.rams.rams[valE_i]});
        $display("M[valM] = %h", memory_module.rams.rams[valM_o]);

        
        #2;
        icode_i = `IOPQ;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        $display("valA = %h", valA_i);
        $display("valE = %h", valE_i);
        $display("valM = %h", valP_i);
        $display("M[valA] = %h", {memory_module.rams.rams[valA_i+7],
        memory_module.rams.rams[valA_i+6],memory_module.rams.rams[valA_i+5],
        memory_module.rams.rams[valA_i+4],memory_module.rams.rams[valA_i+3],
        memory_module.rams.rams[valA_i+2],memory_module.rams.rams[valA_i+1],
        memory_module.rams.rams[valA_i]});
        $display("M[valE] = %h", {memory_module.rams.rams[valE_i+7],
        memory_module.rams.rams[valE_i+6],memory_module.rams.rams[valE_i+5],
        memory_module.rams.rams[valE_i+4],memory_module.rams.rams[valE_i+3],
        memory_module.rams.rams[valE_i+2],memory_module.rams.rams[valE_i+1],
        memory_module.rams.rams[valE_i]});
        $display("M[valM] = %h", memory_module.rams.rams[valM_o]);
        $display("------------Finesh--------------------------------------");
        #2;

        $display("------------9th instruction IJXX: ----------------");
        $display("NOTHING TO DO...");
        $display("valA = %h", valA_i);
        $display("valE = %h", valE_i);
        $display("valM = %h", valP_i);
        $display("M[valA] = %h", {memory_module.rams.rams[valA_i+7],
        memory_module.rams.rams[valA_i+6],memory_module.rams.rams[valA_i+5],
        memory_module.rams.rams[valA_i+4],memory_module.rams.rams[valA_i+3],
        memory_module.rams.rams[valA_i+2],memory_module.rams.rams[valA_i+1],
        memory_module.rams.rams[valA_i]});
        $display("M[valE] = %h",{memory_module.rams.rams[valE_i+7],
        memory_module.rams.rams[valE_i+6],memory_module.rams.rams[valE_i+5],
        memory_module.rams.rams[valE_i+4],memory_module.rams.rams[valE_i+3],
        memory_module.rams.rams[valE_i+2],memory_module.rams.rams[valE_i+1],
        memory_module.rams.rams[valE_i]});
        $display("M[valM] = %h", memory_module.rams.rams[valM_o]);

        
        #2;
        icode_i = `IJXX;  // 设定指令
        #2;
        $display("------------EXECUTE-------");
        $display("valA = %h", valA_i);
        $display("valE = %h", valE_i);
        $display("valM = %h", valP_i);
        $display("M[valA] = %h", {memory_module.rams.rams[valA_i+7],
        memory_module.rams.rams[valA_i+6],memory_module.rams.rams[valA_i+5],
        memory_module.rams.rams[valA_i+4],memory_module.rams.rams[valA_i+3],
        memory_module.rams.rams[valA_i+2],memory_module.rams.rams[valA_i+1],
        memory_module.rams.rams[valA_i]});
        $display("M[valE] = %h", {memory_module.rams.rams[valE_i+7],
        memory_module.rams.rams[valE_i+6],memory_module.rams.rams[valE_i+5],
        memory_module.rams.rams[valE_i+4],memory_module.rams.rams[valE_i+3],
        memory_module.rams.rams[valE_i+2],memory_module.rams.rams[valE_i+1],
        memory_module.rams.rams[valE_i]});
        $display("M[valM] = %h", memory_module.rams.rams[valM_o]);
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
