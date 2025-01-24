library verilog;
use verilog.vl_types.all;
entity pc_update is
    port(
        clk_i           : in     vl_logic;
        rst_n_i         : in     vl_logic;
        instr_valid_i   : in     vl_logic;
        cnd_i           : in     vl_logic;
        icode_i         : in     vl_logic_vector(3 downto 0);
        valC_i          : in     vl_logic_vector(63 downto 0);
        valP_i          : in     vl_logic_vector(63 downto 0);
        valM_i          : in     vl_logic_vector(63 downto 0);
        pc_o            : out    vl_logic_vector(63 downto 0)
    );
end pc_update;
