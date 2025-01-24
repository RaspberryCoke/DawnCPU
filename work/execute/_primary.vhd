library verilog;
use verilog.vl_types.all;
entity execute is
    port(
        clk_i           : in     vl_logic;
        rst_n_i         : in     vl_logic;
        icode_i         : in     vl_logic_vector(3 downto 0);
        ifun_i          : in     vl_logic_vector(3 downto 0);
        valA_i          : in     vl_logic_vector(63 downto 0);
        valB_i          : in     vl_logic_vector(63 downto 0);
        valC_i          : in     vl_logic_vector(63 downto 0);
        valE_o          : out    vl_logic_vector(63 downto 0);
        cc_o            : out    vl_logic_vector(2 downto 0);
        cnd_o           : out    vl_logic
    );
end execute;
