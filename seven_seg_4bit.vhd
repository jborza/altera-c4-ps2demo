----------------------------------------------------------------------------------
--Displays a 4-bit number on the seven-segment display
-- 7 segment configuration
--        1    
--      ____
--   6 |    | 2
--     |_7__| 
--   5 |    | 3
--     |____| .0
--       4
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_4bit is
    Port ( Number : in  STD_LOGIC_VECTOR (3 downto 0);
           SevenSegment : out  STD_LOGIC_VECTOR (7 downto 0));
end seven_seg_4bit;


architecture Behavioral of seven_seg_4bit is

begin
	with Number select
		SevenSegment(7 downto 1) <= -- 1 is off for a segment
			"0000001" when "0000", --0
			"1001111" when "0001", --1
			"0010010" when "0010", --2
			"0000110" when "0011", --3
			"1001100" when "0100", --4
			"0100100" when "0101", --5
			"0100000" when "0110", --6
			"0001111" when "0111", --7
			"0000000" when "1000", --8
			"0000100" when "1001", --9
			"0001000" when "1010", --a
			"1100000" when "1011", --b
			"0110001" when "1100", --c
			"1000010" when "1101", --d
			"0110000" when "1110", --e
			"0111000" when others; --f
		SevenSegment(0) <= '1'; --decimal point

end Behavioral;

