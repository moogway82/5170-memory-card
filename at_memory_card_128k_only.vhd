library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity at_memory_card_128k_only is
	port (
		-- inputs from ISA bus
		la 			: in 	std_logic_vector(23 downto 17);
		sa16		: in 	std_logic;
		ale 		: in 	std_logic;
		memr_n 		: in 	std_logic;
		memw_n 		: in 	std_logic;
		refresh_n	: in 	std_logic;
		sa0			: in 	std_logic;
		sbhe_n 		: in 	std_logic;
		---- switches
		umbd_n 		: in 	std_logic;
		umbe_n 		: in 	std_logic;
		xms_only_n 	: in 	std_logic;
		-- outputs
		md_dir 		: out 	std_logic := '1';
		ram_cs_l_n	: out 	std_logic_vector(15 downto 1) := (others => '1');
		ram_cs_h_n	: out 	std_logic_vector(15 downto 1) := (others => '1');
		mem_cs_16_n : out 	std_logic := 'Z';
		-- zero_ws  : out 	std_logic;
		led_ram_cs_n 	: out 	std_logic := '1';
		led_rom_cs_n 	: out 	std_logic := '1'
	);
end;

architecture behavioral of at_memory_card_128k_only is
	signal	la_decoded 	: std_logic := '0';
	signal 	rom_decoded : std_logic := '0';
	signal 	ram_cs 	: std_logic := '0';
begin

	-- Decode LA
	la_decoded <= 	'1' when la = "0000100" and refresh_n = '1' else
					'0';

	-- Decode ROM
	rom_decoded <=  '1' when la = "1111111" and refresh_n = '1' else
					'1' when la = "0000111" and refresh_n = '1' else
					'0';

	mem_cs_16_n <= 	'0' when la_decoded = '1' else
					'Z';

	-- Pass through CS status on ALE high, and Latch on falling edge (transparent latch).
	-- Note: GHDL requires "--latches" option to allow this
	p_latch_ram_cs : process(ale, la_decoded)
	begin
		if ale = '1' then
			if la_decoded = '1' then
				ram_cs <= '1';
			else
				ram_cs <= '0';
			end if;
			-- ROM LED
			if rom_decoded = '1' then led_rom_cs_n <= '0'; else led_rom_cs_n <= '1'; end if;
		end if;
	end process p_latch_ram_cs;

	-- Enable RAM High and Low chips depending on SA0 and SHBE
	ram_cs_l_n(1) <=	'0' when ram_cs = '1' and sa0 = '0' else
						'1';
	ram_cs_h_n(1) <= 	'0' when ram_cs = '1' and sbhe_n = '0' else
						'1';

	-- Set the transciever direction: 0 = driving data bus, 1 = input from data bus (and closest we get to disconnected)
	md_dir <= 	'0'	when ram_cs = '1' and memr_n = '0' else
				'1';

	-- RAM LED
	led_ram_cs_n <= not ram_cs;

end behavioral;


--PIN: CHIP "at_memory_card_128k_only" ASSIGNED TO AN PLCC84
--PIN: sa16      : 9
--PIN: la_0  	: 37
--PIN: la_1 		: 35
--PIN: la_2 		: 33
--PIN: la_3 		: 36
--PIN: la_4 		: 34
--PIN: la_5 		: 31
--PIN: la_6 		: 30
--PIN: ale 		: 46
--PIN: sa0 		: 83
--PIN: sbhe_n 	: 2
--PIN: memr_n 	: 29
--PIN: memw_n 	: 1
--PIN: md_dir 	: 28
--PIN: led_ram_cs_n 	: 11
--PIN: led_rom_cs_n 	: 15
--PIN: ram_cs_l_n_0 	: 74
--PIN: ram_cs_l_n_1 	: 24
--PIN: ram_cs_l_n_2 	: 70
--PIN: ram_cs_l_n_3 	: 58
--PIN: ram_cs_l_n_4 	: 68
--PIN: ram_cs_l_n_5 	: 61
--PIN: ram_cs_l_n_6 	: 75
--PIN: ram_cs_l_n_7 	: 63
--PIN: ram_cs_l_n_8 	: 56
--PIN: ram_cs_l_n_9 	: 25
--PIN: ram_cs_l_n_10 	: 48
--PIN: ram_cs_l_n_11 	: 27
--PIN: ram_cs_l_n_12 	: 51
--PIN: ram_cs_l_n_13 	: 60
--PIN: ram_cs_l_n_14 	: 50
--PIN: ram_cs_h_n_0 	: 76
--PIN: ram_cs_h_n_1 	: 64
--PIN: ram_cs_h_n_2 	: 69
--PIN: ram_cs_h_n_3 	: 21
--PIN: ram_cs_h_n_4 	: 73
--PIN: ram_cs_h_n_5 	: 18
--PIN: ram_cs_h_n_6 	: 67
--PIN: ram_cs_h_n_7 	: 16
--PIN: ram_cs_h_n_8 	: 49
--PIN: ram_cs_h_n_9 	: 65
--PIN: ram_cs_h_n_10 	: 44
--PIN: ram_cs_h_n_11 	: 20
--PIN: ram_cs_h_n_12 	: 54
--PIN: ram_cs_h_n_13 	: 17
--PIN: ram_cs_h_n_14 	: 77
--PIN: umbd_n 			: 6
--PIN: umbe_n 			: 8
--PIN: xms_only_n 		: 57
--PIN: mem_cs_16_n 		: 22
--PIN: refresh_n 		: 10
