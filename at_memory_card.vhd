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
		sbhe_n 		: in 	std_logic;
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
	signal 	ram_cs 				: std_logic_vector(15 downto 0); -- Active High, One more CS than output so that full possible RAM is decoded internally
	signal 	ram_cs_l_int_n		: std_logic_vector(15 downto 1);
	signal 	ram_cs_h_int_n		: std_logic_vector(15 downto 1);
	signal 	ram_cs_l_latch_n	: std_logic_vector(15 downto 1);
	signal 	ram_cs_h_latch_n	: std_logic_vector(15 downto 1);
	signal 	ram_cs_l_out_n		: std_logic_vector(15 downto 1);
	signal 	ram_cs_h_out_n		: std_logic_vector(15 downto 1);
	signal  card_cs 			: std_logic;


begin
	chip_select_decoding : process(ale)
	begin
		if rising_edge(ale) then
			ram_cs <= (others => '0');
			card_cs <= '0';
			
			if refresh_n = '1' then

				case a(23 downto 20) is

					when x"0" => 

						case a(19 downto 16) is

							when x"8" | x"9" =>
								if(xms_only_n = '1') then 
									ram_cs <= (0 => '1', others => '0');
									card_cs <= '1';
								end if;

							when x"D" =>
								if(umbd_n = '0') then 
									ram_cs <= (0 => '1', others => '0');
									card_cs <= '1';
								end if;

							when x"E" =>
								if(umbe_n = '0') then 
									ram_cs <= (0 => '1', others => '0');
									card_cs <= '1';
								end if;

							when others =>
								ram_cs <= (others => '0');
								card_cs <= '0';

						end case;

					when x"1" => 
						ram_cs <= (1 => '1', others => '0');
						card_cs <= '1';

					when x"2" =>
						ram_cs <= (2 => '1', others => '0');
						card_cs <= '1';

					when x"3" =>
						ram_cs <= (3 => '1', others => '0');
						card_cs <= '1';

					when x"4" =>
						ram_cs <= (4 => '1', others => '0');
						card_cs <= '1';

					when x"5" =>
						ram_cs <= (5 => '1', others => '0');
						card_cs <= '1';

					when x"6" =>
						ram_cs <= (6 => '1', others => '0');
						card_cs <= '1';

					when x"7" =>
						ram_cs <= (7 => '1', others => '0');
						card_cs <= '1';

					when x"8" =>
						ram_cs <= (8 => '1', others => '0');
						card_cs <= '1';

					when x"9" =>
						ram_cs <= (9 => '1', others => '0');
						card_cs <= '1';

					when x"A" =>
						ram_cs <= (10 => '1', others => '0');
						card_cs <= '1';

					when x"B" =>
						ram_cs <= (11 => '1', others => '0');
						card_cs <= '1';

					when x"C" =>
						ram_cs <= (12 => '1', others => '0');
						card_cs <= '1';

					when x"D" =>
						ram_cs <= (13 => '1', others => '0');
						card_cs <= '1';

					when x"E" =>
						ram_cs <= (14 => '1', others => '0');
						card_cs <= '1';

					when x"F" =>
						if(unsigned(a(19 downto 16)) >= x"0" and unsigned(a(19 downto 16)) < x"D") then
							if(xms_only_n = '0') then 
								ram_cs <= (15 => '1', others => '0');
								card_cs <= '1';
							end if;
						end if;

					when others =>
						ram_cs <= (others => '0');
						card_cs <= '0';

				end case;

			end if;

		end if;

	end process chip_select_decoding;

	ram_cs_l_n 	<= 	not ram_cs(15 downto 1) when sa0 = '0' else
				 	(others => '1');

	ram_cs_h_n 	<= 	not ram_cs(15 downto 1) when sbhe_n = '0' else
					(others => '1');


	---- Decode initially, assuming that the RAM for the missing bits from 512KB to 1MB is required and will use SRAM1.
	---- If the <1MB decoding is not required, will be offset by 1 when output
	---- If we just want to do XMS, then allocate RAM chip 15 to 0xF00000 to 0xFDFFFF
	--ram_cs 	<= 	"0000000000000001" when a(23 downto 16) = x"08" or a(23 downto 16) = x"09" else -- 0x080000 to 0x09FFFF 128KB
	--			"0000000000000001" when a(23 downto 16) = x"0D" and umbd_n = '0' else 			-- 0x0D0000 to 0xODFFFF 64KB UMB [SW]
	--			"0000000000000001" when a(23 downto 16) = x"0E" and umbe_n = '0' else			-- 0x0E0000 to 0x0EFFFF 64KB UMB [SW]
	--			"0000000000000010" when a(23 downto 20) = x"1" else 							-- 0x100000 to 0x1FFFFF 1MB
	--			"0000000000000100" when a(23 downto 20) = x"2" else
	--			"0000000000001000" when a(23 downto 20) = x"3" else
	--			"0000000000010000" when a(23 downto 20) = x"4" else
	--			"0000000000100000" when a(23 downto 20) = x"5" else
	--			"0000000001000000" when a(23 downto 20) = x"6" else
	--			"0000000010000000" when a(23 downto 20) = x"7" else
	--			"0000000100000000" when a(23 downto 20) = x"8" else
	--			"0000001000000000" when a(23 downto 20) = x"9" else
	--			"0000010000000000" when a(23 downto 20) = x"A" else
	--			"0000100000000000" when a(23 downto 20) = x"B" else
	--			"0001000000000000" when a(23 downto 20) = x"C" else
	--			"0010000000000000" when a(23 downto 20) = x"D" else
	--			"0100000000000000" when a(23 downto 20) = x"E" else
	--			"1000000000000000" when unsigned(a(23 downto 16)) >= x"F0" and unsigned(a(23 downto 16)) < x"FD" else 	-- 0xF00000 to 0xFDFFFF	
	--			"0000000000000000";

	---- Invert, transpose if needed and add more conditions to when it applies
	--ram_cs_l_int_n 	<= 	not ram_cs(15 downto 1) when sa0 = '0' and xms_only_n = '0' and refresh_n = '1' else
	--					not ram_cs(14 downto 0) when sa0 = '0' and xms_only_n = '1' and refresh_n = '1' else
	--					(others => '1');

	--ram_cs_h_int_n 	<= 	not ram_cs(15 downto 1) when sbhe_n = '0' and xms_only_n = '0' and refresh_n = '1' else
	--					not ram_cs(14 downto 0) when sbhe_n = '0' and xms_only_n = '1' and refresh_n = '1' else
	--					(others => '1');

	----Convaluted way to implement a transparent latch, GHDL doesn't like transparent latches
	--ram_cs_latch : process(ale)
    --begin
    --	if falling_edge(ale) then
    --		ram_cs_l_latch_n <= ram_cs_l_int_n;
    --		ram_cs_h_latch_n <= ram_cs_h_int_n;
    --	end if;
    --end process ram_cs_latch;

   	--ram_cs_l_out_n <= 	ram_cs_l_int_n when ale = '1' else 
    --				ram_cs_l_latch_n;

    --ram_cs_h_out_n <= 	ram_cs_h_int_n when ale = '1' else 
    --				ram_cs_h_latch_n;

    --ram_cs_l_n <= ram_cs_l_out_n;
    --ram_cs_h_n <= ram_cs_h_out_n;

    -- card_cs <= 	'1' when ram_cs_l_out_n = "111111111111111" and ram_cs_h_out_n = "111111111111111" else
    --			'0';

    mem_cs_16_n <= not	card_cs;

    -- this follows MEMR when Selected
    md_dir <= 	memr_n when card_cs = '1' else
    			'1';



    -- Neater transparent latch solution, but don't think it's synthasisable as Flip-Flops = 0 on Fitter report
    --ram_cs_latch : block(ale = '1')
    --begin
    --	ram_cs_l_n <= guarded ram_cs_l_int_n;
    --	ram_cs_h_n <= guarded ram_cs_h_int_n;
    --end block ram_cs_latch;

	-- If you don't specify outputs then the fitter will crash		
	-- TODO: This is the only way to stop the disconnect the card form the bus on a READ when not selected
	-- Must be '1' when NOT selected (ie, INPUT on bus)	
	 --md_dir 	<= 	'1';
	--ram_cs_l_n <= (others => '0');
	--ram_cs_h_n <= (others => '0');
	 --mem_cs_16_n <= '1';

end behavioral;
