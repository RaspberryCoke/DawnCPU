library verilog;
use verilog.vl_types.all;
entity regs is
    port(
        clk_i           : in     vl_logic;
        rst_n           : in     vl_logic;
        srcA            : in     vl_logic_vector(3 downto 0);
        srcB            : in     vl_logic_vector(3 downto 0);
        dstA            : in     vl_logic_vector(3 downto 0);
        dstB            : in     vl_logic_vector(3 downto 0);
        dstA_data       : in     vl_logic_vector(63 downto 0);
        dstB_data       : in     vl_logic_vector(63 downto 0);
        valA            : out    vl_logic_vector(63 downto 0);
        valB            : out    vl_logic_vector(63 downto 0)
    );
end regs;
