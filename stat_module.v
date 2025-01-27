module stat(
    input wire rst_n_i,
    input wire instr_valid_i,
    input wire hlt_i,
    input wire imem_error_i,
    input wire dmem_error_i,
    output wire [2:0]  stat_o
);
/*
0:ok
1:instr error
2:instr mem error
3:data mem error
4:hlt
5.reset
*/
assign stat_o=(rst_n_i==0)?3'd5:
                (instr_valid_i==0)?3'd1:
                (hlt_i==1)?3'd4:
                (imem_error_i)?3'd2:
                (dmem_error_i)?3'd3:3'd0;

endmodule



//always@(posedge clk_i or negedge rst_n_i)begin 
// always@(*)begin 
//     if(~rst_n_i)begin 
//         stat_o=3'd5;
//     end else begin 
//         if(~instr_valid_i)stat_o=3'd1;
//         else if(hlt_i)stat_o=3'd4;
//         else if(imem_error_i)stat_o=3'd2;
//         else if(dmem_error_i)stat_o=3'd3;
//         else stat_o=3'd0;
//     end
// end
