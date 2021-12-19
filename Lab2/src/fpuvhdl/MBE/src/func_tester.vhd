library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.functions.all;

entity func_tester is
    port(
        N,i,k: in integer;
        d,num,fa_rows,fas,pattern_n,carries_n: out integer
    );
end entity func_tester;

architecture rtl of func_tester is
    
begin
    
    d<=d_calc(N=>N);
    num<=num_calc(i=>i,N=>N);
    fa_rows<=n_fa_rows(i=>i,N=>N);
    fas<=n_fa(i=>i,N=>N);
    pattern_n<=pattern_gen(i=>i,k=>k,N=>N);
    carries_n<=carries_gen(i=>i,k=>k,N=>N);

end architecture rtl;