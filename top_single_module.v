module top_single_module(
     input wire clk_i,
     input wire rst_n_i
);

wire [63:0] PC;


//ram
reg ram_read_en;
reg ram_read_instruction_i;
reg ram_write_en;
reg ram_write_data_en;

reg [63:0] ram_addr_i;
wire [63:0] ram_write_data_i;
wire [63:0] ram_read_data_o;
wire ram_dmem_error_o;
wire [79:0] ram_read_instruction_o;
//寄存器
wire reg_rst_n;
wire [3:0] reg_srcA_i;
wire [3:0] reg_srcB_i;
wire [3:0] reg_dstA_i;
wire [3:0] reg_dstB_i;
wire [63:0] reg_dstA_data_i;
wire [63:0] reg_dstB_data_i;
wire [63:0] reg_valA_o;
wire [63:0] reg_valB_o;
//fetch_module
wire[79:0] instruction_i;
wire [3:0] icode_o;
wire [3:0] ifun_o;
wire[3:0] rA_o;
wire [3:0] rB_o;
wire [63:0] valC_o ;
wire [63:0] valP_o ;
wire instr_valid_o;
wire imem_error_o; 
//decode_module
wire[63:0] valE_i;
wire[63:0] valM_i;
wire[63:0] valA_o;
wire[63:0] valB_o;
//execute_module
reg signed[63:0] valE_o;
reg [2:0] cc_o;
wire Cnd_o;
//memory_access
wire dmem_error_o;
//write_back module
wire hlt_i;
wire instr_error_i;



//定义寄存器文件
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

//定义内存
ram ram_module(
    .clk_i(clk),
    .rst_n_i(rst_n_i),
    .read_en(ram_read_en),
    .write_en(ram_write_en),
    .read_instruction_i(ram_read_instruction_i),
    .addr_i(ram_addr_i),
    .write_data_i(ram_write_data_i),
    .read_data_o(ram_read_data_o),
    .read_instruction_o(ram_read_instruction_o),
    .dmem_error_o(ram_dmem_error_o)
);


//fetch
fetch fetch_module(
    .PC_i(PC),
    .instruction_i(ram_read_instruction_o),
    .icode_o(icode_o),
    .ifun_o(ifun_o),
    .rA_o(rA_o),
    .rB_o(rB_o),
    .valC_o(valC_o),
    .valP_o(valP_o),
    .instr_valid_o(instr_valid_o),
    .imem_error_o(imem_error_o)
);

//decode_module
decode decode_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .rA_i(rA_o),
    .rB_i(rB_o),
    .icode_i(icode_o),
    .valE_i(valE_i),
    .valM_i(valM_i),
    .valA_o(valA_o),
    .valB_o(valB_o)
);

//execute_module
execute execute_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .icode_i(icode_o),
    .ifun_i(ifun_o),
    .valA_i(valA_o),
    .valB_i(valB_o),
    .valC_i(valC_o),
    .valE_o(valE_o),
    .cc_o(cc_o),
    .Cnd_o(Cnd_o)
);

//memory_module
memory_access  memory_module(
    .clk_i(clk_i),
    .icode_i(icode_o),
    .valA_i(valA_o),
    .valE_i(valE_o),
    .valP_i(valP_o),
    .valM_o(valM_o),
    .dmem_error_o(dmem_error)
);

//writeback_module
writeback writeback_module(
    .instr_valid_i(instr_valid_i),
    .hlt_i(hlt_i),
    .instr_error_i(instr_error_i),
    .imem_error_i(imem_error_i), 

    .valE_o(valE_i),
    .valM_o(valM_i)
    //output wire [1:0]stat_o
);

pc_update pc_update_module(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .instr_valid_i(instr_valid_i),
    .cnd_i(Cnd_i),
    .icode_i(icode_o),
    .valC_i(valC_o),
    .valP_i(valP_o),
    .valM_i(valM_o),
    .pc_o(PC)
);


// 初始化PC并从RAM中获取指令
always @(posedge clk_i or negedge rst_n_i) begin
    if (~rst_n_i) begin
        ram_addr_i <= 64'b0; // 初始PC为0
        ram_read_en <= 1'b1;
        ram_read_instruction_i <= 1'b1; // 启用内存读取指令
    end else begin
        ram_addr_i <= PC; // 根据当前PC地址来读取指令
        ram_read_en <= 1'b1;
        ram_read_instruction_i <= 1'b1; // 读取指令
    end
end


endmodule