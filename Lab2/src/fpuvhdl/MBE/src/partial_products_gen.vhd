library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity partial_products_gen is
    generic (
        N : integer := 32
    );
    port (
        A, B : in std_logic_vector(N-1 downto 0);
        O : out std_logic_vector((N/2+1)*N*2-1 downto 0)
    );
end entity partial_products_gen;

architecture rtl of partial_products_gen is

    component booth_gen is
        generic (
            N : integer := 32
        );
        port (
            B : in std_logic_vector(N-1 downto 0);
            O: out std_logic_vector((N/2+1)*3-1 downto 0)
        );
    end component booth_gen;

    type mat_type is array (N/2 downto 0) of std_logic_vector(2*N-1 downto 0);
    signal out_int : std_logic_vector((N/2+1)*N*2-1 downto 0);
    signal mat : mat_type;
    signal A_2, A_pad : std_logic_vector(N downto 0);
    signal enc_out: std_logic_vector((N/2+1)*3-1 downto 0);
begin

    booth_enc: booth_gen
    generic map (
        N => N
    )
    port map (
        B=>B,
        O=>enc_out
    );

    A_2 <= A&"0";
    A_pad <= "0"&A;

    matrix_gen: for i in 0 to N/2 generate
        
        Twos_comp_gen: if(i /= N/2) generate
            mat(i+1)(2*i) <= enc_out(i*3+2); -- LSB sign on next row
            mat(i+1)(2*i+1) <= '0'; -- Filling hole

            xor_j: for j in 0 to N generate
                mat(i)(j+(2*i))   <=  A_pad(j) xor enc_out(i*3+2) when enc_out(i*3+1 downto i*3) = "01" else
                                A_2(j)   xor enc_out(i*3+2) when enc_out(i*3+1 downto i*3) = "10" else
                                '0';
            end generate xor_j;

        end generate Twos_comp_gen;

        i_0: if(i = 0) generate
            mat(i)(N+2 downto N+1) <= enc_out(i*3+2)&enc_out(i*3+2);
            mat(i)(N+3) <= not(enc_out(i*3+2));
            mat(i)(2*N-1 downto N+4) <= (others => '0'); --Filling MSBs holes
        end generate i_0;

        middle_i: if(i>0 and i<N/2-1) generate
            mat(i)(N+1+i*2) <= not(enc_out(i*3+2));
            mat(i)(N+2+i*2) <= '1';
            mat(i)(2*N-1 downto N+2+i*2+1) <= (others=>'0'); --Filling MSBs holes
            mat(i)(2*(i-1)-1 downto 0) <= (others=>'0'); -- Filling LSBs holes
        end generate middle_i;

        penultimate_i: if(i = N/2-1) generate
            mat(i)(N+1+i*2) <= not(enc_out(i*3+2));
            mat(i)(2*(i-1)-1 downto 0) <= (others=>'0'); -- Filling LSBs holes
        end generate penultimate_i;

        last_i: if(i = N/2) generate
            mat(i)(2*N-1 downto N)  <=  A when enc_out(i*3+1 downto i*3) = "01" else    -- Last row is always either 0 or A => no XOR management neither 2A is required
                                        (others=>'0');                                  -- Also, last row is on N bit, as opposed to N+1, so original non-padded A is selected in the MUX
            mat(i)(2*(i-1)-1 downto 0) <= (others=>'0'); -- Filling LSBs holes
        end generate last_i;

        out_int(2*N*(i+1)-1 downto 2*N*i) <= mat(i);
    end generate matrix_gen;
    
    O<= out_int;
end architecture rtl;
