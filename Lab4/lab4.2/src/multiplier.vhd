library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity multiplier is
    generic (
        N : integer := 32
    );
    port (
        A, B : in std_logic_vector(N-1 downto 0);
        Y    : out std_logic_vector(2*N-1 downto 0)
    );
end entity multiplier;

architecture struct of multiplier is

    component partial_products_gen is
        generic (
            N : integer := 32
        );
        port (
            A, B : in std_logic_vector(N-1 downto 0);
            O : out std_logic_vector((N/2+1)*N*2-1 downto 0)
        );
    end component partial_products_gen;

    component dadda_tree is
        generic (
            N: integer := 32
        );
        port (
            A : in std_logic_vector((N/2+1)*N*2-1 downto 0);
            O_1 : out std_logic_vector(N*2-1 downto 0);
            O_2 : out std_logic_vector(N*2-1 downto 0)
        );
    end component dadda_tree;

    component adder is
        generic (
            N : integer := 32
        );
        port (
            A, B : in std_logic_vector(N-1 downto 0);
            Cin  : in std_logic;
            Y    : out std_logic_vector(N-1 downto 0);
            Cout : out std_logic
        );
    end component adder;

    signal PPs: std_logic_vector((N/2+1)*N*2-1 downto 0);
    signal O_1, O_2 : std_logic_vector(N*2-1 downto 0);

begin
    
    pp_gen: partial_products_gen
    generic map (
        N=>N
    )
    port map (
        A=>A, 
        B=>B,
        O=>PPs
    );
    
    tree: dadda_tree
    generic map (
        N=>N
    )
    port map (
        A=>PPs,
        O_1=>O_1,
        O_2=>O_2
    );

    addr: adder 
    generic map (
        N=>2*N
    )
    port map (
        A=>O_1,
        B=>O_2,
        Cin=>'0',
        Y=>Y,
        Cout=>open
    );

end architecture struct;