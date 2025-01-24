module top_single_module(
     input wire clk_i,
     input wire rst_n_i
);

//global input
wire[63:0] PC;

//decode and write_back
wire[63:0] valE;
wire[63:0] valM;


//iram
reg iram_read_en;
reg iram_write_en;
reg iram_read_instruction_en;
reg [63:0] iram_addr_i;
wire [63:0] iram_write_data_i;
wire [63:0] iram_read_data_o;
wire iram_dmem_error_o;
wire [79:0] iram_read_instruction_o;

//dram
reg dram_read_en;
reg dram_write_en;
reg dram_read_instruction_en;
reg [63:0] dram_addr_i;
wire [63:0] dram_write_data_i;
wire [63:0] dram_read_data_o;
wire dram_dmem_error_o;
wire [79:0] dram_read_instruction_o;


//寄存器

wire [3:0] reg_srcA_i;
wire [3:0] reg_srcB_i;
wire [3:0] reg_dstA_i;
wire [3:0] reg_dstB_i;
wire [63:0] reg_dstA_data_i;
wire [63:0] reg_dstB_data_i;
wire [63:0] reg_valA_o;
wire [63:0] reg_valB_o;


//fetch_module
wire[79:0] fetch_instruction_i;
wire [3:0] fetch_icode_o;
wire [3:0] fetch_ifun_o;
wire[3:0] fetch_rA_o;
wire [3:0] fetch_rB_o;
wire [63:0] fetch_valC_o ;
wire [63:0]fetch_valP_o ;
wire fetch_instr_valid_o;
wire fetch_imem_error_o; 

assign fetch_rA_o=reg_srcA_i;
assign fetch_rB_o=reg_srcB_i;

//decode_module

/*
    Decode use RegFile to catch valA and valB.
    Following two parameters are declared at the beginning of this file.
// wire[63:0] decode_valE_i;
// wire[63:0] decode_valM_i;
*/
wire[63:0] decode_valA_o;
wire[63:0] decode_valB_o;

assign decode_valA_o=reg_valA_o;
assign decode_valB_o=reg_valB_o;


//execute_module
reg signed[63:0] execute_valE_o;
reg [2:0] execute_cc_o;
wire execute_cnd_o;


//memory_access
wire[63:0]memory_addr_io;

wire memory_read_en;
wire memory_write_en;

wire [63:0] memory_valM_o;//data to read
wire [63:0] memory_write_data_o;//data to write

wire memory_dmem_error_o;

//write_back module
wire memory_hlt_i;
wire memory_instr_error_i;



//实例化寄存器文件
regs regfile(
    .clk_i(clk),
    .rst_n_i(rst_n_i),
    .srcA_i(reg_srcA_i),
    .srcB_i(reg_srcB_i),
    .dstA_i(reg_dstA_i),
    .dstB_i(reg_dstB_i),
    .dstA_data_i(reg_dstA_data_i),
    .dstB_data_i(reg_dstB_data_i),
    .valA_o(reg_valA_o),//output
    .valB_o(reg_valB_o)//output
);

//实例化内存
ram iram_module(
    .clk_i(clk),
    .rst_n_i(rst_n_i),
    .read_en(iram_read_en),
    .write_en(iram_write_en),
    .read_instruction_en(iram_read_instruction_en),
    .addr_i(iram_addr_i),
    .write_data_i(iram_write_data_i),
    .read_data_o(iram_read_data_o),
    .read_instruction_o(iram_read_instruction_o),
    .dmem_error_o(iram_dmem_error_o)
);


//实例化内存
ram dram_module(
    .clk_i(clk),
    .rst_n_i(rst_n_i),
    .read_en(dram_read_en),
    .write_en(dram_write_en),
    .read_instruction_en(dram_read_instruction_en),
    .addr_i(dram_addr_i),
    .write_data_i(dram_write_data_i),
    .read_data_o(dram_read_data_o),
    .read_instruction_o(dram_read_instruction_o),
    .dmem_error_o(dram_dmem_error_o)
);

//实例化fetch_module
fetch fetch_module(
    .PC_i(PC),
    .instruction_i(iram_read_instruction_o),
    .icode_o(fetch_icode_o),
    .ifun_o(fetch_ifun_o),
    .rA_o(fetch_rA_o),
    .rB_o(fetch_rB_o),
    .valC_o(fetch_valC_o),
    .valP_o(fetch_valP_o),
    .instr_valid_o(fetch_instr_valid_o),
    .imem_error_o(fetch_imem_error_o)
);

//实例化decode_module
decode decode_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .rA_i(fetch_rA_o),
    .rB_i(fetch_rB_o),
    .icode_i(fetch_icode_o),
    .valE_i(valE),
    .valM_i(valM),
    .valA_o(decode_valA_o),
    .valB_o(decode_valB_o)
);

//实例化execute_module
execute execute_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .icode_i(fetch_icode_o),
    .ifun_i(fetch_ifun_o),
    .valA_i(decode_valA_o),
    .valB_i(decode_valB_o),
    .valC_i(fetch_valC_o),
    .valE_o(execute_valE_o),
    .cc_o(execute_cc_o),//可能是不必要的。。。
    .cnd_o(execute_cnd_o)
);

//实例化memory_module
memory_access  memory_module(
    .clk_i(clk_i),
    .icode_i(fetch_icode_o),
    .valA_i(decode_valA_o),
    .valE_i(execute_valE_o),
    .valP_i(fetch_valP_o),

    .addr_io(memory_addr_io),

    .read_en(memory_read_en),
    .write_en(memory_write_en),

    .memory_valM_o

    .valM_o(memory_valM_o),
    .dmem_error_o(memory_dmem_error)
);

//实例化writeback_module
writeback writeback_module(
    // .instr_valid_i(instr_valid_i),
    // .hlt_i(hlt_i),
    // .instr_error_i(instr_error_i),
    // .imem_error_i(imem_error_i), 
    .valE_i(execute_valE_o),
    .valM_i(memory_valM_o),
    .valE_o(valE),
    .valM_o(valM)
    //output wire [1:0]stat_o
);

//实例化pc_update_module
pc_update pc_update_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    // .instr_valid_i(instr_valid_i),
    .cnd_i(execute_cnd_o),
    .icode_i(fetch_icode_o),
    .valC_i(fetch_valC_o),
    .valP_i(fetch_valP_o),
    .valM_i(memory_valM_o),
    .pc_o(PC)
);


// 初始化PC并从RAM中获取指令
always @(posedge clk_i or negedge rst_n_i) begin
    if (~rst_n_i) begin
        ram_addr_i <= 64'b0; // 初始PC为0
        ram_read_en <= 1'b1;
        ram_read_instruction_en <= 1'b1; // 启用内存读取指令
    end else begin
        ram_addr_i <= PC; // 根据当前PC地址来读取指令
        ram_read_en <= 1'b1;
        ram_read_instruction_en <= 1'b1; // 读取指令
    end
end


endmodule