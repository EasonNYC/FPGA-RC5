----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:53:20 12/10/2016 
-- Design Name: 
-- Module Name:    ram - Behavioral 
-- Project Name: 



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; --use CONV_INTEGER
ENTITY ram32_32 IS
PORT  (clk: IN STD_LOGIC;
       wr: in STD_LOGIC; --read =0; write =1
		 addr: IN STD_LOGIC_VECTOR(4 DOWNTO 0);--5-bit address
		 datain: in STD_LOGIC_VECTOR(31 DOWNTO 0) ;--32-bit datain
		 dataout: OUT STD_LOGIC_VECTOR(31 DOWNTO 0) --32 bit data out
		 ); --8-bitdataout);

END ram32_32;

ARCHITECTURE RTL OF ram32_32 IS

TYPE ram IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
signal skey : ram := (others => (others => '0'));

BEGIN 

PROCESS(clk)  
BEGIN
IF(clk'EVENT AND clk='1')  THEN 
    if (wr='1') then 
		skey(CONV_INTEGER(addr)) <= datain;
	 end if;
END IF; 
END PROCESS;

Dataout<= skey(CONV_INTEGER(addr));

END RTL;
