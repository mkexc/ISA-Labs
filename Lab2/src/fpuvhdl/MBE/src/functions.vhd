library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package functions is
    
    function d_calc(N: integer)
                return integer;
    function num_calc(i:integer; N: integer)
                return integer;
    function n_fa_rows(i:integer; N: integer)
                return integer;
    function n_fa(i:integer; N: integer)
                return integer;
    function pattern_gen(i:integer; k: integer; N: integer)
                return integer;
    function carries_gen(i:integer; k: integer; N: integer)
                return integer;

end package functions;

package body functions is

    -- function that computes the number of layers (the index of d) required for the dadda tree to work
    function d_calc(
        N: integer  -- bits of inputs
    )
        return integer is variable d : integer;
        variable num: integer;
        begin
            -- defining starting conditions
            num :=2;
            d := 0;
            -- compute iteratively the d index with the standard formula d(i)=floor(d(i-1)*3/2)
            while num < N/2+1 loop
                d:=d+1;
                num:=num*3/2;
            end loop;
        return d;
    end d_calc; 
    
    -- function that computes the number of rows in a predefined layer i
    function num_calc(
        i: integer; -- layer to compute the number of rows
        N: integer  -- number of bits
    )
        return integer is variable num : integer;
        variable d: integer;
    begin
        num :=2;
        d := 0;
        if(i=d_calc(N=>N)) then -- if we are on top layer
            num:=N/2+1;
        elsif(i=0) then -- if layer 0, the one with the adder
            num:=0;
        else
            while d < i loop
                d:=d+1;
                num:=num*3/2;
            end loop;
        end if;
        return num;
    end num_calc;

    -- function that computes the max number of group of 3 rows that can be filled by full adders in the top row of layer i
    function n_fa_rows(
        i: integer; -- layer to compute the number
        N: integer  -- number of bits
    )
        return integer is variable rows : integer;
    begin
        rows:=num_calc(i=>i,N=>N)/3;    -- take the total number of rows in the layer and divide by 3, then take the floor
        return rows;
    end n_fa_rows;

    -- function that computes the number of full adders in the top row of the layer i 
    function n_fa(
        i: integer; -- layer i
        N: integer  -- number of bits
    )
        return integer is variable n_fas : integer;
        variable k: integer :=1;
    begin
        if(i=0) then -- in the layer of the ADDER, no FAs are needed
            n_fas:=0;
        elsif(i=1) then   -- if on the bottom layer of the tree, define the number of FAs. It is always constant, depending only on the number of bits.
            n_fas:=2*N-4;
        else    -- if on the other layers compute the number of FAs to be instantiated in the top row of the layer 
                -- N_FA(i)=N_FA(i-1)-N_FA_Rows(i-1)*4
            n_fas:=2*N-4; -- starting value
            while k < i loop
                n_fas:=n_fas - n_fa_rows(i=>k, N=>N)*4;
                k:=k+1;
            end loop;
        end if;
        return n_fas;
    end n_fa;

    -- Function that outputs how many significant bits are in the column k of the layer i
    function pattern_gen(
        i:integer; 
        k: integer; 
        N: integer)
        return integer is variable rows : integer := 0;
        variable m : integer := 0;
        variable j : integer := 0;
        variable cnt : integer;
    begin

        if(i=d_calc(N=>N)) then
            cnt := n_fa(i=>i, N=>N);
            while cnt /= 4 loop 
                cnt:=cnt-4;
                j:=j+1;
            end loop;
        else
            j:=n_fa_rows(i=>i,N=>N)-1;
        end if;

        if(k<=N+1) then
            -- RIGHT PATTERN
            for l in N+1 downto 0 loop
                if(l<=N+1 and l>N+1-(n_fa(i=>i,N=>N)-j*4)/2) then
                    -- center
                    rows:=num_calc(i=>i,N=>N); 
                else
                    rows:=num_calc(i=>i,N=>N)-1-m;
                    if((l mod 2) = 0) then
                        rows:=rows+1;
                        m:=m+1;
                    end if;
                end if;
                exit when (l=k);
            end loop;     
        else
            -- LEFT PATTERN
            m:=1;
            for l in N+2 to 2*N-1 loop 
                if(l>=N+2 and l<(N+2+(n_fa(i=>i,N=>N)-j*4)/2)) then
                    -- center
                    rows:=num_calc(i=>i,N=>N);
                else
                    if(l/=(N+2+(n_fa(i=>i,N=>N)-j*4)/2) and (l mod 2) /= 0 ) then
                        m:=m+1;
                    end if;
                    rows:=num_calc(i=>i,N=>N)-m;
                end if;
                exit when (l=k);
            end loop;
        end if;
        return rows;
    end pattern_gen;

     -- Function that outputs how many carries are placed on column k of layer i from column k-1 HAs/FAs
     function carries_gen(
        i:integer; 
        k: integer; 
        N: integer)
        return integer is variable carries : integer := 0;
        variable m : integer := 0;
        variable j : integer := 0;
        variable cnt : integer;
    begin
        if(i=d_calc(N=>N)) then
            cnt := n_fa(i=>i, N=>N);
            while cnt /= 4 loop 
                cnt:=cnt-4;
                j:=j+1;
            end loop;
        else
            j:=n_fa_rows(i=>i,N=>N)-1;
        end if;

        if(k<(n_fa(i=>i,N=>N)-4*j)/2+2+N+2 and k>=N+2-(n_fa(i=>i,N=>N)-4*j)/2-1) then -- CENTER
            carries:=j+1;
        elsif k>=(n_fa(i=>i,N=>N)-4*j)/2+2+N+2 then -- LEFT
            m:=(n_fa(i=>i,N=>N)-4*j)/2+2+N+2;
            carries:=j+1;
            while m <= k and carries > 0 loop -- handles the leftmost bits with zero carries
                if (m mod 2 = 0) then
                    carries:=carries-1;
                end if;
                m:=m+1;
            end loop;
        elsif k<N+2-(n_fa(i=>i,N=>N)-4*j)/2-1 then -- RIGHT
            m:=N+2-(n_fa(i=>i,N=>N)-4*j)/2-2;
            carries:=j+1;
            while m >= k  and carries > 0 loop 
                if ( m mod 2 = 0) then
                    carries:=carries-1;
                end if;
                m:=m-1;
            end loop;
        end if;

        return carries;
    end carries_gen;

end package body functions;