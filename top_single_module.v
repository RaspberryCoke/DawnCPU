`timescale 1ns/1ps
module top_single_module();
//GLOBAL
//global input
reg clk_i;
reg rst_n_i;
wire[63:0] PC;
reg[63:0] PC_reg;
assign PC=PC_reg;

//DECODE
//used for decode stage and write_back stage
wire[63:0] valE;
wire[63:0] valM;


//RAM
//put two ram out of memory_module.

//iram for instructions
wire iram_read_en=1;
wire iram_write_en=0;
wire iram_read_instruction_en=1;
reg [63:0] iram_addr_i;
wire [63:0] iram_write_data_i;
wire [63:0] iram_read_data_o;
wire iram_dmem_error_o;
wire [79:0] iram_read_instruction_o;

//dram for data
wire dram_read_en;
wire dram_write_en;
reg dram_read_instruction_en;
wire [63:0] dram_addr_i;//
wire [63:0] dram_write_data_i;
wire [63:0] dram_read_data_o;
wire dram_dmem_error_o;
wire [79:0] dram_read_instruction_o;


//REGFILE
wire [3:0] reg_srcA_i;
wire [3:0] reg_srcB_i;
wire [3:0] reg_dstA_i;
wire [3:0] reg_dstB_i;
wire [63:0] reg_dstA_data_i;
wire [63:0] reg_dstB_data_i;
wire [63:0] reg_valA_o;
wire [63:0] reg_valB_o;


//FETCH
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

assign fetch_rA_o=reg_srcA_i;//connect fetch to regfile
assign fetch_rB_o=reg_srcB_i;


//DECODE
//decode_module

/*
    Decode use RegFile to catch valA and valB.
    Following two parameters are declared at the beginning of this file.
// wire[63:0] decode_valE_i;
// wire[63:0] decode_valM_i;
*/

wire[63:0] decode_valA_o;
wire[63:0] decode_valB_o;

assign decode_valA_o=reg_valA_o;//connect decode to regfile
assign decode_valB_o=reg_valB_o;


//EXECUTE
//execute_module
//reg signed[63:0] execute_valE_o;
wire [63:0] execute_valE_o;
wire [2:0] execute_cc_o;
wire execute_cnd_o;


//MEMORY
//memory_access

//   all initial in dram


//WRIET_BACK
//write_back module
wire memory_hlt_i;
wire memory_instr_error_i;



//instantiate
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

    .addr_io(dram_addr_i),

    .read_en(dram_read_en),
    .write_en(dram_write_en),

    .valM_o(dram_read_data_o),
    .write_data(dram_write_data_i),
    .dmem_error_o(dram_dmem_error_o)
);

//实例化writeback_module
writeback writeback_module(
    // .instr_valid_i(instr_valid_i),
    // .hlt_i(hlt_i),
    // .instr_error_i(instr_error_i),
    // .imem_error_i(imem_error_i), 
    .valE_i(execute_valE_o),
    .valM_i(dram_read_data_o),
    .valE_o(valE),
    .valM_o(valM)
    //output wire [1:0]stat_o
);

// //实例化pc_update_module
// pc_update pc_update_module(
//     .clk_i(clk_i),
//     .rst_n_i(rst_n_i),
//     // .instr_valid_i(instr_valid_i),
//     .cnd_i(execute_cnd_o),
//     .icode_i(fetch_icode_o),
//     .valC_i(fetch_valC_o),
//     .valP_i(fetch_valP_o),
//     .valM_i(dram_read_data_o),
//     .pc_o(PC)
// );


// // 初始化PC并从RAM中获取指令
// always @(posedge clk_i or negedge rst_n_i) begin
//     if (~rst_n_i) begin
//         $display("---------------reset----------------");
//         PC_reg<=0;
//         iram_addr_i <= 64'b0; // 初始PC为0
//     end else begin
//         $display("---------------NEXT PC----------------");
//         iram_addr_i <= PC; // 根据当前PC地址来读取指令
//     end
// end

// initial begin
//     rst_n_i=0;#1;
//     rst_n_i=1;#10000;
// end

// initial begin
    
//     clk_i = 0;
//     forever begin
//         #1 clk_i = ~clk_i; // 每 5ns 反转一次时钟
//     end
// end

// initial begin
//     #100 $stop;
// end


// initial begin
//     #1;
//     $monitor("Time=%0t|PC=%d|icode=%h|rA=%h|rB=%h|valA_o=%h|valB_o=%h|valC_o=%h|valE_o=%h|valM_o=%h|valP_o=%h|",
//                 $time, PC_reg, fetch_icode_o, fetch_rA_o, fetch_rB_o, reg_valA_o, reg_valB_o, fetch_valC_o, valE, valM, fetch_valP_o);
// end

initial begin
    rst_n_i=0;#1;
    rst_n_i=1;#1;
    rst_n_i=0;#1;
    rst_n_i=1;#1;

    
		//IRMOVQ�����������أ�
		iram_module.rams[0] = 8'h30; // icode=3, ifun=0
		iram_module.rams[1] = 8'hf8; // rA=F, rB=8
		iram_module.rams[2] = 8'hF0; // valC=0x123456789ABCDEF0 (little-endian)
		iram_module.rams[3] = 8'hDE;
		iram_module.rams[4] = 8'hBC;
		iram_module.rams[5] = 8'h9A;
		iram_module.rams[6] = 8'h78;
		iram_module.rams[7] = 8'h56;
		iram_module.rams[8] = 8'h34;
		iram_module.rams[9] = 8'h12;
		
		//RMMOVQ���Ĵ������ڴ�洢��
		iram_module.rams[10] = 8'h40; // icode=4, ifun=0
		iram_module.rams[11] = 8'h34; // rA=3, rB=4
		iram_module.rams[12] = 8'h10; // valC=0x0010 (little-endian) 16��ʼ
		iram_module.rams[13] = 8'h00;
		iram_module.rams[14] = 8'h00;
		iram_module.rams[15] = 8'h00;
		iram_module.rams[16] = 8'h00;
		iram_module.rams[17] = 8'h00;
		iram_module.rams[18] = 8'h00;
		iram_module.rams[19] = 8'h00;
		
		//MRMOVQ���ڴ浽�Ĵ������أ�
		iram_module.rams[20] = 8'h50; // icode=5, ifun=0
		iram_module.rams[21] = 8'h25; // rA=2, rB=5
		iram_module.rams[22] = 8'h00; // valC=0x0000 (little-endian) 32��ʼ
		iram_module.rams[23] = 8'h0;
		iram_module.rams[24] = 8'h00;
		iram_module.rams[25] = 8'h00;
		iram_module.rams[26] = 8'h00;
		iram_module.rams[27] = 8'h00;
		iram_module.rams[28] = 8'h00;
		iram_module.rams[29] = 8'h00;

		//OPQ�������߼�������
		iram_module.rams[30] = 8'h60; // icode=6, ifun=0 (�ӷ�)
		iram_module.rams[31] = 8'h12; // rA=1, rB=2

		//JXX��������ת��
		iram_module.rams[40] = 8'h70; // icode=7, ifun=0 (��������ת)
		iram_module.rams[41] = 8'h00; // valC=0x3000 (little-endian)
		iram_module.rams[42] = 8'h30;
		iram_module.rams[43] = 8'h00;
		iram_module.rams[44] = 8'h00;
		iram_module.rams[45] = 8'h00;
		iram_module.rams[46] = 8'h00;
		iram_module.rams[47] = 8'h00;
		iram_module.rams[48] = 8'h00;
		iram_module.rams[49] = 8'h00;

        #1;

        iram_addr_i <= 64'b0;
        PC_reg<=0;
        $monitor("Time=%0t|PC=%d|icode=%h|rA=%h|rB=%h|valA_o=%h|valB_o=%h|valC_o=%h|valE_o=%h|valM_o=%h|valP_o=%h|",
                $time, PC_reg, fetch_icode_o, fetch_rA_o, fetch_rB_o, reg_valA_o, reg_valB_o, fetch_valC_o, valE, valM, fetch_valP_o);

                #1;
                $monitor("Time=%0t|PC=%d|icode=%h|rA=%h|rB=%h|valA_o=%h|valB_o=%h|valC_o=%h|valE_o=%h|valM_o=%h|valP_o=%h|",
                $time, PC_reg, fetch_icode_o, fetch_rA_o, fetch_rB_o, reg_valA_o, reg_valB_o, fetch_valC_o, valE, valM, fetch_valP_o);
	end

endmodule