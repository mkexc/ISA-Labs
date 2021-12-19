library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.functions.all;

-- Parametric Dadda Tree
-- Receives as a parameter the number of bits
-- Input: A = Partial products from Partial products generator
-- Outputs: O_1 and O_2 = The two final outputs to sum with a carry propagation adder (eg. RCA)

entity dadda_tree is
    generic (
        N: integer := 32
    );
    port (
        A : in std_logic_vector((N/2+1)*N*2-1 downto 0);
        O_1 : out std_logic_vector(N*2-1 downto 0);
        O_2 : out std_logic_vector(N*2-1 downto 0)
    );
end entity dadda_tree;

architecture rtl of dadda_tree is
    -- Full Adder
    component fa is
        port (
            A, B, Cin: in std_logic;
            Y, Cout: out std_logic
        );
    end component fa;

    -- Half Adder
    component ha is
        port (
            A, B : in std_logic;
            Y, Cout : out std_logic
        );
    end component ha;

    -- Matrix for easily managing input partial products
    type in_matrix is array (N/2 downto 0) of std_logic_vector(N*2-1 downto 0);
    signal mat_in: in_matrix;

    -- Matrix for managing the actual dadda tree and dadda tree interconnections
    type dadda_mat_subtype is array (N/2 downto 0) of std_logic_vector(2*N downto 0);
    type dadda_mat_type is array (d_calc(N=>N) downto 0) of dadda_mat_subtype;
    signal dadda_mat: dadda_mat_type;

begin
    
    -- Place partial products in temp matrix
    in_matrix_gen: for i in 0 to N/2 generate
        mat_in(i) <= A((i+1)*N*2-1 downto i*2*N);
    end generate in_matrix_gen;
    
    -- Create dadda tree pyramid matrix
    dadda_gen: for i in 1 to d_calc(N=>N) generate
        top_layer_gen: if(i= d_calc(N=>N)) generate
            top_gen: for k in 0 to 2*N-1 generate
                inv_cond: if(k>=N+4) generate
                    inversion: for j in 0 to (N/2+1)/2 generate
                        dadda_mat(i)((N/2)-j)(k) <= mat_in(j)(k);
                        dadda_mat(i)(j)(k) <= mat_in((N/2)-j)(k);
                    end generate inversion;
                end generate inv_cond;
                transp_cond: if(k<N+4) generate
                    transposition: for j in 0 to N/2 generate
                        dadda_mat(i)(j)(k)<=mat_in(j)(k);
                    end generate transposition;
                end generate transp_cond;
            end generate top_gen;
        end generate top_layer_gen;

        -- for every row of the layer
        place: for j in 0 to n_fa_rows(i=>i, N=>N) -1 generate
            -- check needed on the top layer to stop placing FAs when number reaches 4
            check_top: if(n_fa(i=>i,N=>N)-(j*4)>=4) generate
                -- start placing blocks on the left half of the layer
                left_place: for k in N+2 to N+2+(n_fa(i=>i,N=>N)-4*j)/2 generate
                    -- place single half adder on the left
                    ha_place_left: if(k=N+2+(n_fa(i=>i,N=>N)-4*j)/2 and i/=1 ) generate
                        -- Half adder outputs are placed on the next layer, in the row j. The sum is put on same column while the carry is put on the next column
                        -- This can be helpful when transposing down unused bits
                        ha_left_i: ha port map ( 
                            A=>dadda_mat(i)(j*3)(k),
                            B=>dadda_mat(i)(j*3+1)(k),
                            Y=>dadda_mat(i-1)(j+carries_gen(i=>i,k=>k,N=>N))(k),
                            Cout=>dadda_mat(i-1)(j)(k+1)
                        );
                        -- transposition of bits on the left of the placed half adder
                        transp_left_ha: for m in j*3 to pattern_gen(i=>i,k=>k+1,N=>N)-1 generate
                            -- transpose significant bit from current row of current column of current layer =>
                            -- ==> next layer, same column, remaining rows obtained by checking number of carries in column and adding j(number of operators in column)
                            dadda_mat(i-1)(j+carries_gen(i=>i,k=>k+1,N=>N)+(m-j*3))(k+1)<=dadda_mat(i)(m)(k+1);
                        end generate transp_left_ha;
                        -- transposition of significant bits under the placed half adder
                        transp_under_left_ha_cond: if(j*3+2 /= pattern_gen(i=>i,k=>k,N=>N)) generate --check if not 0
                            transp_under_left_ha: for m in j*3+2 to pattern_gen(i=>i,k=>k,N=>N)-1 generate
                                dadda_mat(i-1)(j + 1 + carries_gen(i=>i,k=>k,N=>N) + m-(j*3+2))(k)<=dadda_mat(i)(m)(k);
                            end generate transp_under_left_ha;
                        end generate transp_under_left_ha_cond;
                    end generate ha_place_left;
                    -- Full adder outputs are placed on the next layer, in the row j. The sum is put on same column while the carry is put on the next column
                    -- This can be helpful when transposing down unused bits
                    fa_place_left: if (k/=N+2+(n_fa(i=>i,N=>N)-4*j)/2) generate
                        fa_left_i: fa port map ( 
                            A=>dadda_mat(i)(j*3)(k),
                            B=>dadda_mat(i)(j*3+1)(k),
                            Cin=>dadda_mat(i)(j*3+2)(k),
                            Y=>dadda_mat(i-1)(j+carries_gen(i=>i,k=>k,N=>N))(k),
                            Cout=>dadda_mat(i-1)(j)(k+1)
                        );

                        --if on last row of fas, transpose down significant unused bits, last condition checks if not 0
                        transp_left_fa_center_cond: if((j=n_fa_rows(i=>i,N=>N)-1 or (j<n_fa_rows(i=>i,N=>N) and n_fa(i=>i,N=>N)-(j*4)=4)) and ((j+1)*3/=pattern_gen(i=>i,k=>k,N=>N))) generate
                            transp_left_fa_center: for m in (j+1)*3 to pattern_gen(i=>i,k=>k,N=>N)-1 generate
                                dadda_mat(i-1)(j + 1 + carries_gen(i=>i,k=>k,N=>N) + m - (j+1)*3 )(k)<=dadda_mat(i)(m)(k);
                            end generate transp_left_fa_center;
                        end generate transp_left_fa_center_cond;
                    end generate fa_place_left;
                    
                end generate left_place;
                -- start placing blocks on the right half of the layer
                right_place: for k in N+1 downto N+1-(((n_fa(i=>i,N=>N)-4*j)/2) +1) generate
                    -- place right FAs
                    fa_place_right: if(k>=N+1-((n_fa(i=>i,N=>N)-4*j)/2-1)) generate
                        fa_right_i: fa port map (
                            A=>dadda_mat(i)(j*3)(k),
                            B=>dadda_mat(i)(j*3+1)(k),
                            Cin=>dadda_mat(i)(j*3+2)(k),
                            Y=>dadda_mat(i-1)(j+carries_gen(i=>i,k=>k,N=>N))(k),
                            Cout=>dadda_mat(i-1)(j)(k+1)
                         );

                        --if on last row of fas, transpose down significant unused bits, last condition checks if not 0
                        transp_right_fa_center_cond: if((j=n_fa_rows(i=>i,N=>N)-1 or (j<n_fa_rows(i=>i,N=>N) and n_fa(i=>i,N=>N)-(j*4)=4)) and ((j+1)*3/=pattern_gen(i=>i,k=>k,N=>N))) generate
                            transp_right_fa_center: for m in (j+1)*3 to pattern_gen(i=>i,k=>k,N=>N)-1 generate
                                dadda_mat(i-1)(j + 1 + carries_gen(i=>i,k=>k,N=>N) + m - (j+1)*3 )(k)<=dadda_mat(i)(m)(k);
                            end generate transp_right_fa_center;
                        end generate transp_right_fa_center_cond;
                    end generate fa_place_right;
                    -- Place right HAs
                    ha_place_right: if(k<N+1-((n_fa(i=>i,N=>N)-4*j)/2-1)) generate
                        ha_right_i: ha port map (
                            A=>dadda_mat(i)(j*3)(k),
                            B=>dadda_mat(i)(j*3+1)(k),
                            Y=>dadda_mat(i-1)(j+carries_gen(i=>i,k=>k,N=>N))(k),
                            Cout=>dadda_mat(i-1)(j)(k+1)
                         );
                        -- transposition of significant bits under the placed half adder
                        transp_under_right_ha_cond: if(j*3+2 /= pattern_gen(i=>i,k=>k,N=>N)) generate --check if not 0
                            transp_under_right_ha: for m in j*3+2 to pattern_gen(i=>i,k=>k,N=>N)-1 generate
                                dadda_mat(i-1)( j + 1 + carries_gen(i=>i,k=>k,N=>N) + m-(j*3+2))(k)<=dadda_mat(i)(m)(k);
                            end generate transp_under_right_ha;
                        end generate transp_under_right_ha_cond;
                    end generate ha_place_right;
                end generate right_place;
            end generate check_top;
        end generate place;

        -- transpose unused significant bits on the left down 
        free_transpose_left: if(i/=1 and i/=2) generate -- layer 1 doesn't have HAs on the left, layer 2 significant bits get managed in HAs placing
                columns_left: for k in N+4+(n_fa(i=>i,N=>N))/2 to 2*N-1 generate
                    pull_down_left: for j in 0 to pattern_gen(i=>i,k=>k,N=>N)-1 generate
                        dadda_mat(i-1)(j)(k)<=dadda_mat(i)(j)(k);
                    end generate pull_down_left;
            end generate columns_left;
        end generate free_transpose_left;
        -- transpose significant bits on the right down
        free_transpose_right: for k in N+1-(n_fa(i=>i,N=>N)/2+2) downto 0 generate
            pull_down_right: for j in 0 to pattern_gen(i=>i,k=>k,N=>N)-1 generate
                dadda_mat(i-1)(j)(k)<=dadda_mat(i)(j)(k);
            end generate pull_down_right;
        end generate free_transpose_right;
    end generate dadda_gen;
    
    dadda_mat(0)(1)(1)<='0'; -- assign 0 to bit 1 of second row of layer 0

    -- Outputs assignment
    O_1<=dadda_mat(0)(0)(2*N-1 downto 0);
    O_2<=dadda_mat(0)(1)(2*N-1 downto 0);
    
end architecture rtl;