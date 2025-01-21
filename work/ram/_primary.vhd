library verilog;
use verilog.vl_types.all;
entity ram is
    port(
        clk_i           : in     vl_logic;
        read_en         : in     vl_logic;
        write_en        : in     vl_logic;
        addr_i          : in     vl_logic_vector(63 downto 0);
        write_data_i    : in     vl_logic_vector(63 downto 0);
        read_data_o     : out    vl_logic_vector(63 downto 0);
        dmem_error_o    : out    vl_logic
    );
end ram;
