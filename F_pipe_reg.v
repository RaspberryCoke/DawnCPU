module F_pipe_reg(
    input wire clk_i,
    input wire rst_n_i,
    input wire F_stall_i,
    input wire F_bubble_i,
    input wire[63:0] f_predPC_i,
    output wire[63:0] F_predPC_o
);
reg[63:0]predPC;
always@(posedge clk_i)begin 
    if(~rst_n_i)begin 
        predPC<=64'b0;
    end
    else if(F_bubble_i)begin 
        predPC<=64'b0;
    end
    else if(~F_stall_i)begin 
        predPC<=f_predPC_i;
    end
end
assign F_predPC_o=predPC;

endmodule