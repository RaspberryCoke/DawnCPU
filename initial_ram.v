module initial_ram (
    input wire clk,
    input wire reset,
    output reg [7:0] buff
);
//////////////////////////////////////////////废弃
    // 文件路径
    parameter FILE_PATH = "data.txt"; // 这个是文件的路径
    
    // 在reset时加载数据
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // 使用$readmemh或$readmemb从文件读取数据到数组
            $readmemh(FILE_PATH, buff);
        end
    end
endmodule
