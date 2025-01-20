library verilog;
use verilog.vl_types.all;
entity cpu_top is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic
    );
end cpu_top;
