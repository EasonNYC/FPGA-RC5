----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:33:01 12/10/2016 
-- Design Name: 
-- Module Name:    key_exp - Behavioral 
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
LIBRARY	IEEE;
USE	IEEE.STD_LOGIC_1164.ALL;
PACKAGE rc5_pkg IS
 TYPE S_ARRAY IS ARRAY (0 TO 25) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
 TYPE L_ARRAY IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
END rc5_pkg;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE	WORK.rc5_pkg.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY key_exp IS
    PORT
    (
        clr : IN STD_LOGIC := '0';
		  clk	: IN STD_LOGIC;
        key_in	: IN STD_LOGIC;
        ukey	: IN STD_LOGIC_VECTOR(127 DOWNTO 0);--16 byte user passphrase
        skey	: INOUT S_ARRAY; --26 entry ram
        key_rdy	: OUT STD_LOGIC := '0'
    );
END key_exp;


architecture Behavioral of key_exp is

--state machine states
TYPE  StateType IS (ST_IDLE, ST_KEY_IN, ST_KEY_EXP, ST_READY);
SIGNAL state : StateType;

--Larray
signal L_ARRAY : L_ARRAY;

--counters
signal i_cnt : std_logic_vector(4 downto 0); --5 bits max 31
signal j_cnt : std_logic_vector(1 downto 0); --2 bits max 3
signal k_cnt : std_logic_vector(6 downto 0); --7 bits max 127

--registers
SIGNAL a_reg: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b_reg: STD_LOGIC_VECTOR(31 DOWNTO 0);

--temp A and B signals
SIGNAL a_tmp1: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL a_tmp2: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b_tmp1: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b_tmp2: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ab_tmp: STD_LOGIC_VECTOR(31 DOWNTO 0);

begin

--A = S[i] = (S[i] + A + B) <<< 3
a_tmp1<=skey(CONV_INTEGER(i_cnt))+a_reg+b_reg;
-- <<<rotate by 3
a_tmp2<=a_tmp1(28 DOWNTO 0) & a_tmp1(31 DOWNTO 29);

--B = L[j] = (L[j] + A + B) <<< (A + B)
ab_tmp<=a_tmp2+b_reg;
b_tmp1<=L_ARRAY(CONV_INTEGER(j_cnt))+ab_tmp;
WITH ab_tmp(4 DOWNTO 0) SELECT
  b_tmp2<= b_tmp1(30 DOWNTO 0) & b_tmp1(31)  			WHEN "00001",
				b_tmp1(29 DOWNTO 0) & b_tmp1(31 DOWNTO 30) WHEN "00010",
				b_tmp1(28 DOWNTO 0) & b_tmp1(31 DOWNTO 29) WHEN "00011",
				b_tmp1(27 DOWNTO 0) & b_tmp1(31 DOWNTO 28) WHEN "00100",
				b_tmp1(26 DOWNTO 0) & b_tmp1(31 DOWNTO 27) WHEN "00101",
				b_tmp1(25 DOWNTO 0) & b_tmp1(31 DOWNTO 26) WHEN "00110",
				b_tmp1(24 DOWNTO 0) & b_tmp1(31 DOWNTO 25) WHEN "00111",
				b_tmp1(23 DOWNTO 0) & b_tmp1(31 DOWNTO 24) WHEN "01000",
				b_tmp1(22 DOWNTO 0) & b_tmp1(31 DOWNTO 23) WHEN "01001",
				b_tmp1(21 DOWNTO 0) & b_tmp1(31 DOWNTO 22) WHEN "01010",
				b_tmp1(20 DOWNTO 0) & b_tmp1(31 DOWNTO 21) WHEN "01011",
				b_tmp1(19 DOWNTO 0) & b_tmp1(31 DOWNTO 20) WHEN "01100",
				b_tmp1(18 DOWNTO 0) & b_tmp1(31 DOWNTO 19) WHEN "01101",
				b_tmp1(17 DOWNTO 0) & b_tmp1(31 DOWNTO 18) WHEN "01110",
				b_tmp1(16 DOWNTO 0) & b_tmp1(31 DOWNTO 17) WHEN "01111",
				b_tmp1(15 DOWNTO 0) & b_tmp1(31 DOWNTO 16) WHEN "10000",
				b_tmp1(14 DOWNTO 0) & b_tmp1(31 DOWNTO 15) WHEN "10001",
				b_tmp1(13 DOWNTO 0) & b_tmp1(31 DOWNTO 14) WHEN "10010",
				b_tmp1(12 DOWNTO 0) & b_tmp1(31 DOWNTO 13) WHEN "10011",
				b_tmp1(11 DOWNTO 0) & b_tmp1(31 DOWNTO 12) WHEN "10100",
				b_tmp1(10 DOWNTO 0) & b_tmp1(31 DOWNTO 11) WHEN "10101",
				b_tmp1(9 DOWNTO 0) & b_tmp1(31 DOWNTO 10) WHEN "10110",
				b_tmp1(8 DOWNTO 0) & b_tmp1(31 DOWNTO 9) WHEN "10111",
				b_tmp1(7 DOWNTO 0) & b_tmp1(31 DOWNTO 8) WHEN "11000",
				b_tmp1(6 DOWNTO 0) & b_tmp1(31 DOWNTO 7) WHEN "11001",
				b_tmp1(5 DOWNTO 0) & b_tmp1(31 DOWNTO 6) WHEN "11010",
				b_tmp1(4 DOWNTO 0) & b_tmp1(31 DOWNTO 5) WHEN "11011",
				b_tmp1(3 DOWNTO 0) & b_tmp1(31 DOWNTO 4) WHEN "11100",
				b_tmp1(2 DOWNTO 0) & b_tmp1(31 DOWNTO 3) WHEN "11101",
				b_tmp1(1 DOWNTO 0) & b_tmp1(31 DOWNTO 2) WHEN "11110",
				b_tmp1(0) & b_tmp1(31 DOWNTO 1) 		     WHEN "11111",
				b_tmp1  				 						     WHEN OTHERS;


--done
WITH state SELECT
key_rdy<= '1' WHEN ST_READY,
			 '0' WHEN OTHERS;


-- A register
PROCESS(clr, clk)  BEGIN
      IF(clr='0') THEN
           a_reg<=(OTHERS=>'0');
      ELSIF(clk'EVENT AND clk='1') THEN
           IF(state=ST_KEY_EXP) THEN   a_reg<=a_tmp2;
			  END IF;
      END IF;
END PROCESS;

-- B register
PROCESS(clr, clk)  BEGIN
      IF(clr='0') THEN
           b_reg<=(OTHERS=>'0');
      ELSIF(clk'EVENT AND clk='1') THEN
           IF(state=ST_KEY_EXP) THEN   b_reg<=b_tmp2;
           END IF;
     END IF;
END PROCESS;   


-- i = (i + 1) mod (26) round counter
PROCESS(clr, clk)
 BEGIN
    IF(clr='0') THEN  i_cnt<=(OTHERS=>'0');
    ELSIF(clk'EVENT AND clk='1') THEN
       IF(state=ST_KEY_EXP) THEN
         IF(i_cnt="11001") THEN   i_cnt<=(OTHERS=>'0');
         ELSE   i_cnt<=i_cnt+1;
         END IF;
       END IF;
    END IF;
 END PROCESS;

--j = (j + 1) mod (4); round counter   ???
PROCESS(clr, clk)
 BEGIN
    IF(clr='0') THEN  j_cnt<=(OTHERS=>'0');
    ELSIF(clk'EVENT AND clk='1') THEN
       IF(state=ST_KEY_EXP) THEN
         IF(j_cnt="11") THEN   j_cnt<=(OTHERS=>'0'); --if 3
         ELSE  j_cnt<=j_cnt+1;
         END IF;
       END IF;
    END IF;
 END PROCESS;
 
 --k = (k + 1) mod (78); round counter 
PROCESS(clr, clk)
 BEGIN
    IF(clr='0') THEN  k_cnt<=(OTHERS=>'0');
    ELSIF(clk'EVENT AND clk='1') THEN
       IF(state=ST_KEY_EXP) THEN --incriment during key_exp
         IF(k_cnt="1001101") THEN   k_cnt<=(OTHERS=>'0'); --if 77
         ELSE  k_cnt<=k_cnt+1;
         END IF;
       END IF;
    END IF;
 END PROCESS;
 
  
 --init skey and change skey on clk during key exp
PROCESS(clr, clk)

TYPE rom IS ARRAY (0 TO 25) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
CONSTANT s_arr_tmp : S_ARRAY:=S_ARRAY'(x"b7e15163", x"5618cb1c", x"f45044d5", x"9287be8e", x"30bf3847", x"cef6b200", x"6d2e2bb9", x"0b65a572", x"a99d1f2b", x"47d498e4",
x"e60c129d", x"84438c56", x"227b060f", x"c0b27fc8", x"5ee9f981", x"fd21733a", x"9b58ecf3", x"399066ac", x"d7c7e065",
x"75ff5a1e", x"1436d3d7", x"b26e4d90", x"50a5c749", x"eedd4102", x"8d14babb", x"2b4c3474");

BEGIN
IF(clr='0') THEN	 -- After system reset, S array is initialized with P and Q
	skey<=s_arr_tmp; -- clear 
ELSIF(clk'EVENT AND clk='1') THEN
   IF(state=ST_KEY_EXP) THEN 
		skey(CONV_INTEGER(i_cnt))<=a_tmp2;
   END IF;
END IF;
END PROCESS;


--init L_array and change Larray on clk during key_exp
PROCESS(clr, clk)
   BEGIN
     IF(clr='0') THEN --if clear L array, cycle thru
        FOR i IN 0 TO 3 LOOP
           L_ARRAY(i)<=(OTHERS=>'0');
        END LOOP;
     ELSIF(clk'EVENT AND clk='1') THEN
        IF(state=ST_KEY_IN) THEN --capture L_array
          L_ARRAY(0)<=ukey(31 DOWNTO 0);
          L_ARRAY(1)<=ukey(63 DOWNTO 32);
          L_ARRAY(2)<=ukey(95 DOWNTO 64);
          L_ARRAY(3)<=ukey(127 DOWNTO 96);
        ELSIF(state=ST_KEY_EXP) THEN
          L_ARRAY(CONV_INTEGER(j_cnt))<=b_tmp2;
        END IF;
     END IF;
END PROCESS;

--state machine 
PROCESS(clr, clk)	
     BEGIN
       IF(clr='0') THEN
           state<=ST_IDLE;
       ELSIF(clk'EVENT AND clk='1') THEN
           CASE state IS
              WHEN ST_IDLE | ST_READY=>
                  	IF(key_in='1') THEN  state<=ST_KEY_IN;   END IF;
              WHEN ST_KEY_IN=> state<=ST_KEY_EXP;  
              WHEN ST_KEY_EXP=> IF(k_cnt="1001101") THEN   state<=ST_READY;  END IF;--if its been 78 rounds
            END CASE;
       END IF;
END PROCESS;

end Behavioral;

