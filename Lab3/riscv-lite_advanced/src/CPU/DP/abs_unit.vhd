library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity abs_unit is
    port (
        A : in std_logic_vector(31 downto 0);
        Y : out std_logic_vector(31 downto 0)
    );
end entity abs_unit;

architecture rtl of abs_unit is
    signal xor_grid: std_logic_vector(31 downto 0);
begin
    
    process(A,xor_grid)
    begin
        for i in 0 to 31 loop
            xor_grid(i) <= A(i) xor A(31);
        end loop;
        Y <= std_logic_vector(signed(xor_grid)+signed(std_logic_vector'(30 downto 0 => '0')&A(31)));
    end process;
    
end architecture rtl;