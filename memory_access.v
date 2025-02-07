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
    output wire[2:0]stat_o,
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

reg dmem_error;

integer i;

always@(posedge clk_i)begin 
    if(~rst_n_i)begin
        stat<=`SAOK;
        icode<=`INOP;

        valA<=0;
        valE<=0;

        dstE<=`RNONE;
        dstM<=`RNONE;

        r_en<=0;
        w_en<=0;
        dmem_error<=0;
        for(i=0;i<1024;i=i+1)begin 
            drams[i]=8'H10;
        end
    end else if(bubble_i)begin //BUBBLE时，继承的状态是什么
        stat<=`SAOK;
        icode<=`INOP;
        valA<=0;
        valE<=0;
        dstE<=`RNONE;
        dstM<=`RNONE;
        r_en<=0;
        w_en<=0;
        dmem_error<=0;
    end else  if(~stall_i)begin 
        dmem_error<=0;
        stat<=stat_i;
        icode<=icode_i;
        valA<=valA_i;
        valE<=valE_i;
        dstE<=dstE_i;
        dstM<=dstM_i;
        case(icode_i)
            `IRMMOVQ:begin 
                r_en<=1'b0;w_en<=1'b1;
                if(valE>=1023)begin 
                    dmem_error<=1;
                end else begin
                    drams[valE]<=valA;
                    end
                end
            `IMRMOVQ:begin 
                r_en<=1'b1;w_en<=1'b0;
                if(valE>=1023)begin 
                    dmem_error<=1;
                end else begin
                    valM<=drams[valE]; 
                    end
                end
            `IHALT,`INOP,`IIRMOVQ,`IOPQ,`IJXX,`IRRMOVQ:begin 
                r_en<=1'b0;w_en<=1'b0;
                end
            `IPUSHQ:begin 
                r_en<=1'b0;w_en<=1'b1;
                if(valE>=1023)begin 
                    dmem_error<=1;
                end else begin
                    drams[valE]<=valA; 
                    end
                end
            `IPOPQ:begin 
                r_en<=1'b1;w_en<=1'b0;
                if(valA>=1023)begin 
                    dmem_error<=1;
                end else begin
                    valM<=drams[valA];
                    end
                end
            `ICALL:begin 
                r_en<=1'b0;w_en<=1'b1;
                if(valE>=1023)begin 
                    dmem_error<=1;
                end else begin
                    drams[valE]<=valA; //change from valP_i to valA_i
                    end
                end
            `IRET:begin 
                r_en<=1'b1;w_en<=1'b0;
                if(valA>=1023)begin 
                    dmem_error<=1;
                end else begin
                    valM<=drams[valA];
                    end
                end
            default:begin 
                r_en<=1'b0;w_en<=1'b0;
                end
        endcase

    end
end



assign icode_o=icode;
assign dmem_error_o=dmem_error;

assign stat_o=(stat==`SINS)?`SINS://
                (stat==`SADR)?`SADR:
                (stat==`SHLT)?`SHLT:
                dmem_error_o?`SADR:`SAOK;


assign valE_o=valE;
assign valM_o=valM;
assign dstE_o=dstE;
assign dstM_o=dstM;
assign M_valA_o=valA;

endmodule