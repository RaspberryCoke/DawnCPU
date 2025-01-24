library verilog;
use verilog.vl_types.all;
entity writeback is
    port(
        valE_i          : in     vl_logic_vector(63 downto 0);
        valM_i          : in     vl_logic_vector(63 downto 0);
        valE_o          : out    vl_logic_vector(63 downto 0);
        valM_o          : out    vl_logic_vector(63 downto 0)
    );
end writeback;
