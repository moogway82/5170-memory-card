library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity at_memory_card is
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
		-- switches
		umbd_n 		: in 	std_logic;
		umbe_n 		: in 	std_logic;
		xms_only_n 	: in 	std_logic;
		-- outputs
		md_dir 			: out 	std_logic := '1';
		ram_bank_cs_l_n	: out 	std_logic_vector(15 downto 1) := (others => '1');
		ram_bank_cs_h_n	: out 	std_logic_vector(15 downto 1) := (others => '1');
		mem_cs_16_n 	: out 	std_logic := 'Z';
		zero_ws_n  		: out 	std_logic := 'Z';
		led_ram_cs_n 	: out 	std_logic := '1';
		led_rom_cs_n 	: out 	std_logic := '1'
	);
end;

architecture behavioral of at_memory_card is
	attribute keep : string;

	signal 	ram_bank_cs 		: std_logic_vector(15 downto 0) := (others => '0'); -- Active High, One more CS than output so that full possible RAM is decoded internally
	signal  rom_decode 			: std_logic := '0';
	signal  card_cs 			: std_logic := '0';  -- This is the commitment to serve the bus on ALE
	signal  ram_la_decode 		: std_logic := '0';
	signal  zero_ws_n_oe 		: std_logic := '1';
	attribute keep of zero_ws_n_oe : signal is "true";

begin

	-- PROCESS: Early Chip Select Decoding as soon as it can
	-- SETS: ram_bank_cs
	-- 
	-- Provide selection signals for ALE latching later and quick asserting of MEM_CS_16
	-- Need to be aware of jumper settings for XMS ONLY and UMB
	--
	chip_select_decoding : process(refresh_n, la, xms_only_n, sa16)
	begin

		ram_bank_cs <= (others => '0');

		-- Select only on memory operations and but not during DRAM refresh cycles
		if refresh_n = '1' then

			case la(23 downto 20) is

				when x"0" => 
					-- Lower 1MB RAM space - Region is only decoded if XMS ONLY is OFF
					if xms_only_n = '1' then 

						case la(19 downto 17) is
							-- Upper 128KB in Conventional RAM (0x08000-0x09FFF)
							when "100" =>
								ram_bank_cs <= (0 => '1', others => '0');
							-- UMB D
							when "110" =>
								if umbd_n = '0' and sa16 = '1' then
									ram_bank_cs <= (0 => '1', others => '0');									
								end if;
							-- UMB E
							when "111" =>
								if umbe_n = '0' and sa16 = '0' then
									ram_bank_cs <= (0 => '1', others => '0');									
								end if;

							when others =>
								ram_bank_cs <= (others => '0');

						end case;

					end if;

				when x"1" => 
					ram_bank_cs <= (1 => '1', others => '0');

				when x"2" =>
					ram_bank_cs <= (2 => '1', others => '0');

				when x"3" =>
					ram_bank_cs <= (3 => '1', others => '0');

				when x"4" =>
					ram_bank_cs <= (4 => '1', others => '0');

				when x"5" =>
					ram_bank_cs <= (5 => '1', others => '0');

				when x"6" =>
					ram_bank_cs <= (6 => '1', others => '0');

				when x"7" =>
					ram_bank_cs <= (7 => '1', others => '0');

				when x"8" =>
					ram_bank_cs <= (8 => '1', others => '0');

				when x"9" =>
					ram_bank_cs <= (9 => '1', others => '0');

				when x"A" =>
					ram_bank_cs <= (10 => '1', others => '0');

				when x"B" =>
					ram_bank_cs <= (11 => '1', others => '0');

				when x"C" =>
					ram_bank_cs <= (12 => '1', others => '0');

				when x"D" =>
					ram_bank_cs <= (13 => '1', others => '0');

				when x"E" =>
					ram_bank_cs <= (14 => '1', others => '0');

				when x"F" =>
				 --Top 1MB space - Region is only decoded if XMS ONLY is ON
				 	if xms_only_n = '0' then 
				 		-- 0xF00000 to 0xFDFFFF only as 0xFE0000 to 0xFFFFFF mirrors 0x0E0000 to 0x0FFFFF 
				 		if not la(19 downto 17) = "111" then
						-- if unsigned(la(19 downto 17)) >= 0 and unsigned(la(19 downto 17)) < 7 then	
							ram_bank_cs <= (15 => '1', others => '0');
						end if;
					end if;

				when others =>
					ram_bank_cs <= (others => '0');

			end case;

		end if;

	end process chip_select_decoding;

	ram_la_decode <= 	'0' when ram_bank_cs = x"0000" else
						'1';

	-- Activate the 16-bit transfer signal (1-wait state) if card selected
	-- If you don't assert this quickly, then the AT will switch to doing a
	-- slow 2x 8-bit transfer, which this doesn't support
    mem_cs_16_n <= 	'0' when ram_la_decode = '1' else
    				'Z';

    -- Decode ROM
	rom_decode  <=  '1' when la = "1111111" and refresh_n = '1' else
					'1' when la = "0000111" and sa16 = '1' and refresh_n = '1' else
					'0';

    -- PROCESS: Latch the SRAM Chip Selection lines for the whole cycle
    -- SETS: card_cs, ram_bank_cs_l_n, ram_bank_cs_h_n, led_rom_cs_n
    -- 
    -- These are shifted to allow for (almost) the full 15MB possible
    -- on the card depending on the selection of the XMS_ONLY_N switch
    -- Ie, RAM chip 1 will do upper 128K conventional + UMBs if XMS_ONLY_N is OFF
    -- Or RAM chip 1 will do the first 1MB of XMS and conventional space ignored
    -- if XMS_ONLY_N is ON.
    --
    p_latch_selection : process(ale, ram_la_decode, sa0, sbhe_n, ram_bank_cs)
    begin

    	-- Trying to implement a transparent latch - GHDL/Yosys requires "--latches" switch for this to work
    	if ale = '1' then

	    	-- Default to not selected
			card_cs <= '0';
			ram_bank_cs_l_n <= (others => '1');
			ram_bank_cs_h_n <= (others => '1');
			led_rom_cs_n <= '1';

    		if ram_la_decode = '1' then

    			card_cs <= '1';

	    		-- XMS ONLY ON, 1MB (0x010000) to 15MB (0xFEFFFF)
	    		if xms_only_n = '0' then 	
	    			if sa0 = '0' then
	    				ram_bank_cs_l_n <= not ram_bank_cs(15 downto 1);
	    			end if;

	    			if sbhe_n = '0' then
	    				ram_bank_cs_h_n <= not ram_bank_cs(15 downto 1);
	    			end if; 

	    		-- XMS ONLY OFF, 512kb (0x008000) to 14MB (0xEFFFFF)
	    		else 						

	    		  	if sa0 = '0' then
	    				ram_bank_cs_l_n <= not ram_bank_cs(14 downto 0);
	    			end if;
	    			if sbhe_n = '0' then
	    				ram_bank_cs_h_n <= not ram_bank_cs(14 downto 0);
	    			end if;

	    		end if;

    		end if;

    		if rom_decode <= '1' then
    			led_rom_cs_n <= '0';
    		end if;

    	end if;

    end process p_latch_selection;

    -- Memory chip Data transciever direction
    -- same as MEMR_N unless it's not selected then it's set to INPUT (ie write) as I can't tristate it
   	-- TODO: If this doesn't work might need to mod the hardware to add the ENABLE signal so can tristate
    md_dir <= 	'0' when memr_n = '0' and card_cs = '1' else
    			'1' when memw_n = '0' and card_cs = '1' else
    			'1';

    -- Light the RAM LED when the card is being accessed
    led_ram_cs_n <= '0' when card_cs = '1' else
    				'1';

    -- Experimental 0WS stuff, didn't seem to crash the 386SX I was testing on, but not sure
    -- if it sped it up either. Leaving it in and if folks want to try it can connect pin 4
    -- to the 0WS signal.

    -- #2 Only during the command - might not be fast enough, I measured between 17 and 20ns from MEMR/W, but
    -- docs say need like 10ish ns from MEMR/W to work
    zero_ws_n_oe 	<= 	'1' when card_cs = '1' and memr_n = '0' else 
    					'1' when card_cs = '1' and memw_n = '0' else
       					'0';

    zero_ws_n 	<= 	'0' when zero_ws_n_oe = '1' else
    				'Z';

end behavioral;


--PIN: CHIP "at_memory_card" ASSIGNED TO AN PLCC84
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
--PIN: ram_bank_cs_l_n_0 	: 74
--PIN: ram_bank_cs_l_n_1 	: 24
--PIN: ram_bank_cs_l_n_2 	: 70
--PIN: ram_bank_cs_l_n_3 	: 58
--PIN: ram_bank_cs_l_n_4 	: 68
--PIN: ram_bank_cs_l_n_5 	: 61
--PIN: ram_bank_cs_l_n_6 	: 75
--PIN: ram_bank_cs_l_n_7 	: 63
--PIN: ram_bank_cs_l_n_8 	: 56
--PIN: ram_bank_cs_l_n_9 	: 25
--PIN: ram_bank_cs_l_n_10 	: 48
--PIN: ram_bank_cs_l_n_11 	: 27
--PIN: ram_bank_cs_l_n_12 	: 51
--PIN: ram_bank_cs_l_n_13 	: 60
--PIN: ram_bank_cs_l_n_14 	: 50
--PIN: ram_bank_cs_h_n_0 	: 76
--PIN: ram_bank_cs_h_n_1 	: 64
--PIN: ram_bank_cs_h_n_2 	: 69
--PIN: ram_bank_cs_h_n_3 	: 21
--PIN: ram_bank_cs_h_n_4 	: 73
--PIN: ram_bank_cs_h_n_5 	: 18
--PIN: ram_bank_cs_h_n_6 	: 67
--PIN: ram_bank_cs_h_n_7 	: 16
--PIN: ram_bank_cs_h_n_8 	: 49
--PIN: ram_bank_cs_h_n_9 	: 65
--PIN: ram_bank_cs_h_n_10 	: 44
--PIN: ram_bank_cs_h_n_11 	: 20
--PIN: ram_bank_cs_h_n_12 	: 54
--PIN: ram_bank_cs_h_n_13 	: 17
--PIN: ram_bank_cs_h_n_14 	: 77
--PIN: umbd_n 			: 6
--PIN: umbe_n 			: 8
--PIN: xms_only_n 		: 57
--PIN: mem_cs_16_n 		: 22
--PIN: refresh_n 		: 10
--PIN: zero_ws_n		: 4
