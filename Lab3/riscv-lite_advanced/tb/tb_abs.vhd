library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_abs is
end entity tb_abs;

architecture rtl of tb_abs is
    component abs_unit is
        port (
            A : in std_logic_vector(31 downto 0);
            Y : out std_logic_vector(31 downto 0)
        );
    end component abs_unit;

    signal A_s, Y_s : std_logic_vector(31 downto 0);

begin
    
    uut: abs_unit
    port map (
        A => A_s,
        Y => Y_s
    );
    
    process
    begin
        A_s<=std_logic_vector(to_signed(1,A_s'length));
        wait for 10 ns;
        assert signed(Y_s)=abs(signed(A_s)) report "ERROR ABS";
        A_s<=std_logic_vector(to_signed(-5,A_s'length));
        wait for 10 ns;
        assert signed(Y_s)=abs(signed(A_s)) report "ERROR ABS";
        A_s<=std_logic_vector(to_signed(-1,A_s'length));
        wait for 10 ns;
        assert signed(Y_s)=abs(signed(A_s)) report "ERROR ABS";
        A_s<=std_logic_vector(to_signed(0,A_s'length));
        wait for 10 ns;
        assert signed(Y_s)=abs(signed(A_s)) report "ERROR ABS";
        A_s<=(31 downto 0 => '1');
        wait for 10 ns;
        assert signed(Y_s)=abs(signed(A_s)) report "ERROR ABS";
        
        wait;
    end process;
    
end architecture rtl;