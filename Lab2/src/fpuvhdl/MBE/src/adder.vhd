library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Behavioral adder. Set wanted implementation through synthesizer or substitute with structural desired implementation

entity adder is
    generic (
        N : integer := 32
    );
    port (
        A, B : in std_logic_vector(N-1 downto 0);
        Cin  : in std_logic;
        Y    : out std_logic_vector(N-1 downto 0);
        Cout : out std_logic
    );
end entity adder;

architecture beh of adder is
    
begin
    
    process (A,B,Cin)
        variable res: std_logic_vector(N downto 0);
    begin
        res :=  std_logic_vector(unsigned('0'&A)+unsigned('0'&B)+unsigned(std_logic_vector'(""&Cin)));
        Y   <=  res(N-1 downto 0);
        Cout<=  res(N);
    end process;
    
end architecture beh;