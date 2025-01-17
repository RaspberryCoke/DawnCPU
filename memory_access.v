`include "define.v"
module  memory_access(
    input wire clk_i,
    input [3:0]icode_i,
    input [63:0] valA_i,
    input [63:0] valE_i,
    input [63:0] valP_i,
    output wire [63:0] valM_o,
    output wire dmem_error_o
);

// module ram(
//     input wire clk_i,
//     input wire read_en,
//     input wire write_en,
//     input wire [63:0] addr_i,
//     input wire [63:0] write_data_i,
//     output  wire [63:0] read_data_o,
//     output wire dmem_error_o
// );

wire write_en,read_en;

assign write_en=(icode_i==`IRMMOVQ)||(icode_i==`ICALL)||(icode_i==`IPUSHQ);
assign read_en=(icode_i==`IMRMOVQ)||(icode_i==`IRET)||(icode_i==`IPOPQ);

wire addr;

assign addr=((icode_i==`IRMMOVQ)||(icode_i==`IMRMOVQ)||(icode_i==`ICALL)||(icode_i==`IPUSHQ))?valE_i:
    (((icode_i==`IRET)||(icode_i==`IPOPQ))?valA_i:64'b0);

wire [63:0] write_data_i;
assign write_data_i=((icode_i==`IRMMOVQ)||(icode_i==`IPUSHQ))?valA_i:
    ((icode_i==`ICALL)?valP_i:64'b0);


ram rams(
    .clk_i(clk_i),
    .read_en(read_en),
    .write_en(write_en),
    .addr_i(addr),
    .write_data_i(write_data_i),
    .read_data_o(valM_o),
    .dmem_error_o(dmem_error_o)
);

endmodule