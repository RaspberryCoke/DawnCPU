library verilog;
use verilog.vl_types.all;
entity ram is
    port(
        clk_i           : in     vl_logic;
        r_en            : in     vl_logic;
        w_en            : in     vl_logic;
        addr_i          : in     vl_logic_vector(63 downto 0);
        wdata_i         : in     vl_logic_vector(63 downto 0);
        rdata_o         : out    vl_logic_vector(63 downto 0);
        dmem_error_o    : out    vl_logic
    );
end ram;
