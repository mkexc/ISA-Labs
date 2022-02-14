package constants is
	constant Nbit : integer := 4;
	type type_op is (ADD,BITAND,BITXOR,SAR,CMP);
	constant NumInstr: integer := 65534;
	constant InstrSize : integer := 32;
	constant WordSize : integer := 8;
	constant InstrPath: string := "../src/MEM/test_abs2.mem";
	constant NumData : integer := 65534;
	constant DataAddrSize : integer := 32;
	constant DataWordSize : integer := 32;
	constant DataPath : string := "../src/MEM/data_segment.mem";

end package constants;
