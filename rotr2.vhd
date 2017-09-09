----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:15:48 11/20/2016 
-- Design Name: 
-- Module Name:    rotr2 - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rotr8 is

PORT  (
myval : in std_logic_vector (31 downto 0);
b : in std_logic_vector ( 4 downto 0);
dout : out std_logic_vector( 7 downto 0)
);
end rotr8;


architecture Behavioral of rotr8 is
--signals
signal ab_rot : STD_LOGIC_VECTOR(31 DOWNTO 0);

begin

--rotate 5bit input by 3bit b
process(myval, b, ab_rot)
begin

case b(4 DOWNTO 0) is
	WHEN "11111" => ab_rot <= myval(30 DOWNTO 0) & myval(31);
	WHEN "11110" => ab_rot <= myval(29 DOWNTO 0) & myval(31 DOWNTO 30); 
	WHEN "11101" => ab_rot <= myval(28 DOWNTO 0) & myval(31 DOWNTO 29);
	WHEN "11100" => ab_rot <= myval(27 DOWNTO 0) & myval(31 DOWNTO 28);
	WHEN "11011" => ab_rot <= myval(26 DOWNTO 0) & myval(31 DOWNTO 27);
	WHEN "11010" => ab_rot <= myval(25 DOWNTO 0) & myval(31 DOWNTO 26);
	WHEN "11001" => ab_rot <= myval(24 DOWNTO 0) & myval(31 DOWNTO 25);
	WHEN "11000" => ab_rot <= myval(23 DOWNTO 0) & myval(31 DOWNTO 24);
	WHEN "10111" => ab_rot <= myval(22 DOWNTO 0) & myval(31 DOWNTO 23);
	WHEN "10110" => ab_rot <= myval(21 DOWNTO 0) & myval(31 DOWNTO 22);
	WHEN "10101" => ab_rot <= myval(20 DOWNTO 0) & myval(31 DOWNTO 21);
	WHEN "10100" => ab_rot <= myval(19 DOWNTO 0) & myval(31 DOWNTO 20);
	WHEN "10011" => ab_rot <= myval(18 DOWNTO 0) & myval(31 DOWNTO 19);
	WHEN "10010" => ab_rot <= myval(17 DOWNTO 0) & myval(31 DOWNTO 18);
	WHEN "10001" => ab_rot <= myval(16 DOWNTO 0) & myval(31 DOWNTO 17);
	WHEN "10000" => ab_rot <= myval(15 DOWNTO 0) & myval(31 DOWNTO 16);
	WHEN "01111" => ab_rot <= myval(14 DOWNTO 0) & myval(31 DOWNTO 15);
	WHEN "01110" => ab_rot <= myval(13 DOWNTO 0) & myval(31 DOWNTO 14);
	WHEN "01101" => ab_rot <= myval(12 DOWNTO 0) & myval(31 DOWNTO 13);
	WHEN "01100" => ab_rot <= myval(11 DOWNTO 0) & myval(31 DOWNTO 12);
	WHEN "01011" => ab_rot <= myval(10 DOWNTO 0) & myval(31 DOWNTO 11);
	WHEN "01010" => ab_rot <= myval(9 DOWNTO 0) & myval(31 DOWNTO 10);
	WHEN "01001" => ab_rot <= myval(8 DOWNTO 0) & myval(31 DOWNTO 9);
	WHEN "01000" => ab_rot <= myval(7 DOWNTO 0) & myval(31 DOWNTO 8);
	WHEN "00111" => ab_rot <= myval(6 DOWNTO 0) & myval(31 DOWNTO 7);
	WHEN "00110" => ab_rot <= myval(5 DOWNTO 0) & myval(31 DOWNTO 6);
	WHEN "00101" => ab_rot <= myval(4 DOWNTO 0) & myval(31 DOWNTO 5);
	WHEN "00100" => ab_rot <= myval(3 DOWNTO 0) & myval(31 DOWNTO 4);
	WHEN "00011" => ab_rot <= myval(2 DOWNTO 0) & myval(31 DOWNTO 3);
	WHEN "00010" => ab_rot <= myval(1 DOWNTO 0) & myval(31 DOWNTO 2);
	WHEN "00001" => ab_rot <= myval(0) & myval(31 DOWNTO 1);
	WHEN OTHERS => ab_rot <= myval;
END CASE;
--capture input
dout <= ab_rot(7 downto 0);
end process;

end Behavioral;

