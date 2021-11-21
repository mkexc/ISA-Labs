library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
port (
		A,B : 	in std_logic_vector (9 downto 0);
		SEL :	in std_logic;
		S :		out std_logic_vector (10 downto 0)
	);
end adder;

architecture behavior of adder is
	begin
		S <= std_logic_vector( to_signed (to_integer(signed(A)) + to_integer(signed(B)), S'length) ) when SEL='0'
		else
		std_logic_vector( to_signed (to_integer(signed(A)) - to_integer(signed(B)), S'length) );
end behavior;
