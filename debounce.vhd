----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:35:47 11/19/2016 
-- Design Name: 
-- Module Name:    debounce - Behavioral 
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; --use CONV_INTEGER

entity button is
PORT  (
  clk_in: IN STD_LOGIC;  -- Clock signal
  btn_out: OUT STD_LOGIC := '0'; --answer is ready when '1'
  Led_in : out std_logic_vector(7 downto 0); --display button state for input feedback
  btn_in : in STD_LOGIC_VECTOR(4 DOWNTO 0)
  );
end button;


architecture Behavioral of button is
signal oldbstate : std_logic := '0'; --used in debounce
begin

-- debounce push button process
debouncer : PROCESS(clk_in)
variable dbcounter : std_logic_vector(19 DOWNTO 0); --decrimenting counter
begin
    if (clk_in'event and clk_in = '1') then --on clk
      if(btn_in(0) xor oldbstate) = '1' then --if change in button state
        dbcounter := (others => '0'); --reset cntr
        oldbstate <= btn_in(0); --save new value
      else
		  dbcounter := dbcounter + '1'; --incr cntr
		  if((dbcounter = x"F423F") and ((oldbstate xor btn_in(0)) = '0')) then 
				btn_out <= oldbstate; --output new state
		  END IF;
		End if;
	 end if;
end process debouncer;
end Behavioral;


