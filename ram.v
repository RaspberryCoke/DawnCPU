module ram(
    input wire clk_i,
    input wire rst_n_i,
    input wire read_en,
    input wire write_en,
    input wire read_instruction_i,
    input wire [63:0] addr_i,
    input wire [63:0] write_data_i,
    output  wire [63:0] read_data_o,
    output wire [79:0] read_instruction_o,
    output wire dmem_error_o
);

reg [7:0] rams[1023:0];
integer i;

//注意：这里简化了判断，应该是1017-8
assign dmem_error_o=(addr_i>64'd1017)?1'b1:1'b0;

//注意：这里简化了判断，应该是1017-8
assign read_data_o=(read_en==1'b1&&read_instruction_i==1'b0)?((addr_i<64'd1017)?
    {rams[addr_i+7],rams[addr_i+6],rams[addr_i+5],rams[addr_i+4],
    rams[addr_i+3],rams[addr_i+2],rams[addr_i+1],rams[addr_i]}:64'b0):64'b0;

assign read_instruction_o=(read_en==1'b1&&read_instruction_i==1'b1)?
((addr_i<64'd1017)?{rams[addr_i+9],rams[addr_i+8],rams[addr_i+7],rams[addr_i+6],rams[addr_i+5],rams[addr_i+4],
   rams[addr_i+3],rams[addr_i+2],rams[addr_i+1],rams[addr_i]}:64'b0):64'b0;

//异步复位的ram，在初始化的时候可以复位。
always@(posedge clk_i )begin 
    if(~rst_n_i)begin 
        for(i=0;i<1024;i=i+1)begin 
            rams[i]<=8'b0;
       end
    end 
    else 
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