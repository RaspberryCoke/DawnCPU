`timescale 1ns/1ps
`include "define.v"
module execute_tb;
      wire clk_i;
      reg rst_n_i ;

      wire[3:0] icode_i ;
      reg [3:0] ifun_i ;

      wire signed[63:0] valA_i ;
      wire signed[63:0] valB_i ;
      wire signed[63:0] valC_i ;

    wire signed[63:0] valE_o ;

    wire Cnd_o;

    wire [2:0] cc;

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
    assign cc=emodule.new_cc;
   assign icode_i=`IOPQ;
   
   assign valA_i=64'd3;
   assign valB_i=64'd2;
initial begin 
    ifun_i=`FADDL;
    rst_n_i=1;
    #5 rst_n_i=~rst_n_i;
    #5 rst_n_i=~rst_n_i;
    ifun_i=`FSUBL;
    #5 rst_n_i=~rst_n_i;
    #5 rst_n_i=~rst_n_i; 
    ifun_i=`FANDL;
    #5 rst_n_i=~rst_n_i; 
    #5 rst_n_i=~rst_n_i; 
    ifun_i=`FXORL;
    #5 rst_n_i=~rst_n_i; 
    #5 rst_n_i=~rst_n_i; 
    #5 ;
end


endmodule