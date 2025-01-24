library verilog;
use verilog.vl_types.all;
entity initial_ram is
    generic(
        FILE_PATH       : string  := "data.txt"
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        buff            : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FILE_PATH : constant is 1;
end initial_ram;
