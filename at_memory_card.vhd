library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity at_memory_card is
	port (
		la 			: in 	std_logic_vector(23 downto 17);
		ale 		: in 	std_logic;
		memr_n 		: in 	std_logic;
		memw_n 		: in 	std_logic;
		refresh_n	: in 	std_logic;
		a0 			: in 	std_logic;
		sbhe 		: in 	std_logic;

		md_dir 		: out 	std_logic;
		ram_cs_l_n	: out 	std_logic_vector(15 downto 0);
		ram_cs_h_n	: out 	std_logic_vector(15 downto 0)
	);
end;

architecture behavioral of at_memory_card is

begin
	md_dir <= '1';
	ram_cs_l_n <= x"FFFF";
	ram_cs_h_n <= x"FFFF";
end behavioral;