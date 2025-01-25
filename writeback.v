module writeback(

    input wire [3:0] icode_i,
    input wire [63:0] valE_i,
    input wire [63:0] valM_i,

    input wire instr_valid_i,
    input wire imem_error_i, 
    input wire dmem_error_i, 

    output wire [63:0] valE_o,
    output wire [63:0] valM_o,

    output wire stat_o
);
always@(icode_i)begin 
    $display($time,".writeback.v running.icode:%h.",icode_i);
end

assign valE_o=valE_i;
assign valM_o=valE_i;

assign stat_o=(instr_valid_i==1)||(imem_error_i==1)||(dmem_error_i==1);//todo


endmodule