library verilog;
use verilog.vl_types.all;
entity regs is
    port(
        clk_i           : in     vl_logic;
        rst_n_i         : in     vl_logic;
        srcA_i          : in     vl_logic_vector(3 downto 0);
        srcB_i          : in     vl_logic_vector(3 downto 0);
        dstA_i          : in     vl_logic_vector(3 downto 0);
        dstB_i          : in     vl_logic_vector(3 downto 0);
        dstA_data_i     : in     vl_logic_vector(63 downto 0);
        dstB_data_i     : in     vl_logic_vector(63 downto 0);
        valA_o          : out    vl_logic_vector(63 downto 0);
        valB_o          : out    vl_logic_vector(63 downto 0)
    );
end regs;
