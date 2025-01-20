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
reg[79:0] instruction_i;
wire [3:0] icode;
wire [3:0] ifun;
wire[3:0] rA;
wire [3:0] rB;
wire [63:0] valC;
wire [63:0] valP;
wire instr_valid;
wire imem_error;
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
        `FETCH: next_state = `DECODE;  
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

    case (state)
        `FETCH: begin
            ram_read_en = 1;//从内存读指令
            ram_read_instruction = 1;//启用指令读取
            ram_addr_i=PC;
            instruction_i=ram_read_instruction_o;
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

endmodule