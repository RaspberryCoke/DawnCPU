module regs(
    input wire clk_i,
    input wire rst_n,
    input wire [3:0] srcA,
    input wire [3:0] srcB,
    input wire [3:0] dstA,
    input wire [3:0] dstB,
    input wire [63:0] dstA_data,
    input wire [63:0] dstB_data,

    output wire [63:0] valA,
    output wire [63:0] valB
);

reg [63:0] regfile[14:0];

assign valA=(srcA==4'hf)?64'b0:regfile[srcA];
assign valB=(srcB==4'hf)?64'b0:regfile[srcB];

always@(posedge clk_i)begin 
    if(dstA!=4'hf)regfile[dstA]<=dstA_data;
    if(dstB!=4'hf)regfile[dstB]<=dstB_data;
end

endmodule