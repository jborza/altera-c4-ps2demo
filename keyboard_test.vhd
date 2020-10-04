
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity keyboardVhdl is
	Port (	CLK, RST, KD, KC: in std_logic;
				an: out std_logic_vector (3 downto 0);
				sseg: out std_logic_vector (7 downto 0));


end keyboardVhdl;


architecture Behavioral of keyboardVhdl is

	------------------------------------------------------------------------
	-- Component Declarations
	------------------------------------------------------------------------

	COMPONENT seven_seg_4bit
	PORT
	(
		Number		:	 IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		SevenSegment		:	 OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	END COMPONENT;
	
	------------------------------------------------------------------------
	-- Signal Declarations
	------------------------------------------------------------------------
	signal clkDiv : std_logic_vector (12 downto 0);
	signal sclk, pclk : std_logic;
	signal KDI, KCI : std_logic;
	signal DFF1, DFF2 : std_logic;
	signal shiftRegSig1: std_logic_vector(10 downto 0);
	signal shiftRegSig2: std_logic_vector(10 downto 1);
	signal MUXOUT: std_logic_vector (3 downto 0);
	signal WaitReg: std_logic_vector (7 downto 0);
	
	------------------------------------------------------------------------
	-- Module Implementation
	------------------------------------------------------------------------

	begin
	
	-- seven segment instance
	inst_seven_seg: seven_seg_4bit PORT MAP
	(
		Number => MUXOUT,
		SevenSegment => sseg
	);
	
	--Divide the master clock down to a lower frequency--
	CLKDivider: Process (CLK)
	begin
		if (CLK = '1' and CLK'Event) then 
			clkDiv <= clkDiv +1; 
		end if;	
	end Process;

	sclk <= clkDiv(12);
	pclk <= clkDiv(3);

	--Flip Flops used to condition siglans coming from PS2--
	Process (pclk, RST, KC, KD)
	begin
		if(RST = '0') then
			DFF1 <= '0'; DFF2 <= '0'; KDI <= '0'; KCI <= '0';
		else												
			if (pclk = '1' and pclk'Event) then
				DFF1 <= KD; KDI <= DFF1; DFF2 <= KC; KCI <= DFF2;
			end if;
		end if;
	end process;

	--Shift Registers used to clock in scan codes from PS2--
	Process(KDI, KCI, RST) --DFF2 carries KD and DFF4, and DFF4 carries KC
	begin																					  
		if (RST = '0') then
			ShiftRegSig1 <= "00000000000";
			ShiftRegSig2 <= "0000000000";
		else
			if (KCI = '0' and KCI'Event) then
				ShiftRegSig1(10 downto 0) <= KDI & ShiftRegSig1(10 downto 1);
				ShiftRegSig2(10 downto 1) <= ShiftRegSig1(0) & ShiftRegSig2(10 downto 2);
			end if;
		end if;
	end process;
	
	--Wait Register
	process(ShiftRegSig1, ShiftRegSig2, RST, KCI)
	begin
		if(RST = '0')then
			WaitReg <= "00000000";
		else
			if(KCI'event and KCI = '1' and ShiftRegSig2(8 downto 1) = "11110000")then 
				WaitReg <= ShiftRegSig1(8 downto 1);
			end if;			
		end if;
	end Process;

	--Multiplexer

	MUXOUT <=  WaitReg(7 downto 4) when sclk = '1' else
				  WaitReg(3 downto 0);


	--Anode Driver--
	an(3) <= '1'; an(2) <= '1'; --disable first two seven-segment decoders.
	an(1 downto 0) <= "10" when sclk = '0' else "01";

				
end Behavioral;