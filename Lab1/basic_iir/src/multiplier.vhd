library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
port (
		A,B : 	in std_logic_vector (10 downto 0);
		P :		out std_logic_vector (21 downto 0)
	);
end multiplier;

architecture behavior of multiplier is
	begin
		P <= std_logic_vector(signed(A) * signed(B));
end behavior;
