`include"define.v"
module pc_update_module;
      wire clk_i;
      wire rst_n_i;
      wire instr_valid_i;

      wire cnd_i;

      wire[3:0] icode_i;

      wire [63:0] valC_i;
      wire [63:0] valP_i;
      wire [63:0] valM_i;

     reg [63:0] pc_o;

pc_update pc_update_module(
      .clk_i(clk_i),
      .rst_n_i(rst_n_i),
      .instr_valid_i(instr_valid_i),
      .cnd_i(cnd_i),
    .icode_i(icode_i),
    .valC_i(valC_i),
    .valP_i(valP_i),
    .valM_i(valM_i),


     .pc_o(pc_o)
);


//do not need to verify...



// always@(*)begin 
//     case(icode_i)
//     `IHALT:pc_o=64'b0;
//     `INOP,
//     `IRRMOVQ,
//     `IIRMOVQ,
//     `IRMMOVQ,
//     `IMRMOVQ,
//     `IOPQ,
//     `IPUSHQ,
//     `IPOPQ:
//            pc_o=valP_i;
//     `ICALL:pc_o=valC_i;
//     `IRET: pc_o=valM_i;
//     `IJXX: pc_o=(cnd_i==1'b1)?valC_i:valP_i;

//     default:pc_o=valP_i;


//     endcase

// end


endmodule