library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity at_memory_card_tb is
end;

architecture behavioral of at_memory_card_tb is
		-- in
		signal a 				: std_logic_vector(23 downto 1) := (others => '0');
		signal a_cnt		: std_logic_vector(23 downto 1) := (others => '0');
		signal data_cnt : std_logic_vector(15 downto 0) := (others => '0');
		signal data 		: std_logic_vector(15 downto 0);
		signal ale 			: std_logic := '0';
		signal memr_n 		: std_logic := '1';
		signal memw_n 		: std_logic := '1';
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
		signal led_ram_cs_n : std_logic;
		signal led_rom_cs_n : std_logic;

		-- test signal
		signal clk 				: std_logic := '1';
		signal cpu_clk 		: std_logic := '1';
		signal cpu_clk_no  	: integer := 0; 
		signal rw_cycle : std_logic := '0'; -- 0 for Read Cycle, 1 for Write Cycle, jut go between the two
		signal reset 		: std_logic := '1';

begin

at_memory_card_sim : entity work.at_memory_card
port map( 
	a => a(23 downto 16),
	ale => ale, 
	memr_n => memr_n,
	memw_n => memw_n,
	refresh_n => refresh_n,
	sa0 => sa0,
	sbhe_n => sbhe_n,
	umbd_n => umbd_n,
	umbe_n => umbe_n,
	xms_only_n => xms_only_n,
	md_dir => md_dir,
	ram_cs_l_n => ram_cs_l_n,
	ram_cs_h_n => ram_cs_h_n,
	mem_cs_16_n => mem_cs_16_n,
	led_ram_cs_n => led_ram_cs_n,
	led_rom_cs_n => led_rom_cs_n
);

ram1h : entity work.SRAM
  port map (
    A(18 downto 1) => a(18 downto 1),
    A(0) => sa0,
    D => data(15 downto 8),
    OE_n => memr_n,
    WE_n => memw_n,
    CE_n => ram_cs_h_n(15)
  );

ram1l : entity work.SRAM
  port map (
    A(18 downto 1) => a(18 downto 1),
    A(0) => sa0,
    D => data(7 downto 0),
    OE_n => memr_n,
    WE_n => memw_n,
    CE_n => ram_cs_l_n(15)
  );

p_clk : process
begin
	wait for 62.5 ns;
	clk <= '0';
	wait for 62.5 ns;
	clk <= '1';
end process p_clk;

p_cpu_clock : process(clk)
begin
	if falling_edge(clk) then
		cpu_clk <= not cpu_clk;
		if cpu_clk = '0' then
			cpu_clk_no <= cpu_clk_no + 1;
			if cpu_clk_no = 2 then
				cpu_clk_no <= 0;
				rw_cycle <= not rw_cycle;
			end if;
		end if;
	end if;
end process p_cpu_clock;

p_addr : process(clk)
begin
	if falling_edge(clk) then
		if cpu_clk_no = 0 and cpu_clk = '1'  then
			a_cnt(23 downto 15) <= std_logic_vector(unsigned(a_cnt(23 downto 15)) + 1);
		end if;
	end if;
end process p_addr;

refresh_n <= '1';

a <= a_cnt when ale = '1';

ale <= 	'1' when cpu_clk_no = 0 and cpu_clk = '0' else
				'0';

memr_n <= '0' when rw_cycle = '0' and (cpu_clk_no = 1 or cpu_clk_no = 2) else
					'1';

memw_n <= '0' when rw_cycle = '1' and (cpu_clk_no = 1 or cpu_clk_no = 2) else
					'1';

p_data : process(clk)
begin
	if falling_edge(clk) then
		if rw_cycle = '0' then
			data <= (others => 'Z');
		elsif cpu_clk_no = 0 and cpu_clk = '0' and rw_cycle = '1' then 
			data_cnt(15 downto 8) <=  std_logic_vector(unsigned(data_cnt(15 downto 8)) + 1);
			data_cnt(7 downto 0) <=  std_logic_vector(unsigned(data_cnt(7 downto 0)) + 1);
			data <= data_cnt;
		end if;
	end if;
end process p_data;


tb : process
begin
	xms_only_n <= '0';
	sbhe_n <= '0';
	sa0 <= '0';
	wait until a = "00000000000000000000000";
	wait until a = "00000000000000000000000";
	sa0 <= '1';
	wait until a = "00000000000000000000000";
	sbhe_n <= '1';
	sa0 <= '0';
	wait until a = "00000000000000000000000";
	xms_only_n <= '1';
	sbhe_n <= '0';
	sa0 <= '0';
	wait until a = "00000000000000000000000";
	wait until a = "00000000000000000000000";
	sa0 <= '1';
	wait until a = "00000000000000000000000";
	sbhe_n <= '1';
	sa0 <= '0';
	wait until a = "00000000000000000000000";
	
	-- End testing by crashing out, wheee!
	assert false report "End of testing, phew!" severity failure;

end process;

end behavioral;