module ram(
    input wire clk_i,
    input wire read_en,
    input wire write_en,
    input wire [63:0] addr_i,
    input wire [63:0] write_data_i,
    output  wire [63:0] read_data_o,
    output wire dmem_error_o
);

reg [7:0] rams[1023:0];
integer i;
initial begin 
    
    for(i=0;i<1024;i=i+8)begin
        rams[i]=i/8;
    end
end 
assign dmem_error_o=(addr_i>64'd1017)?1'b1:1'b0;
assign read_data_o=read_en?((addr_i<64'd1017)?rams[addr_i]:64'b0):64'b0;
always@(*)begin 
    if((dmem_error_o==1'b0)&&(write_en==1'b1))begin
        {rams[addr_i+7],       
        rams[addr_i+6],  
        rams[addr_i+5],  
        rams[addr_i+4],  
        rams[addr_i+3],  
        rams[addr_i+2],  
        rams[addr_i+1],  
        rams[addr_i]  
        }  <=write_data_i;
    end
end


endmodule