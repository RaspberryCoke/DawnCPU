library verilog;
use verilog.vl_types.all;
entity stat_module is
    port(
        instr_valid_i   : in     vl_logic;
        hlt_i           : in     vl_logic;
        instr_error_i   : in     vl_logic;
        imem_error_i    : in     vl_logic;
        stat_o          : out    vl_logic_vector(1 downto 0)
    );
end stat_module;
