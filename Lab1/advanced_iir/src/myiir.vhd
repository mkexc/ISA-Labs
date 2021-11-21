library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity myiir is
	port(
		CLK, RST_n, VIN : in std_logic;
		DIN, B0, B1_A1B0, A1B1, A1_2 : in std_logic_vector(12 downto 0);
		DOUT : out std_logic_vector(12 downto 0);
		VOUT : out std_logic
		);
end myiir;

architecture behavior of myiir is

	signal DIN_Trunk : std_logic_vector(9 downto 0);						-- 10 bit
	signal currDout, nextDout : std_logic_vector (10 downto 0);				-- 11 bit
	signal B0_Trunk, B1_A1B0_Trunk, A1B1_Trunk, A1_2_Trunk : std_logic_vector (10 downto 0);	-- 11 bit
	signal curr3A, curr3B, next3, curr4, curr5, curr6, next11, curr11 : std_logic_Vector (10 downto 0);				-- 11 bit 
	signal curr1, curr2, next2, curr7, next7, curr8, next9, curr9, next10, curr10 : std_logic_vector(9 downto 0);
	signal nextVout,currVout, currVinDelay1, currVinDelay2, currVinDelay3, currVinDelay4 : std_logic; 					-- validation bits 
	signal mult_b0, mult_b1_a1b0, mult_a1_2, mult_a1b1 : std_logic_vector(21 downto 0); 		-- 22 bit
	component adder
		generic(
			NBIT : integer := 10
		);
	port (
			A,B : 	in std_logic_vector (NBIT-1 downto 0);
			SEL :	in std_logic;
			S :		out std_logic_vector (NBIT downto 0)
		);
	end component;

	component multiplier
	port (
			A,B : 	in std_logic_vector (10 downto 0);
			P :		out std_logic_vector (21 downto 0)
	);
	end component;

begin	
	
	-- Registers process
	regs: process(clk)
	begin
		if(rising_edge(clk)) then
			if(rst_n = '0' ) then
				currDout<=(others => '0');
				currVout<='0';
				curr1<=(others => '0');
				curr2<=(others => '0');
				curr3A<=(others => '0');
				curr3B<=(others => '0');
				curr4<=(others => '0');
				curr5<=(others => '0');
				curr6<=(others => '0');
				curr7<=(others => '0');
				curr8<=(others => '0');
				curr9<=(others => '0');
				curr10<=(others => '0');
				curr11<=(others => '0');
				currVinDelay1<='0';
				currVinDelay2<='0';
				currVinDelay3<='0';
				currVinDelay4<='0';
			else
				currVinDelay1<=VIN; -- Internal validation reg
				currVinDelay2<=currVinDelay1;
				currVinDelay3<=currVinDelay2;
				currVinDelay4<=currVinDelay3;
				currVout<=currVinDelay4;
				if(VIN = '1') then
					curr1<=DIN_Trunk;
					curr2<=next2;
					curr3A<=next3;
					curr5<=curr3A;
				end if;
				if(currVinDelay1 = '1') then
					curr3B<=next3;
					curr4<=curr3A;
					curr6<=curr5;
				end if;
				if(currVinDelay2 = '1') then
					curr7<=next7;
					curr9<=next9;
					curr10<=next10;
				end if;
				if(currVinDelay3 = '1') then
					curr8<=curr7;
					curr11<=next11;
				end if;
				if(currVinDelay4 = '1') then
					currDout<=nextDout; -- Output data reg
				end if;
			end if;
		end if;
	end process regs;

	DOUT<=currDout(6 downto 0) & "000000";
	Vout<=currVout;

	-- Inputs truncation
	DIN_Trunk <= DIN(12 downto 3); -- [10 bit]
	B0_Trunk <= B0(12) & B0(12 downto 3); --  [11 bit]
	B1_A1B0_Trunk <= B1_A1B0(12) & B1_A1B0(12 downto 3); -- [11 bit]
	A1B1_Trunk <= A1B1(12) & A1B1(12 downto 3); -- [11 bit]
	A1_2_Trunk <= A1_2(12) & A1_2(12 downto 3); -- [11 bit]

	-- Multiplications [11bit*11bit=22bit]
	M_B0 : multiplier port map (A=>B0_Trunk, B=>curr3B, P=>mult_b0);
	M_B1_A1B0 : multiplier port map (A=>curr4, B=>B1_A1B0_Trunk, P=>mult_b1_a1b0);
	M_A1B1 : multiplier port map (A=>curr6, B=>A1B1_Trunk, P=>mult_a1b1);
	M_A1_2 : multiplier port map (A=>curr3A, B=>A1_2_Trunk, P=>mult_a1_2);
	
	next2<=mult_a1_2(21 downto 12);
	next7<=mult_b0(21 downto 12);
	next9<=mult_b1_a1b0(21 downto 12);
	next10<=mult_a1b1(21 downto 12);
	
	-- Additions [10bit+10bit=11bit]
	A_1_2 : adder port map (A=>curr1,
					      B=>curr2,
						  SEL=>'0', -- [ + ]
						  S=>next3);

	A_8_11 : adder 
	port map (A=>curr8,
						  B=>curr11(9 downto 0),
						  SEL=>'0', -- [ + ]
						  S=>nextDout);

	A_9_10 : adder port map (A=>curr9,
						B=>curr10,
						SEL=>'0', -- [ + ]
						S=>next11);

end behavior;
