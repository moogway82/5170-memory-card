library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity at_memory_card_tb is
end;

architecture behavioral of at_memory_card_tb is
		-- in
		signal a 			: std_logic_vector(23 downto 16) := x"00";
		signal ale 			: std_logic;
		signal memr_n 		: std_logic;
		signal refresh_n	: std_logic;
		signal sa0			: std_logic;
		signal sbhe_n 		: std_logic;
		signal umbd_n 		: std_logic;
		signal umbe_n 		: std_logic;
		signal xms_only_n 	: std_logic;

		-- out
		signal md_dir 		: std_logic;
		signal ram_cs_l_n	: std_logic_vector(15 downto 1);
		signal ram_cs_h_n	: std_logic_vector(15 downto 1);
		signal mem_cs_16_n  : std_logic;

		-- test signal
		signal cpu_clk 		: std_logic;
		signal cpu_clk_no  	: integer := 0; 
		signal reset 		: std_logic := '1';

begin

at_memory_card_sim : entity work.at_memory_card
port map( 
	a => a,
	ale => ale, 
	memr_n => memr_n,
	refresh_n => refresh_n,
	sa0 => sa0,
	sbhe_n => sbhe_n,
	umbd_n => umbd_n,
	umbe_n => umbe_n,
	xms_only_n => xms_only_n,
	md_dir => md_dir,
	ram_cs_l_n => ram_cs_l_n,
	ram_cs_h_n => ram_cs_h_n,
	mem_cs_16_n => mem_cs_16_n
);

cpu_clock : process
begin
	cpu_clk <= '1';
	wait for 0.166666667 us;
	cpu_clk <= '0';
	wait for 0.166666667 us;
end process cpu_clock;

cpu_clock_count : process(cpu_clk)
begin
	if(rising_edge(cpu_clk)) then
		cpu_clk_no <= cpu_clk_no + 1;
		if(cpu_clk_no = 2) then
			cpu_clk_no <= 0;
		end if;
	end if;
end process cpu_clock_count;

ale <= '1' when cpu_clk = '0' and cpu_clk_no = 0 else
		'0';	

cycle_all_addresses_inputs : process(ale)
begin
	if(reset = '1') then
		a <= x"00";
	elsif(rising_edge(ale)) then
			a <= std_logic_vector(unsigned(a) + 1);
	end if;
end process cycle_all_addresses_inputs;

tb : process
begin
	reset <= '1';
	umbd_n <= '1';
	umbe_n <= '1';
	xms_only_n <= '1';
	refresh_n <= '1';
	sa0 <= '0';
	sbhe_n <= '0';
	wait for  1 us;
	reset <= '0';

	wait until a = x"00";
	umbd_n <= '0';
	umbe_n <= '1';
	xms_only_n <= '1';
	wait until a = x"00";
	umbd_n <= '1';
	umbe_n <= '0';
	xms_only_n <= '1';
	wait until a = x"00";
	umbd_n <= '0';
	umbe_n <= '0';
	xms_only_n <= '1';
	wait until a = x"00";
	umbd_n <= '1';
	umbe_n <= '1';
	xms_only_n <= '0';
	wait until a = x"00";
	umbd_n <= '0';
	umbe_n <= '1';
	xms_only_n <= '0';
	wait until a = x"00";
	umbd_n <= '1';
	umbe_n <= '0';
	xms_only_n <= '0';
	wait until a = x"00";
	umbd_n <= '0';
	umbe_n <= '0';
	xms_only_n <= '0';
	wait until a = x"00";

	sa0 <= '0';
	sbhe_n <= '1';
	umbd_n <= '1';
	umbe_n <= '1';
	xms_only_n <= '1';
	wait until a = x"00";
	umbd_n <= '0';
	umbe_n <= '1';
	xms_only_n <= '1';
	wait until a = x"00";
	umbd_n <= '1';
	umbe_n <= '0';
	xms_only_n <= '1';
	wait until a = x"00";
	umbd_n <= '0';
	umbe_n <= '0';
	xms_only_n <= '1';
	wait until a = x"00";
	umbd_n <= '1';
	umbe_n <= '1';
	xms_only_n <= '0';
	wait until a = x"00";
	umbd_n <= '0';
	umbe_n <= '1';
	xms_only_n <= '0';
	wait until a = x"00";
	umbd_n <= '1';
	umbe_n <= '0';
	xms_only_n <= '0';
	wait until a = x"00";
	umbd_n <= '0';
	umbe_n <= '0';
	xms_only_n <= '0';
	wait until a = x"00";

	sa0 <= '1';
	sbhe_n <= '0';
	umbd_n <= '1';
	umbe_n <= '1';
	xms_only_n <= '1';
	wait until a = x"00";
	umbd_n <= '0';
	umbe_n <= '1';
	xms_only_n <= '1';
	wait until a = x"00";
	umbd_n <= '1';
	umbe_n <= '0';
	xms_only_n <= '1';
	wait until a = x"00";
	umbd_n <= '0';
	umbe_n <= '0';
	xms_only_n <= '1';
	wait until a = x"00";
	umbd_n <= '1';
	umbe_n <= '1';
	xms_only_n <= '0';
	wait until a = x"00";
	umbd_n <= '0';
	umbe_n <= '1';
	xms_only_n <= '0';
	wait until a = x"00";
	umbd_n <= '1';
	umbe_n <= '0';
	xms_only_n <= '0';
	wait until a = x"00";
	umbd_n <= '0';
	umbe_n <= '0';
	xms_only_n <= '0';
	wait until a = x"00";
	
	wait for  1 us;
	umbd_n <= '0';
	umbe_n <= '0';
	wait for  1 us;


	-- End testing by crashing out, wheee!
	assert false report "End of testing, phew!" severity failure;

end process;

end behavioral;