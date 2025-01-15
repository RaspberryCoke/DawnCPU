library verilog;
use verilog.vl_types.all;
entity fetch is
    port(
        PC_i            : in     vl_logic_vector(63 downto 0);
        icode_o         : out    vl_logic_vector(3 downto 0);
        ifun_o          : out    vl_logic_vector(3 downto 0);
        rA_o            : out    vl_logic_vector(3 downto 0);
        rB_o            : out    vl_logic_vector(3 downto 0);
        valC_o          : out    vl_logic_vector(63 downto 0);
        valP_o          : out    vl_logic_vector(63 downto 0);
        instr_valid_o   : out    vl_logic;
        imem_error_o    : out    vl_logic
    );
end fetch;
