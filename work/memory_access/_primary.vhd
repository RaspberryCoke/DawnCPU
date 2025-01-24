library verilog;
use verilog.vl_types.all;
entity memory_access is
    port(
        clk_i           : in     vl_logic;
        icode_i         : in     vl_logic_vector(3 downto 0);
        valA_i          : in     vl_logic_vector(63 downto 0);
        valE_i          : in     vl_logic_vector(63 downto 0);
        valP_i          : in     vl_logic_vector(63 downto 0);
        addr_io         : out    vl_logic_vector(63 downto 0);
        valM_o          : out    vl_logic_vector(63 downto 0);
        write_data      : out    vl_logic_vector(63 downto 0);
        dmem_error_o    : out    vl_logic
    );
end memory_access;
