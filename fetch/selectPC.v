`include "define.v"

//注意：这个模块很可能有错。在写完后续模块之后，一定回来重写！

module selectPC(
    input rst_n_i,

    input wire[63:0] predPC_i,
    input wire[63:0] valC_i,//tmp
    input wire[63:0] valP_i,//tmp
    input wire[3:0] icode_i,//tmp
    input wire[63:0] M_valA_i,
    input wire[63:0] W_valM_i,
    input wire M_Cnd_i,
    output wire[63:0] f_pc_o
);

assign f_pc_o=(rst_n_i==0)?64'b0:
                (icode_i==`IHALT)?64'b0:
                (icode_i==`INOP)?valP_i:       //注意：可能有错！
                (icode_i==`IRRMOVQ)?valP_i:
                (icode_i==`IIRMOVQ)?valP_i:
                (icode_i==`IRMMOVQ)?valP_i:
                (icode_i==`IMRMOVQ)?valP_i:
                (icode_i==`IOPQ)?valP_i:
                (icode_i==`IPUSHQ)?valP_i:
                (icode_i==`IPOPQ)?valP_i:
                (icode_i==`ICALL)?valC_i:
                (icode_i==`IRET)?W_valM_i:   //注意：可能有错！
                (icode_i==`IJXX)?((M_Cnd_i==1'b1)?valC_i:valP_i)
                :valP_i;
endmodule





//always@(posedge clk_i or negedge rst_n_i)begin 
// always@(*)begin 
//     if(~rst_n_i)f_pc_o<=64'b0;//pc
//     else begin
//         case(icode_i)
//         `IHALT:f_pc_o=64'b0;
//         `INOP,`IRRMOVQ,`IIRMOVQ,`IRMMOVQ,`IMRMOVQ,
//         `IOPQ,`IPUSHQ,`IPOPQ: f_pc_o=valP_i;
//         `ICALL:f_pc_o=valC_i;
//         `IRET: f_pc_o=W_valM_i;
//         `IJXX: f_pc_o=(M_Cnd_i==1'b1)?valC_i:valP_i;
//         default:f_pc_o=valP_i;
//         endcase
//     end
// end