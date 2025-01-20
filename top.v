`timescale 1ns/1ps
module cpu_top (
    input wire clk,
    input wire rst_n
);

// 定义状态
`define FETCH           3'H0
`define DECODE          3'H1
`define EXECUTE         3'H2
`define MEMORY          3'H3
`define WRITE_BACK      3'H4
`define UPDATE_PC       3'H5


reg [63:0] PC;  
//状态寄存器
reg [2:0] state, next_state;
//保存fetch输出
reg [3:0] icode_reg, ifun_reg, rA_reg, rB_reg;
reg [63:0] valC_reg, valP_reg;
reg instr_valid_reg, imem_error_reg;


//控制信号，驱动各个阶段的行为
//实例化ram内存
reg ram_read_en;
reg ram_read_instruction;
reg ram_write_en;
reg ram_write_data_en;
wire ram_rst_n;
reg [63:0] ram_addr_i;
wire [63:0] ram_write_data_i;
wire [63:0] ram_read_data_o;
wire ram_dmem_error_o;
wire [79:0] ram_read_instruction_o;
//以及寄存器相关
//实例化一个寄存器文件
wire reg_rst_n;
wire [3:0] reg_srcA;
wire [3:0] reg_srcB;
wire [3:0] reg_dstA;
wire [3:0] reg_dstB;
wire [63:0] reg_dstA_data;
wire [63:0] reg_dstB_data;
wire [63:0] reg_valA;
wire [63:0] reg_valB;
//
//实例化一个fetch模块
wire[79:0] instruction_i;
assign instruction_i = ram_read_instruction_o;
wire [3:0] icode;
wire [3:0] ifun;
wire[3:0] rA;
wire [3:0] rB;
wire [63:0] valC;
wire [63:0] valP;
wire instr_valid;
wire imem_error;
//实例化一个decode模块
reg[63:0] valE_i;
reg[63:0] valM_i;
reg[63:0] valA_o;
reg[63:0] valB_o;
//



always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= `FETCH;  // 复位时进入FETCH阶段
    else
        state <= next_state;  // 否则进入下一个状态
end

//下一个状态
always @(*) begin
    case (state)
        `FETCH: next_state = `FETCH;  
        `DECODE: next_state = `EXECUTE; 
        `EXECUTE: next_state = `MEMORY; 
        `MEMORY: next_state = `WRITE_BACK; 
        `WRITE_BACK: next_state = `UPDATE_PC; 
        `UPDATE_PC: next_state = `FETCH;  
        default: next_state = `FETCH; 
    endcase
end

// 控制信号
always @(*) begin
    //默认
    ram_read_en = 0;
    ram_read_instruction = 0;
    ram_write_en = 0;
    ram_write_data_en = 0;
    icode_reg <= 4'b0;
    ifun_reg <= 4'b0;
    rA_reg <= 4'b0;
    rB_reg <= 4'b0;
    valC_reg <= 64'b0;
    valP_reg <= 64'b0;
    instr_valid_reg <= 0;
    imem_error_reg <= 0;

    case (state)
        `FETCH: begin
            ram_read_en = 1;//从内存读指令
            ram_read_instruction = 1;//启用指令读取
            ram_addr_i=PC;
            icode_reg <= icode;      // 从fetch模块保存icode
            ifun_reg <= ifun;        // 从fetch模块保存ifun
            rA_reg <= rA;            // 从fetch模块保存rA
            rB_reg <= rB;            // 从fetch模块保存rB
            valC_reg <= valC;        // 从fetch模块保存valC
            valP_reg <= valP;        // 从fetch模块保存valP
            instr_valid_reg <= instr_valid;  // 保存指令有效信号
            imem_error_reg <= imem_error;    // 保存内存错误信号
        end
        `DECODE: begin
            
        end
        `EXECUTE: begin

        end
        `MEMORY: begin

        end
        `WRITE_BACK: begin

        end
        `UPDATE_PC: begin

        end
        default: begin
            //出现意外
            ram_read_en = 0;
            ram_read_instruction = 0;
            ram_write_en = 0;
            ram_write_data_en = 0;
        end
    endcase
end



regs regfile(
    .clk_i(clk),
    .rst_n(reg_rst_n),
    .srcA(reg_srcA),
    .srcB(reg_srcB),
    .dstA(reg_dstA),
    .dstB(reg_dstB),
    .dstA_data(reg_dstA_data),
    .dstB_data(reg_dstB_data),
    .valA(reg_valA),//output
    .valB(reg_valB)//output
);

ram rams(
    .clk_i(clk),
    .rst_n(ram_rst_n),
    .read_en(ram_read_en),
    .write_en(ram_write_en),
    .read_instruction(ram_read_instruction),
    .addr_i(ram_addr_i),
    .write_data_i(ram_write_data_i),
    .read_data_o(ram_read_data_o),
    .read_instruction_o(read_instruction_o),
    .dmem_error_o(ram_dmem_error_o)
);

fetch fetch_model(
    .PC_i(PC),
    .instruction_i(instruction_i),
    .icode_o(icode),
    .ifun_o(ifun),
    .rA_o(rA),
    .rB_o(rB),
    .valC_o(valC),
    .valP_o(valP),
    .instr_valid_o(instr_valid),
    .imem_error_o(imem_error)
);


decode decode_model(
    .clk_i(clk),
    .rst_n_i(rst_n),

    .rA(rA_reg),
    .rB(rB_reg),
    .icode(icode_reg),

    .valE_i(valE_i),
    .valM_i(valM_i),



    .valA_o(valA_o),
    .valB_o(valB_o)
);


    initial begin
        //手动填充指令
        //30 F8 08 00 00 00 00 00 00 00
        //由第一个字节的icode分析出后面有立即数，
        //立即数采用了小端存储，也就是在指令里面，是逆序的。

        //irmovq 0x8 %r8    30 f8 08
        rams.rams[0]=8'h30;
         rams.rams[1]=8'hF8;
         rams.rams[2]=8'h08;
         rams.rams[3]=8'h00;
         rams.rams[4]=8'h00;
         rams.rams[5]=8'h00;
         rams.rams[6]=8'h00;
         rams.rams[7]=8'h00;
         rams.rams[8]=8'h00;
         rams.rams[9]=8'h00;

        //irmovq 0x21 %r9 30 f9 21
         rams.rams[10]=8'h30;
         rams.rams[11]=8'hf9;
         rams.rams[12]=8'h21;
         rams.rams[13]=8'h00;
         rams.rams[14]=8'h00;
         rams.rams[15]=8'h00;
         rams.rams[16]=8'h00;
         rams.rams[17]=8'h00;
         rams.rams[18]=8'h00;
         rams.rams[19]=8'h00;

        //rrmovq %r8 %r10 
         rams.rams[20]=8'h20;
         rams.rams[21]=8'h8A;

        //addq %8 %10
         rams.rams[22]=8'h60;
         rams.rams[23]=8'h8A;

        //subq %10 %8
         rams.rams[24]=8'h00;
         rams.rams[25]=8'h00;
         rams.rams[26]=8'h00;
         rams.rams[27]=8'h00;
         rams.rams[28]=8'h00;
         rams.rams[29]=8'h00;

        //subq %rdx %rbx   61 23 
         rams.rams[30]=8'h61;
         rams.rams[31]=8'h23;


        //pushq %rdx
         rams.rams[32]=8'ha0;
         rams.rams[33]=8'h2f;

        //popq %rax
         rams.rams[34]=8'hb0;
         rams.rams[35]=8'h0f;

end 


endmodule