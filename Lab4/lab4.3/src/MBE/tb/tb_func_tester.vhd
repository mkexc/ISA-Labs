library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_func_tester is
end entity tb_func_tester;

architecture rtl of tb_func_tester is
    component func_tester is
        port(
            N,i,k: in integer;
            d,num,fa_rows,fas,pattern_n, carries_n: out integer
        );
    end component func_tester;

    signal N_s, i_s, k_s, d_s,num_s,fa_rows_s,fas_s, pattern_n_s, carries_n_s : integer;
begin
    
    UUT: func_tester
    port map (
        N=>N_s,
        i=>i_s,
        k=>k_s,
        d=>d_s,
        num=>num_s,
        fa_rows=>fa_rows_s,
        fas=>fas_s,
        pattern_n=>pattern_n_s,
        carries_n=>carries_n_s
    );
    
    process
    begin
        N_s<=16; i_s<=4;
        for m in 0 to 31 loop 
            k_s<=m;
            wait for 10 ns;
        end loop;
        -- k_s<=16;
        -- wait for 10 ns;
        -- k_s<=15;
        -- wait for 10 ns;
        -- k_s<=14;
        -- wait for 10 ns;
        -- k_s<=13;
        -- wait for 10 ns;
        -- k_s<=0;
        -- wait for 10 ns;
        -- k_s<=19;
        -- wait for 10 ns;
        -- k_s<=20;
        -- wait for 10 ns;
        -- k_s<=21;
        -- wait for 10 ns;
        -- k_s<=22;
        -- wait for 10 ns;
        -- k_s<=23;
        -- wait for 10 ns;
        -- k_s<=31;
        -- wait for 10 ns;
        i_s<=3;
        for m in 0 to 31 loop 
            k_s<=m;
            wait for 10 ns;
        end loop;
        -- k_s<=16;
        -- wait for 10 ns;
        -- k_s<=10;
        -- wait for 10 ns;
        -- k_s<=19;
        -- wait for 10 ns;
        -- k_s<=8;
        -- wait for 10 ns;
        -- k_s<=7;
        -- wait for 10 ns;
        -- k_s<=0;
        -- wait for 10 ns;
        -- k_s<=19;
        -- wait for 10 ns;
        -- k_s<=25;
        -- wait for 10 ns;
        -- k_s<=26;
        -- wait for 10 ns;
        -- k_s<=27;
        -- wait for 10 ns;
        -- k_s<=28;
        -- wait for 10 ns;
        -- k_s<=31;
        -- wait for 10 ns;
        i_s<=2;
        for m in 0 to 31 loop 
            k_s<=m;
            wait for 10 ns;
        end loop;
        i_s<=1;
        for m in 0 to 31 loop 
            k_s<=m;
            wait for 10 ns;
        end loop;
        -- k_s<=16;
        -- wait for 10 ns;
        -- k_s<=10;
        -- wait for 10 ns;
        -- k_s<=19;
        -- wait for 10 ns;
        -- k_s<=8;
        -- wait for 10 ns;
        -- k_s<=7;
        -- wait for 10 ns;
        -- k_s<=0;
        -- wait for 10 ns;
        -- k_s<=1;
        -- wait for 10 ns;
        -- k_s<=2;
        -- wait for 10 ns;
        -- k_s<=3;
        -- wait for 10 ns;
        -- k_s<=4;
        -- wait for 10 ns;
        -- k_s<=19;
        -- wait for 10 ns;
        -- k_s<=25;
        -- wait for 10 ns;
        -- k_s<=26;
        -- wait for 10 ns;
        -- k_s<=27;
        -- wait for 10 ns;
        -- k_s<=28;
        -- wait for 10 ns;
        -- k_s<=31;
        -- wait for 10 ns;
        N_s<=32; 
        i_s<=6;
        for m in 0 to 63 loop 
            k_s<=m;
            wait for 10 ns;
        end loop;
        i_s<=5;
        for m in 0 to 63 loop 
            k_s<=m;
            wait for 10 ns;
        end loop;

        N_s<=8; i_s<=1;
        wait for 10 ns;
        i_s<=0;
        wait for 10 ns;
        N_s<=64; i_s<=8;
        wait for 10 ns;
        wait;
    end process;
end architecture rtl;