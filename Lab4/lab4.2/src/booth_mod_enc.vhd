library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity booth_mod_enc is
    port (
        A: in std_logic_vector(2 downto 0);
        O: out std_logic_vector(2 downto 0)
    );
end entity booth_mod_enc;

architecture rtl of booth_mod_enc is
    
begin
    
    process (A)
    begin
        case A is
            -- MSB is sign, LSBs are for MUX
            when "001" | "010" => O<="001"; -- A
            when "011" => O<="010";         -- 2A
            when "100" => O<="110";         -- -2A
            when "101" | "110" => O<="101"; -- -A
            when others => O<="000";        -- 0
        end case;
    end process;
    
end architecture rtl;