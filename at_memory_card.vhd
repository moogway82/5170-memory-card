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
		md_dir 		: out 	std_logic := '1';
		ram_cs_l_n	: out 	std_logic_vector(15 downto 1) := (others => '1');
		ram_cs_h_n	: out 	std_logic_vector(15 downto 1) := (others => '1');
		mem_cs_16_n : out 	std_logic;
		-- zero_ws  : out 	std_logic;
		led_ram_cs_n 	: out 	std_logic := '1';
		led_rom_cs_n 	: out 	std_logic := '1'
	);
end;

architecture behavioral of at_memory_card is
	signal 	ram_cs 				: std_logic_vector(15 downto 0); -- Active High, One more CS than output so that full possible RAM is decoded internally
	signal  addr_cs 			: std_logic;  -- This is combinational, early decoding of the address, to assert MEM_CS_16
	signal  card_cs 			: std_logic;  -- This is the commitment to serve the bus on ALE

begin

	chip_select_decoding : process(refresh_n, la, xms_only_n)
	begin

		led_rom_cs_n <= '1';
		ram_cs <= (others => '0');
		addr_cs <= '0';

		-- Select only on memory operations and but not during DRAM refresh cycles
		if refresh_n = '1' then

			case la(23 downto 20) is

				when x"0" => 
					-- Lower 1MB RAM space
					case la(19 downto 17) is
						-- Select the card to fill missing 128KB in Conventional RAM (0x08000-0x09FFF) on a 5170 if not XMS only
						when "100" =>
							if(xms_only_n = '1') then 
								ram_cs <= (0 => '1', others => '0');
								addr_cs <= '1';
							end if;

						-- Need to think about UMB - I'm not sure if I can decode in 16 bit, might need to use an 8 bit transfer
						-- but not quite sure how at present. Just ignoring for now.
						--when x"D" =>
						--	if(umbd_n = '0') then 
						--		ram_cs <= (0 => '1', others => '0');
						--		card_cs <= '1';
						--	end if;

						--when x"E" =>
						--	if(umbe_n = '0') then 
						--		ram_cs <= (0 => '1', others => '0');
						--		card_cs <= '1';
						--	end if;

						when "111" =>
							if sa16 = '1' then
								-- Light the ROM LED when in system ROM space
								led_rom_cs_n <= '0';
							end if;

						when others =>
							ram_cs <= (others => '0');
							addr_cs <= '0';

					end case;

				--when x"1" => 
				--	ram_cs <= (1 => '1', others => '0');
				--	addr_cs <= '1';

				--when x"2" =>
				--	ram_cs <= (2 => '1', others => '0');
				--	addr_cs <= '1';

				--when x"3" =>
				--	ram_cs <= (3 => '1', others => '0');
				--	addr_cs <= '1';

				--when x"4" =>
				--	ram_cs <= (4 => '1', others => '0');
				--	addr_cs <= '1';

				--when x"5" =>
				--	ram_cs <= (5 => '1', others => '0');
				--	addr_cs <= '1';

				--when x"6" =>
				--	ram_cs <= (6 => '1', others => '0');
				--	addr_cs <= '1';

				--when x"7" =>
				--	ram_cs <= (7 => '1', others => '0');
				--	addr_cs <= '1';

				--when x"8" =>
				--	ram_cs <= (8 => '1', others => '0');
				--	addr_cs <= '1';

				--when x"9" =>
				--	ram_cs <= (9 => '1', others => '0');
				--	addr_cs <= '1';

				--when x"A" =>
				--	ram_cs <= (10 => '1', others => '0');
				--	addr_cs <= '1';

				--when x"B" =>
				--	ram_cs <= (11 => '1', others => '0');
				--	addr_cs <= '1';

				--when x"C" =>
				--	ram_cs <= (12 => '1', others => '0');
				--	addr_cs <= '1';

				--when x"D" =>
				--	ram_cs <= (13 => '1', others => '0');
				--	addr_cs <= '1';

				--when x"E" =>
				--	ram_cs <= (14 => '1', others => '0');
				--	addr_cs <= '1';

				--when x"F" =>
				--	if(unsigned(a(19 downto 16)) >= x"0" and unsigned(a(19 downto 16)) < x"E") then
				--		if(xms_only_n = '0') then 
				--			ram_cs <= (15 => '1', others => '0');
				--			card_cs <= '1';
				--		end if;
				--	else
				--		-- Light the ROM LED when in system ROM space (0xFE and 0xFF is repeat of 0x0E and 0x0F)
				--		led_rom_cs_n <= '0';
				--	end if;

				when others =>
					ram_cs <= (others => '0');
					addr_cs <= '0';

			end case;

		end if;

	end process chip_select_decoding;

	-- Activate the 16-bit transfer signal (1-wait state) if card selected
	-- If you don't assert this quickly, then the AT will switch to doing a
	-- slow 2x 8-bit transfer.
    mem_cs_16_n <= 	'0' when addr_cs = '1' else
    				'Z';

    -- Latch the RAM chip selection lines for the whole cycle
    -- These are shifted to allow for (almost) the full 15MB possible
    -- on the card depending on the selection of the XMS_ONLY_N switch
    -- Ie, RAM chip 1 will do upper 128K conventional + UMBs if XMS_ONLY_N is OFF
    -- Or RAM chip 1 will do the first 1MB of XMS and conventional space ignored
    -- if XMS_ONLY_N is ON.
    p_latch_selection : process(ale)
    begin
    	if rising_edge(ale) then

    		card_cs <= addr_cs;
    		ram_cs_l_n <= (others => '1');
    		ram_cs_h_n <= (others => '1');

    		if xms_only_n = '0' then 	-- XMS ONLY ON, > 1MB

    			if sa0 = '0' then
    				ram_cs_l_n <= not ram_cs(15 downto 1);
    			end if;
    			if sbhe_n = '0' then
    				ram_cs_h_n <= not ram_cs(15 downto 1);
    			end if;

    		else 						-- XMS ONLY OFF

    		  	if sa0 = '0' then
    				ram_cs_l_n <= not ram_cs(14 downto 0);
    			end if;
    			if sbhe_n = '0' then
    				ram_cs_h_n <= not ram_cs(14 downto 0);
    			end if;

    		end if;
    	end if;
    end process p_latch_selection;

    -- TODO: Leaving this here for now, as liked how this showed the shifting even if it didn't latch properly
    ---- Shift the Chip selection if only XMS is selected to use all the available RAM
	---- And split the Chip Selection between Hight and Low bytes
	--ram_cs_l_n 	<= 	not ram_cs(15 downto 1) when sa0 = '0' and xms_only_n = '0' else
	--				not ram_cs(14 downto 0) when sa0 = '0' and xms_only_n = '1' else
	--			 	(others => '1');

	--ram_cs_h_n 	<= 	not ram_cs(15 downto 1) when sbhe_n = '0' and xms_only_n = '0' else
	--				not ram_cs(14 downto 0) when sbhe_n = '0' and xms_only_n = '1' else
	--				(others => '1');

    -- TODO: Look at enabling 0WS also if testing well, oooh the power
    --zero_ws_n 	<=	'0' when card_cs = '1' else
    --				'Z';

    -- Memory chip Data transciever direction
    -- same as MEMR_N unless it's not selected then it's set to INPUT (ie write) as I can't tristate it
   	-- TODO: If this doesn't work might need to mod the hardware to add the ENABLE signal so can tristate
    md_dir <= 	'0' when memr_n = '0' and card_cs = '1' else
    			'1' when memw_n = '0' and card_cs = '1' else
    			'1';

    -- Light the RAM LED when the card is being accessed
    led_ram_cs_n <= '0' when card_cs = '1' and (memr_n = '0' or memw_n = '0') else
    				'1';

	--p_ram_cs_lh : process(ale)
	--begin
	--	--ram_cs_l_n 	<= (others => '1');
	--	--ram_cs_h_n 	<= (others => '1');
	--	--md_dir <= '1';
	--	--led_ram_cs_n <= '1';

	--	if rising_edge(ale) then
	--		if card_cs = '1' then
	--			-- Shift the Chip selection if only XMS is selected to use all the available RAM
	--			-- And split the Chip Selection between Hight and Low bytes
	--			if sa0 = '0' and xms_only_n = '0' then
	--				ram_cs_l_n 	<= 	not ram_cs(15 downto 1);
	--			elsif sa0 = '0' and xms_only_n = '1' then
	--				ram_cs_l_n 	<= not ram_cs(14 downto 0);
	--			else
	--				ram_cs_l_n 	<= (others => '1');
	--			end if;

	--			if 	sbhe_n = '0' and xms_only_n = '0' then
	--				ram_cs_h_n 	<= 	not ram_cs(15 downto 1);
	--			elsif sbhe_n = '0' and xms_only_n = '1' then
	--				ram_cs_h_n 	<= not ram_cs(14 downto 0);
	--			else 
	--				ram_cs_h_n 	<= (others => '1');
	--			end if;		

	--			-- md_dir = 1, as input on the ISA bus. md_dir = 0, an output to the ISA bus
	--			if memr_n = '0' then
	--				md_dir <= '0';
	--			else 
	--				md_dir <= '1';
	--			end if;

	--			led_ram_cs_n <= '0';
	--		else
	--			ram_cs_l_n 	<= (others => '1');
	--			ram_cs_h_n 	<= (others => '1');
	--			md_dir <= '1';
	--			led_ram_cs_n <= '1';
	--		end if;
	--	end if;
	--end process p_ram_cs_lh;

    -- TODO: Look at enabling 0WS also if testing well, oooh the power
    --zero_ws_n 	<=	'0' when card_cs = '1' else
    --				'Z';




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
