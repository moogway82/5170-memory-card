library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity at_memory_card_tb is
end;

architecture behavioral of at_memory_card_tb is
		-- in
		signal sa 			: std_logic_vector(19 downto 1) := (others => '0');
		signal sa0			: std_logic;
		signal la 			: std_logic_vector(23 downto 17) := (others => '0');
		signal a_cnt		: std_logic_vector(23 downto 0) := (others => '0');
		signal a_inc 		: std_logic;
		signal d_inc 		: std_logic;
		signal data_cnt : std_logic_vector(15 downto 0) := (others => '0');
		signal data 		: std_logic_vector(15 downto 0);
		signal ale 			: std_logic := '0';
		signal memr_n 		: std_logic := '1';
		signal memw_n 		: std_logic := '1';
		signal refresh_n	: std_logic;
		signal sbhe_n 		: std_logic;
		signal umbd_n 		: std_logic;
		signal umbe_n 		: std_logic;
		signal xms_only_n 	: std_logic;

		-- out
		signal md_dir 		: std_logic;
		signal ram_cs_l_n	: std_logic_vector(15 downto 1);
		signal ram_cs_h_n	: std_logic_vector(15 downto 1);
		signal mem_cs_16_n  : std_logic;
		signal zero_ws_n 	: std_logic;
		signal led_ram_cs_n : std_logic;
		signal led_rom_cs_n : std_logic;

		-- test signal
		signal clk 				: std_logic := '1';
		signal cpu_clk 		: std_logic := '1';
		signal cpu_clk_no  	: integer := 0; 
		signal rw_cycle : std_logic := '0'; -- 0 for Read Cycle, 1 for Write Cycle, jut go between the two
		signal reset 		: std_logic := '1';

		type isa_fsm_type is (R_TS_P1, R_TS_P2, R_TC_P1, R_TC_P2, R_TW_P1, R_TW_P2, W_TS_P1, W_TS_P2, W_TC_P1, W_TC_P2, W_TW_P1, W_TW_P2);
		signal ISA_PS : isa_fsm_type := R_TS_P1;
		signal ISA_NS : isa_fsm_type;
begin

at_memory_card_sim : entity work.at_memory_card
port map( 
	la => la,
	sa16 => sa(16),
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
	ram_bank_cs_l_n => ram_cs_l_n,
	ram_bank_cs_h_n => ram_cs_h_n,
	mem_cs_16_n => mem_cs_16_n,
	zero_ws_n => zero_ws_n,
	led_ram_cs_n => led_ram_cs_n,
	led_rom_cs_n => led_rom_cs_n
);

ram1h : entity work.SRAM
port map (
  A(18 downto 0) => sa(19 downto 1),
  D => data(15 downto 8),
  OE_n => memr_n,
  WE_n => memw_n,
  CE_n => ram_cs_h_n(1)
);

ram1l : entity work.SRAM
port map (
  A(18 downto 0) => sa(19 downto 1),
  D => data(7 downto 0),
  OE_n => memr_n,
  WE_n => memw_n,
  CE_n => ram_cs_l_n(1)
);

p_clk : process
begin
	wait for 41.666666667 ns;
	clk <= '0';
	wait for 41.666666667 ns;
	clk <= '1';
end process p_clk;

-- ISA FSM sequencial part
p_isa_fsm_seq : process(clk, ISA_NS)
begin
  if rising_edge(clk) then
    ISA_PS <= ISA_NS;
  end if;
end process p_isa_fsm_seq;

-- ISA FSM Concurrent part
p_isa_fsm_conc : process(ISA_PS, rw_cycle)
    begin
      -- Preassign the combinational outputs regardless of state - good practise and avoids creating latches
      cpu_clk <= '1';
      a_inc <= '0';
      d_inc <= '0';
      data <= (others => 'Z');
      ale <= '0';
			memr_n <= '1';
			memw_n <= '1';
			la <= (others => '0');

      case ISA_PS is

        -- READ CYCLE

        when R_TS_P1 => 
					cpu_clk <= '1';
					a_inc <= '0';
					d_inc <= '1';
					data <= (others => 'Z');
					ale <= '0';
					memr_n <= '1';
					memw_n <= '1';
					la <= a_cnt(23 downto 17);

					if rw_cycle = '0' then 
        		ISA_NS <= R_TS_P2;
        	else 
        		ISA_NS <= W_TS_P2;
        	end if;

        when R_TS_P2 =>
        	cpu_clk <= '0';
					a_inc <= '0';
					d_inc <= '0';
					data <= (others => 'Z');
					ale <= '1';
					memr_n <= '1';
					memw_n <= '1';
					la <= a_cnt(23 downto 17);

					ISA_NS <= R_TC_P1;

				when R_TC_P1 =>
        	cpu_clk <= '1';
					a_inc <= '0';
					d_inc <= '0';
					data <= (others => 'Z');
					ale <= '0';
					memr_n <= '0';
					memw_n <= '1';
					la <= a_cnt(23 downto 17);

					ISA_NS <= R_TC_P2;

				when R_TC_P2 =>
        	cpu_clk <= '0';
					a_inc <= '0';
					d_inc <= '0';
					data <= (others => 'Z');
					ale <= '0';
					memr_n <= '0';
					memw_n <= '1';
					la <= (others => '0');

					ISA_NS <= R_TW_P1;

				when R_TW_P1 =>
        	cpu_clk <= '1';
					a_inc <= '0';
					d_inc <= '0';
					data <= (others => 'Z');
					ale <= '0';
					memr_n <= '0';
					memw_n <= '1';
					la <= (others => '0');

					ISA_NS <= R_TW_P2;

				when R_TW_P2 =>
        	cpu_clk <= '0';
					a_inc <= '1';
					d_inc <= '0';
					data <= (others => 'Z');
					ale <= '0';
					memr_n <= '0';
					memw_n <= '1';
					la <= a_cnt(23 downto 17);

					ISA_NS <= R_TS_P1;

				-- WRITE CYCLE

				when W_TS_P1 => 
					cpu_clk <= '1';
					a_inc <= '0';
					d_inc <= '1';
					data <= (others => 'Z');
					ale <= '0';
					memr_n <= '1';
					memw_n <= '1';
					la <= a_cnt(23 downto 17);

					if rw_cycle = '0' then 
        		ISA_NS <= R_TS_P2;
        	else 
        		ISA_NS <= W_TS_P2;
        	end if;

       	when W_TS_P2 =>
        	cpu_clk <= '0';
					a_inc <= '0';
					d_inc <= '0';
					data <= x"5555";
					ale <= '1';
					memr_n <= '1';
					memw_n <= '0';
					la <= a_cnt(23 downto 17);

					ISA_NS <= W_TC_P1;

				when W_TC_P1 =>
        	cpu_clk <= '1';
					a_inc <= '0';
					d_inc <= '0';
					data <= x"5555";
					ale <= '0';
					memr_n <= '1';
					memw_n <= '0';
					la <= a_cnt(23 downto 17);

					ISA_NS <= W_TC_P2;

				when W_TC_P2 =>
        	cpu_clk <= '0';
					a_inc <= '0';
					d_inc <= '0';
					data <= x"5555";
					ale <= '0';
					memr_n <= '1';
					memw_n <= '0';
					la <= (others => '0');

					ISA_NS <= W_TW_P1;

				when W_TW_P1 =>
        	cpu_clk <= '1';
					a_inc <= '0';
					d_inc <= '0';
					data <= x"5555";
					ale <= '0';
					memr_n <= '1';
					memw_n <= '0';
					la <= (others => '0');

					ISA_NS <= W_TW_P2;

				when W_TW_P2 =>
        	cpu_clk <= '0';
					a_inc <= '1';
					d_inc <= '0';
					data <= x"5555";
					ale <= '0';
					memr_n <= '1';
					memw_n <= '0';
					la <= a_cnt(23 downto 17);

					ISA_NS <= W_TS_P1;


        when others =>

        	ISA_NS <= R_TS_P1;

       end case;

end process p_isa_fsm_conc;

p_addr_data_rwc : process(a_inc)
begin
	if rising_edge(a_inc) then
			a_cnt(23 downto 13) <= std_logic_vector(unsigned(a_cnt(23 downto 13)) + 1);
			rw_cycle <= not a_cnt(14);
	end if;
end process p_addr_data_rwc;

-- Not using this at the moment, keeping it simple and just asserting "5555" for a write cycle
p_data_inc : process(d_inc)
begin
	if rising_edge(d_inc) then
		data_cnt(15 downto 8) <=  std_logic_vector(unsigned(data_cnt(15 downto 8)) + 1);
		data_cnt(7 downto 0) <=  std_logic_vector(unsigned(data_cnt(7 downto 0)) + 1);
	end if;
end process p_data_inc;



p_saddr : process(ale)
begin
	if rising_edge(ale) then
			sa <= a_cnt(19 downto 1);
	end if;
end process p_saddr;


refresh_n <= '1';

tb : process
begin
	xms_only_n <= '1';
	umbd_n <= '0';
	umbe_n <= '0';
	sbhe_n <= '0';
	sa0 <= '0';
	wait until a_cnt(23 downto 17) = "1111111";
	sbhe_n <= '1';
	sa0 <= '0';
	wait until a_cnt(23 downto 17) = "1111111";	
	sbhe_n <= '0';
	sa0 <= '1';
	wait until a_cnt(23 downto 17) = "1111111";

	
	-- End testing by crashing out, wheee!
	 assert false report "End of testing, phew!" severity failure;

end process;

end behavioral;