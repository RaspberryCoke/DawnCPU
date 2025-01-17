library verilog;
use verilog.vl_types.all;
entity decode is
    port(
        clk_i           : in     vl_logic;
        rst_n_i         : in     vl_logic;
        rA              : in     vl_logic_vector(3 downto 0);
        rB              : in     vl_logic_vector(3 downto 0);
        icode           : in     vl_logic_vector(3 downto 0);
        valE_i          : in     vl_logic_vector(63 downto 0);
        valM_i          : in     vl_logic_vector(63 downto 0);
        cnd_i           : in     vl_logic;
        valA_o          : out    vl_logic_vector(63 downto 0);
        valB_o          : out    vl_logic_vector(63 downto 0)
    );
end decode;
