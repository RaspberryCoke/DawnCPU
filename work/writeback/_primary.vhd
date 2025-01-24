library verilog;
use verilog.vl_types.all;
entity writeback is
    port(
        icode_i         : in     vl_logic_vector(3 downto 0);
        valE_i          : in     vl_logic_vector(63 downto 0);
        valM_i          : in     vl_logic_vector(63 downto 0);
        instr_valid_i   : in     vl_logic;
        imem_error_i    : in     vl_logic;
        dmem_error_i    : in     vl_logic;
        valE_o          : out    vl_logic_vector(63 downto 0);
        valM_o          : out    vl_logic_vector(63 downto 0);
        stat_o          : out    vl_logic
    );
end writeback;
