library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity at_memory_card is
	port (
		a 			: in 	std_logic_vector(23 downto 16);
		ale 		: in 	std_logic;
		memr_n 		: in 	std_logic;
		refresh_n	: in 	std_logic;
		sa0			: in 	std_logic;
		sbhe 		: in 	std_logic;
		-- switches
		umbd_n 		: in 	std_logic;
		umbe_n 		: in 	std_logic;
		xms_only_n 	: in 	std_logic;

		md_dir 		: out 	std_logic;
		ram_cs_l_n	: out 	std_logic_vector(15 downto 1);
		ram_cs_h_n	: out 	std_logic_vector(15 downto 1);
		mem_cs_16_n : out 	std_logic


	);
end;

architecture behavioral of at_memory_card is
	signal 	ram_cs 			: std_logic_vector(15 downto 0); -- Active High, One more CS than output so that full possible RAM is decoded internally
	signal 	ram_cs_l_int_n	: std_logic_vector(15 downto 1);
	signal 	ram_cs_h_int_n	: std_logic_vector(15 downto 1);

begin
	-- Decode initially, assuming that the RAM for the missing bits from 512KB to 1MB is required and will use SRAM1.
	-- If the <1MB decoding is not required, will be offset by 1 when output
	-- If we just want to do XMS, then allocate RAM chip 15 to 0xF00000 to 0xFDFFFF
	ram_cs 	<= 	"0000000000000001" when a(23 downto 16) = x"08" or a(23 downto 16) = x"09" else -- 0x080000 to 0x09FFFF 128KB
				"0000000000000001" when a(23 downto 16) = x"0D" and umbd_n = '0' else 			-- 0x0D0000 to 0xODFFFF 64KB UMB [SW]
				"0000000000000001" when a(23 downto 16) = x"0E" and umbe_n = '0' else			-- 0x0E0000 to 0x0EFFFF 64KB UMB [SW]
				"0000000000000010" when a(23 downto 20) = x"1" else 							-- 0x100000 to 0x1FFFFF 1MB
				"0000000000000100" when a(23 downto 20) = x"2" else
				"0000000000001000" when a(23 downto 20) = x"3" else
				"0000000000010000" when a(23 downto 20) = x"4" else
				"0000000000100000" when a(23 downto 20) = x"5" else
				"0000000001000000" when a(23 downto 20) = x"6" else
				"0000000010000000" when a(23 downto 20) = x"7" else
				"0000000100000000" when a(23 downto 20) = x"8" else
				"0000001000000000" when a(23 downto 20) = x"9" else
				"0000010000000000" when a(23 downto 20) = x"A" else
				"0000100000000000" when a(23 downto 20) = x"B" else
				"0001000000000000" when a(23 downto 20) = x"C" else
				"0010000000000000" when a(23 downto 20) = x"D" else
				"0100000000000000" when a(23 downto 20) = x"E" else
				"1000000000000000" when unsigned(a(23 downto 16)) >= x"F0" and unsigned(a(23 downto 16)) < x"FD" else 	-- 0xF00000 to 0xFDFFFF	
				"0000000000000000";

	ram_cs_l_int_n 	<= 	not ram_cs(15 downto 1) when sa0 = '0' and xms_only_n = '0' and refresh_n = '1' else
						not ram_cs(14 downto 0) when sa0 = '0' and xms_only_n = '1' and refresh_n = '1' else
						(others => '1');

	ram_cs_h_int_n 	<= 	not ram_cs(15 downto 1) when sbhe = '0' and xms_only_n = '0' and refresh_n = '1' else
						not ram_cs(14 downto 0) when sbhe = '0' and xms_only_n = '1' and refresh_n = '1' else
						(others => '1');

	ram_cs_latch : process(ale)
    begin
    	if falling_edge(ale) then
    		ram_cs_l_n <= ram_cs_l_int_n;
    		ram_cs_h_n <= ram_cs_h_int_n;
    	end if;
    end process ram_cs_latch;

	-- If you don't specify outputs then the fitter will crash			
	md_dir 	<= 	'0';
	--ram_cs_l_n <= (others => '0');
	--ram_cs_h_n <= (others => '0');
	mem_cs_16_n <= '1';

end behavioral;