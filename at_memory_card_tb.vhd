library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity at_memory_card_tb is
end;

architecture behavioral of at_memory_card_tb is
		-- in
		signal a 			: std_logic_vector(23 downto 16);
		signal ale 			: std_logic;
		signal memr_n 		: std_logic;
		signal refresh_n	: std_logic;
		signal sa0			: std_logic;
		signal sbhe 		: std_logic;
		signal umbd_n 		: std_logic;
		signal umbe_n 		: std_logic;
		-- out
		signal md_dir 		: std_logic;
		signal ram_cs_l_n	: std_logic_vector(15 downto 1);
		signal ram_cs_h_n	: std_logic_vector(15 downto 1);
		signal mem_cs_16_n  : std_logic;

begin

kdb_sim : entity work.at_memory_card
port map( 
	a => a,
	ale => ale, 
	memr_n => memr_n,
	refresh_n => refresh_n,
	sa0 => sa0,
	sbhe => sbhe,
	umbd_n => umbd_n,
	umbe_n => umbe_n,
	md_dir => md_dir,
	ram_cs_l_n => ram_cs_l_n,
	ram_cs_h_n => ram_cs_h_n,
	mem_cs_16_n => mem_cs_16_n
);

tb : process
begin
	a <= x"00";
	umbd_n <= '0';
	umbe_n <= '0';
	wait for  1 us;

	a <= x"0D";
	umbd_n <= '0';
	umbe_n <= '1';
	wait for  1 us;

	a <= x"0E";
	umbd_n <= '0';
	umbe_n <= '1';
	wait for  1 us;

	a <= x"10";
	umbd_n <= '0';
	umbe_n <= '1';
	wait for  1 us;

	a <= x"00";
	umbd_n <= '0';
	umbe_n <= '0';
	wait for  1 us;

	-- End testing by crashing out, wheee!
	assert false report "End of testing, phew!" severity failure;

end process;

end behavioral;