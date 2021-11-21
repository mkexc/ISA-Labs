library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity myiir is
	port(
		CLK, RST_n, VIN : in std_logic;
		DIN, B0, B1, A1 : in std_logic_vector(12 downto 0);
		DOUT : out std_logic_vector(12 downto 0);
		VOUT : out std_logic
		);
end myiir;

architecture behavior of myiir is

	signal DIN_Trunk : std_logic_vector(9 downto 0);						-- 10 bit
	signal currDout, nextDout : std_logic_vector (10 downto 0);				-- 11 bit
	signal B0_Trunk, B1_Trunk, A1_Trunk : std_logic_vector (10 downto 0);	-- 11 bit
	signal currInt, nextInt : std_logic_Vector (10 downto 0);				-- 11 bit 
	signal nextVout,currVout : std_logic; 					-- validation bits 
	signal mult_b0, mult_b1, mult_a1: std_logic_vector(21 downto 0); 		-- 22 bit

	component adder
	port (
			A,B : 	in std_logic_vector (9 downto 0);
			SEL :	in std_logic; -- '1' add '0' sub
			S :		out std_logic_vector (10 downto 0)
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
				currInt<= (others=> '0');
			else
				currVout<=nextVout; -- Output validation reg
				if(VIN='1') then
					currDout<=nextDout; -- Output data reg
					currInt<=nextInt; -- Internal data reg
				end if;
			end if;
		end if;
	end process regs;

	nextVout<=VIN;
	DOUT<=currDout(6 downto 0) & "000000";
	Vout<=currVout;

	-- Inputs truncation
	DIN_Trunk <= DIN(12 downto 3); -- [10 bit]
	B0_Trunk <= B0(12) & B0(12 downto 3); --  [11 bit]
	B1_Trunk <= B1(12) & B1(12 downto 3); -- [11 bit]
	A1_Trunk <= A1(12) & A1(12 downto 3); -- [11 bit]

	-- Multiplications [11bit*11bit=22bit]
	M_B0 : multiplier port map (A=>B0_Trunk, B=>nextInt, P=>mult_b0);
	M_A1 : multiplier port map (A=>currInt, B=>A1_Trunk, P=>mult_a1);
	M_b1 : multiplier port map (A=>currInt, B=>B1_Trunk, P=>mult_b1);
	
	-- Additions [10bit+10bit=11bit]
	-- Feedforward adder
	A_ff : adder port map (A=>mult_b0(21 downto 12),
					      B=>mult_b1(21 downto 12),
						  SEL=>'0', -- [ + ]
						  S=>nextDout);

	-- Feedback adder
	A_fb : adder port map (A=>DIN_Trunk,
						  B=>mult_a1(21 downto 12),
						  SEL=>'1', -- [ - ]
						  S=>nextInt);

end behavior;
