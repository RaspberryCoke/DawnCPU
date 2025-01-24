library verilog;
use verilog.vl_types.all;
entity top_single_module is
    port(
        clk_i           : in     vl_logic;
        rst_n_i         : in     vl_logic
    );
end top_single_module;
