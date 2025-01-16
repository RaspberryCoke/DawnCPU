library verilog;
use verilog.vl_types.all;
entity decode is
    port(
        rA              : in     vl_logic_vector(3 downto 0);
        rB              : in     vl_logic_vector(3 downto 0);
        icode           : in     vl_logic_vector(3 downto 0);
        valA            : out    vl_logic_vector(63 downto 0);
        valB            : out    vl_logic_vector(63 downto 0)
    );
end decode;
