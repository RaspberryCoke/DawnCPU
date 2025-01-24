`include"define.v"
module pc_update(
    input wire clk_i,
    input wire rst_n_i,
    input wire instr_valid_i,

    input wire cnd_i,

    input wire[3:0] icode_i,

    input wire [63:0] valC_i,
    input wire [63:0] valP_i,
    input wire [63:0] valM_i,

    output reg [63:0] pc_o
);

always@(posedge clk_i or negedge rst_n_i)begin 
    if(~rst_n_i)pc_o<=0;///////////////////////////
    else begin
        case(icode_i)
        `IHALT:pc_o=64'b0;
        `INOP,
        `IRRMOVQ,
        `IIRMOVQ,
        `IRMMOVQ,
        `IMRMOVQ,
        `IOPQ,
        `IPUSHQ,
        `IPOPQ:
            pc_o=valP_i;
        `ICALL:pc_o=valC_i;
        `IRET: pc_o=valM_i;
        `IJXX: pc_o=(cnd_i==1'b1)?valC_i:valP_i;
        default:pc_o=valP_i;
        endcase
    end
end


endmodule