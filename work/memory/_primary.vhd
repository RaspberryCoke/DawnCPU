library verilog;
use verilog.vl_types.all;
entity memory is
    port(
        icode_i         : in     vl_logic;
        valA_i          : in     vl_logic_vector(63 downto 0);
        valE_i          : in     vl_logic_vector(63 downto 0);
        valP_i          : in     vl_logic_vector(63 downto 0);
        valM_o          : out    vl_logic_vector(63 downto 0)
    );
end memory;
