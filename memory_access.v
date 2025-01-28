`include "define.v"
module  memory_access(
    input wire clk_i,
    input wire rst_n_i,
    input wire stall_i,
    input wire bubble_i,

    input wire[3:0]icode_i,
    input wire[2:0]stat_i,

    input wire[63:0] valA_i,
    input wire[63:0] valE_i,
    input wire[3:0] dstE_i,
    input wire[3:0] dstM_i,
    input wire cnd_i,

//有一条从cnd到fetch的虚线。没写
    output wire[3:0]icode_o,
    output wire[3:0]stat_o,
    output wire [63:0] valM_o,
    output wire [63:0] valE_o,
    output wire[3:0]dstE_o,
    output wire[3:0]dstM_o,
    output wire[63:0]M_valA_o
);

reg[2:0]stat;
reg[3:0]icode;
reg cnd;
reg[63:0]valE;
reg[63:0]valA;

reg[3:0]dstE;
reg[3:0]dstM;

reg r_en;
reg w_en;

reg[63:0]valM;

reg [7:0] drams[1023:0];

integer i;

always@(posedge stall_i,bubble_i,clk_i or negedge rst_n_i)begin 
    if(~rst_n_i)begin
        stat<=`STAT_RESET;
        icode<=0;

        valA<=0;
        valE<=0;

        dstE<=4'hf;
        dstM<=4'hf;

        r_en<=0;
        w_en<=0;
        for(i=0;i<1024;i=i+1)begin 
            drams[i]=8'b0;
        end
    end else if(stall_i)begin 
        stat<=`STAT_STALL;
    end else if(bubble_i)begin 
        stat<=`STAT_BUBBLE;
        icode<=0;
        valA<=0;
        valE<=0;
        dstE<=4'hf;
        dstM<=4'hf;
        r_en<=0;
        w_en<=0;

    end else begin 
        stat<=`STAT_OK;

        case(icode_i)
            `IRMMOVQ:begin 
                r_en<=1'b0;w_en<=1'b1;
                drams[valE_i]<=valA_i;
                end
            `IMRMOVQ:begin 
                r_en<=1'b1;w_en<=1'b0;
                valM<=drams[valE_i];   
                end
            `IHALT,`INOP,`IIRMOVQ,`IOPQ,`IJXX,`IRRMOVQ:begin 
                r_en<=1'b0;w_en<=1'b0;
                end
            `IPUSHQ:begin 
                r_en<=1'b0;w_en<=1'b1;
                drams[valE_i]<=valA_i;
                end
            `IPOPQ:begin 
                r_en<=1'b1;w_en<=1'b0;
                valM<=drams[valA_i];
                end
            `ICALL:begin 
                r_en<=1'b0;w_en<=1'b1;
                drams[valE_i]<=valA_i;//change from valP_i to valA_i
                end
            `IRET:begin 
                r_en<=1'b1;w_en<=1'b0;
                valM<=drams[valA_i];
                end
            default:begin 
                r_en<=1'b0;w_en<=1'b0;
                end
        endcase
        icode<=icode_i;
        valA<=valA_i;
        valE<=valE_i;
        dstE<=dstE_i;
        dstM<=dstM_i;
    end
end



assign icode_o=icode_i;
//assign dmem_error_o=(mem_addr<64'd1023);//  TODO ->STAT
//assign stat_o=(dmem_error_o==1)?`STAT_DMEM_ERR:`STAT_OK;
assign stat_o=stat_i;
assign valE_o=valE;
assign valM_o=valM;
assign dstE_o=dstE;
assign dstM_o=dstM;
assign M_valA_o=valA;

endmodule