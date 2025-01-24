`include "define.v"
module  memory_access(
    input wire clk_i,
    input [3:0]icode_i,
    input [63:0] valA_i,
    input [63:0] valE_i,
    input [63:0] valP_i,
    output wire [63:0] valM_o,
    output wire dmem_error_o
);

reg r_en;
reg w_en;
reg[63:0] mem_addr;
reg[63:0] mem_data;

always@(*)begin 
    case(icode_i)
        `IRMMOVQ:begin 
            r_en<=1'b0;
            w_en<=1'b1;
            mem_addr<=valE_i;
            mem_data<=valA_i;
        end

        `IMRMOVQ:begin 
            r_en<=1'b1;
            w_en<=1'b0;
            mem_addr<=valE_i;
        end

        `IHALT,`INOP,`IIRMOVQ,`IOPQ,`IJXX,`IRRMOVQ:begin 
            r_en<=1'b0;
            w_en<=1'b0;
            mem_addr<=64'b0;
            mem_data<=64'b0;
        end

        `IPUSHQ:begin 
            r_en<=1'b0;
            w_en<=1'b1;
            mem_addr<=valE_i;
            mem_data<=valA_i;
        end

        `IPOPQ:begin 
            r_en<=1'b1;
            w_en<=1'b0;
            mem_addr<=valA_i;
        end

        `ICALL:begin 
            r_en<=1'b0;
            w_en<=1'b1;
            mem_addr<=valE_i;
            mem_data<=valP_i;
        end

        `IRET:begin 
            r_en<=1'b1;
            w_en<=1'b0;
            mem_addr<=valA_i;
        end

        default:begin 
            r_en<=1'b0;
            w_en<=1'b0;
            mem_addr<=64'b0;
            mem_data<=64'b0;
        end

    endcase

end

reg [7:0] drams[1023:0];

assign valM_o=r_en?drams[mem_addr]:64'b0;
assign dmem_error_o=(mem_addr<64'd1023);


integer i;

initial begin 
    $display("memory_access.v: drams initial......");
    for(i=0;i<1024;i=i+1)begin 
        drams[i]=8'b0;
    end
end

endmodule