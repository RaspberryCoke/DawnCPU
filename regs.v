module regs(
    input wire clk_i,
    input wire rst_n_i,
    input wire [3:0] srcA_i,
    input wire [3:0] srcB_i,
    input wire [3:0] dstA_i,
    input wire [3:0] dstB_i,
    input wire [63:0] dstA_data_i,
    input wire [63:0] dstB_data_i,

    output wire [63:0] valA_o,
    output wire [63:0] valB_o
);

reg [63:0] regfile[14:0];

assign valA_o=(srcA_i==4'hf)?64'b0:regfile[srcA_i];
assign valB_o=(srcB_i==4'hf)?64'b0:regfile[srcB_i];

always@(posedge clk_i)begin 
    if(dstA_i!=4'hf)regfile[dstA_i]<=dstA_data_i;
    if(dstB_i!=4'hf)regfile[dstB_i]<=dstB_data_i;
end

endmodule