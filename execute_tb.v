`include "define.v"
module execute_tb;
      wire clk_i;
      wire rst_n_i ;

      wire[3:0] icode_i ;
      reg [3:0] ifun_i ;

      wire signed[63:0] valA_i ;
      wire signed[63:0] valB_i ;
      wire signed[63:0] valC_i ;

    wire signed[63:0] valE_o ;

    wire Cnd_o;

execute emodule(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .icode_i(icode_i),
    .ifun_i(ifun_i),
    .valA_i(valA_i),
    .valB_i(valB_i),
    .valC_i(valC_i),
    .valE_o(valE_o),
    .Cnd_o(Cnd_o)
);
   assign clk_i=1;
   assign rst_n_i=1;
   assign icode_i=`IOPQ;
   
   assign valA_i=64'd1;
   assign valB_i=64'd1;
initial begin 
    #10 ifun_i=`FADDL;$display("valE: %h\n",valE_o);
    #10 ifun_i=`FSUBL;$display("valE: %h\n",valE_o);


end


endmodule