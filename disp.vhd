----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:13:58 11/20/2016 
-- Design Name: 
-- Module Name:    disp - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; --use CONV_INTEGER
use IEEE.NUMERIC_STD.ALL;


entity disp is
PORT  (
  clk_in: IN STD_LOGIC;  -- Clock signal
  cath_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
  an_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);--segselect
  display_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0)--holds data to display across 4 7segment displays
);
end disp;


architecture Behavioral of disp is

--SIGNALS

--a single seven seg display hex digit
signal data : STD_LOGIC_VECTOR(3 DOWNTO 0); 

--clk division related signals
CONSTANT digitPeriod : STD_LOGIC_VECTOR(31 DOWNTO 0) := STD_LOGIC_VECTOR(TO_UNSIGNED(100000, 32)); --3000
SIGNAL clkDiv : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
SIGNAL clkCnt : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

--display and input state machine
shared VARIABLE disp_sel : INTEGER := 0; --(0 to 3)

begin
--7seg clk divider & button input detect
updateClock : PROCESS(clk_in)
BEGIN
		IF(clk_in = '1') and (clk_in'EVENT) THEN
		
			--for clock divider for 7seg displays
			IF(clkcnt = digitPeriod) THEN
				clkcnt <= (OTHERS => '0'); --reset
				clkDiv <= clkDiv + '1'; --clkDiv is 1ms, clkDiv(1) is .25*1ms= 250us
			ELSE
				clkcnt <= clkcnt + '1'; --incr
			END IF;
	
	    END IF;
END PROCESS updateClock;

--cycle thru all 7seg displays
cycleDisplays : process(clkDiv(1))
begin
IF(clkDiv(1) = '1') and (clkDiv(1)'EVENT) THEN
	IF(disp_sel = 3) THEN
		disp_sel := 0;
	ELSE
		disp_sel := disp_sel + 1;
	END IF;
END IF;
END PROCESS cycleDisplays;


--select segdisp & data
displaySelect: process(clkDiv, display_in)
begin
IF(clkDiv(1) = '1') and (clkDiv(1)'EVENT) THEN
	case disp_sel is
		when 0 => an_out <= "1110";  --select rightmost display
					 data <= display_in(3 downto 0);
		when 1 => an_out <= "1101"; -- select 2nd display from the right
					 data <= display_in(7 downto 4);
		when 2 => an_out <= "1011"; --select 3rd display from the right
					 data <= display_in(11 downto 8);
		when 3 => an_out <= "0111";  --select leftmost display
					 data <= display_in(15 downto 12);
		when others=> an_out <= "1111"; --(should not happen)						  
	end case;
END IF;
END PROCESS displaySelect;


--display a hex digit
updateDisplay : process(data) 
begin
	case data(3 DOWNTO 0) is
	   WHEN x"0" => cath_out <= "1000000"; --1  g---->a, 0 means on, 1 means off
		WHEN x"1" => cath_out <= "1111001"; --1  g---->a, 0 means on, 1 means off
		WHEN x"2" => cath_out <= "0100100"; --2
		WHEN x"3" => cath_out <= "0110000"; --3
		WHEN x"4" => cath_out <= "0011001"; --4
		WHEN x"5" => cath_out <= "0010010"; --5
		WHEN x"6" => cath_out <= "0000010"; --6
		WHEN x"7" => cath_out <= "1111000"; --7
		WHEN x"8" => cath_out <= "0000000"; --8
		WHEN x"9" => cath_out <= "0011000"; --9
		WHEN x"A" => cath_out <= "0001000"; --A
		WHEN x"B" => cath_out <= "0000011"; --b
		WHEN x"C" => cath_out <= "1000110"; --C
		WHEN x"D" => cath_out <= "0100001"; --d
		WHEN x"E" => cath_out <= "0000110"; --E
		WHEN x"F" => cath_out <= "0001110"; --F
		WHEN OTHERS => cath_out <= "1111111"; --0 change to '--'
	end case;
end process updateDisplay;

end Behavioral;

