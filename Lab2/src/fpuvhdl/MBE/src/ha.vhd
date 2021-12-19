library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ha is
    port (
        A, B : in std_logic;
        Y, Cout : out std_logic
    );
end entity ha;

architecture beh of ha is
    
begin
    
    Y<=A xor B;
    Cout<=A and B;
    
end architecture beh;