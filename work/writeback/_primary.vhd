library verilog;
use verilog.vl_types.all;
entity writeback is
    port(
        valE_i          : in     vl_logic_vector(63 downto 0);
        valM_i          : in     vl_logic_vector(63 downto 0);
        instr_valid_i   : in     vl_logic;
        hlt_i           : in     vl_logic;
        instr_error_i   : in     vl_logic;
        imem_error_i    : in     vl_logic;
        valE_o          : out    vl_logic_vector(63 downto 0);
        valM_o          : out    vl_logic_vector(63 downto 0)
    );
end writeback;
