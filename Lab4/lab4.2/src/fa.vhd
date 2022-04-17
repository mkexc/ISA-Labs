library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fa is
    port (
        A, B, Cin: in std_logic;
        Y, Cout: out std_logic
    );
end entity fa;

architecture beh of fa is
    
begin
    
    Y   <=  A xor B xor Cin;
    Cout<=  (A and B) or (A and Cin) or (B and Cin);
    
end architecture beh;