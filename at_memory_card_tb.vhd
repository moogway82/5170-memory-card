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
		signal xms_only_n 	: std_logic;

		-- out
		signal md_dir 		: std_logic;
		signal ram_cs_l_n	: std_logic_vector(15 downto 1);
		signal ram_cs_h_n	: std_logic_vector(15 downto 1);
		signal mem_cs_16_n  : std_logic;

		-- test signal
		signal cpu_clk 		: std_logic;
		signal cpu_clk_no  	: integer := 0; 

begin

at_memory_card_sim : entity work.at_memory_card
port map( 
	a => a,
	ale => ale, 
	memr_n => memr_n,
	refresh_n => refresh_n,
	sa0 => sa0,
	sbhe => sbhe,
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

tb : process
begin
	a <= x"00";
	umbd_n <= '1';
	umbe_n <= '1';
	xms_only_n <= '1';
	refresh_n <= '1';
	sa0 <= '0';
	sbhe <= '0';
	wait for  1 us;

	a <= x"0D";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"0E";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"0F";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"10";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"20";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"30";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"40";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"50";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"60";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"70";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"80";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"90";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"A0";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"B0";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"C0";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"D0";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"E0";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	wait until cpu_clk_no = 0;
	a <= x"F0";
	wait until falling_edge(ale);
	wait until falling_edge(cpu_clk);
	a <= (others => 'Z');

	--a <= x"0D";
	--umbd_n <= '0';
	
	--wait for  500 ns;
	
	--wait for  1 us;

	--a <= x"0D";
	--umbd_n <= '1';
	
	--wait for  500 ns;
	
	--wait for  1 us;

	--a <= x"0D";
	--umbd_n <= '0';
	--xms_only_n <= '0';
	
	--wait for  500 ns;
	
	--wait for  1 us;

	--a <= x"0E";
	--umbd_n <= '1';
	--umbe_n <= '0';
	--xms_only_n <= '1';
	
	--wait for  500 ns;
	
	--wait for  1 us;
	
	--a <= x"10";
	--umbd_n <= '1';
	--umbe_n <= '1';
	--wait for  1 us;

	--a <= x"20";
	--wait for  1 us;

	--a <= x"30";
	--umbd_n <= '0';
	--umbe_n <= '1';
	--wait for  1 us;

	--a <= x"40";
	--umbd_n <= '0';
	--umbe_n <= '1';
	--wait for  1 us;

	--a <= x"50";
	--wait for  1 us;

	--a <= x"50";
	--xms_only_n <= '0';
	--wait for  1 us;


	--a <= x"60";
	--umbd_n <= '0';
	--umbe_n <= '0';
	--wait for  1 us;

	--a <= x"70";
	--umbd_n <= '0';
	--umbe_n <= '1';
	--wait for  1 us;

	--a <= x"80";
	--umbd_n <= '0';
	--umbe_n <= '1';
	--wait for  1 us;

	--a <= x"90";
	--umbd_n <= '0';
	--umbe_n <= '1';
	--wait for  1 us;

	--a <= x"A0";
	--umbd_n <= '0';
	--umbe_n <= '1';
	--wait for  1 us;

	--a <= x"B0";
	--umbd_n <= '0';
	--umbe_n <= '1';
	--wait for  1 us;

	--a <= x"C0";
	--umbd_n <= '0';
	--umbe_n <= '0';
	--wait for  1 us;

	--a <= x"D0";
	--umbd_n <= '0';
	--umbe_n <= '0';
	--wait for  1 us;

	--a <= x"E0";
	--umbd_n <= '0';
	--umbe_n <= '1';
	--wait for  1 us;

	--a <= x"F0";
	--umbd_n <= '0';
	--umbe_n <= '1';
	--wait for  1 us;

	--a <= x"F1";
	--umbd_n <= '0';
	--umbe_n <= '1';
	--wait for  1 us;

	--a <= x"FD";
	--umbd_n <= '0';
	--umbe_n <= '1';
	--wait for  1 us;

	--a <= x"FE";
	--umbd_n <= '0';
	--umbe_n <= '1';
	--wait for  1 us;

	--a <= x"FF";
	--umbd_n <= '0';
	--umbe_n <= '0';
	--wait for  1 us;

	--a <= x"F1";
	--xms_only_n <= '0';
	--wait for  1 us;

	--a <= x"F2";
	--xms_only_n <= '0';
	--wait for  1 us;

	--a <= x"F2";
	--xms_only_n <= '1';
	--wait for  1 us;

	--a <= x"11";
	--sa0 <= '0';
	--sbhe <= '0';
	--wait for  1 us;

	--a <= x"12";
	--sa0 <= '1';
	--sbhe <= '0';
	--wait for  1 us;
	
	--a <= x"13";
	--sa0 <= '0';
	--sbhe <= '1';
	--wait for  1 us;
	
	--a <= x"14";
	--sa0 <= '1';
	--sbhe <= '1';
	--wait for  1 us;

	--a <= x"10";
	--sa0 <= '0';
	--sbhe <= '0';
	--refresh_n <= '0';
	--wait for  1 us;

	--refresh_n <= '1';
	--wait for  1 us;

	--a <= x"A0";
	--refresh_n <= '0';
	--wait for  1 us;

	--a <= x"A0";
	--refresh_n <= '1';
	
	wait for  1 us;
	a <= x"00";
	umbd_n <= '0';
	umbe_n <= '0';
	wait for  1 us;


	-- End testing by crashing out, wheee!
	assert false report "End of testing, phew!" severity failure;

end process;

end behavioral;