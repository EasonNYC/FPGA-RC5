----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:23:24 09/23/2016 
-- Design Name: 
-- Module Name:    lab1 - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY decryption IS
 PORT  (
  dec_clr: IN STD_LOGIC := '0';  -- asynchronous reset
  dec_clk: IN STD_LOGIC;  -- Clock signal
  dec_din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit i/p
  dec_di_vld: IN STD_LOGIC;  -- input is valid
  dec_dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit o/p
  dec_do_rdy: OUT STD_LOGIC := '0' --answer is ready when '1'
  );
END decryption;

ARCHITECTURE Behavioral OF decryption IS
  --upcounter
  SIGNAL i_cnt: STD_LOGIC_VECTOR(3 DOWNTO 0);  
      
  --register to store value A
  SIGNAL a_reg: STD_LOGIC_VECTOR(31 DOWNTO 0); 
  
  --register to store value B
  SIGNAL b_reg: STD_LOGIC_VECTOR(31 DOWNTO 0); 
  
  --AB internal signals
  SIGNAL ab_sub: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL ab_rot: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL a_pre: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL ba_sub: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL ba_rot: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL b_pre: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL a: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL b: STD_LOGIC_VECTOR(31 DOWNTO 0);
    
  --state machine (4 states)
  TYPE  StateType IS (ST_IDLE, --
                      ST_ROUND_OP, -- RC5 round op is performed. The system remains in this state for twelve clock cycles.
                      ST_POST_ROUND, -- RC5 pre-round op is performed 
							 ST_READY);
							 
  SIGNAL  state : StateType; --store the state in a variable called 'state'

  TYPE rom IS ARRAY (0 TO 25) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
  CONSTANT skey : rom:=rom'(x"9bbbd8c8", x"1a37f7fb", x"46F8E8C5", x"460C6085",
									  x"70F83B8A", x"284B8303", x"513E1454", x"F621ED22",
									  x"3125065D", x"11A83A5D", x"D427686B", x"713AD82D",
									  x"4B792F99", x"2799A4DD", x"A7901C49", x"DEDE871A",
									  x"36C03196", x"A7EFC249", x"61A78BB8", x"3B0A1D2B",
									  x"4DBFCA76", x"AE162167", x"30D76B0A", x"43192304",
									  x"F6CC1431", x"65046380");								
									
-------------------------	
begin --decryption

--start with B 
partB : process(a_reg, b, ba_sub, ba_rot, i_cnt) 
begin

--pre
ba_sub <= b_reg - skey(CONV_INTEGER(i_cnt & '1'));--S[2×i+1] 25

--rotate >>
case a_reg(4 DOWNTO 0) is
WHEN "11111" => ba_rot <= ba_sub(30 DOWNTO 0) & ba_sub(31);
WHEN "11110" => ba_rot <= ba_sub(29 DOWNTO 0) & ba_sub(31 DOWNTO 30); 
WHEN "11101" => ba_rot <= ba_sub(28 DOWNTO 0) & ba_sub(31 DOWNTO 29);
WHEN "11100" => ba_rot <= ba_sub(27 DOWNTO 0) & ba_sub(31 DOWNTO 28);
WHEN "11011" => ba_rot <= ba_sub(26 DOWNTO 0) & ba_sub(31 DOWNTO 27);
WHEN "11010" => ba_rot <= ba_sub(25 DOWNTO 0) & ba_sub(31 DOWNTO 26);
WHEN "11001" => ba_rot <= ba_sub(24 DOWNTO 0) & ba_sub(31 DOWNTO 25);
WHEN "11000" => ba_rot <= ba_sub(23 DOWNTO 0) & ba_sub(31 DOWNTO 24);
WHEN "10111" => ba_rot <= ba_sub(22 DOWNTO 0) & ba_sub(31 DOWNTO 23);
WHEN "10110" => ba_rot <= ba_sub(21 DOWNTO 0) & ba_sub(31 DOWNTO 22);
WHEN "10101" => ba_rot <= ba_sub(20 DOWNTO 0) & ba_sub(31 DOWNTO 21);
WHEN "10100" => ba_rot <= ba_sub(19 DOWNTO 0) & ba_sub(31 DOWNTO 20);
WHEN "10011" => ba_rot <= ba_sub(18 DOWNTO 0) & ba_sub(31 DOWNTO 19);
WHEN "10010" => ba_rot <= ba_sub(17 DOWNTO 0) & ba_sub(31 DOWNTO 18);
WHEN "10001" => ba_rot <= ba_sub(16 DOWNTO 0) & ba_sub(31 DOWNTO 17);
WHEN "10000" => ba_rot <= ba_sub(15 DOWNTO 0) & ba_sub(31 DOWNTO 16);
WHEN "01111" => ba_rot <= ba_sub(14 DOWNTO 0) & ba_sub(31 DOWNTO 15);
WHEN "01110" => ba_rot <= ba_sub(13 DOWNTO 0) & ba_sub(31 DOWNTO 14);
WHEN "01101" => ba_rot <= ba_sub(12 DOWNTO 0) & ba_sub(31 DOWNTO 13);
WHEN "01100" => ba_rot <= ba_sub(11 DOWNTO 0) & ba_sub(31 DOWNTO 12);
WHEN "01011" => ba_rot <= ba_sub(10 DOWNTO 0) & ba_sub(31 DOWNTO 11);
WHEN "01010" => ba_rot <= ba_sub(9 DOWNTO 0) & ba_sub(31 DOWNTO 10);
WHEN "01001" => ba_rot <= ba_sub(8 DOWNTO 0) & ba_sub(31 DOWNTO 9);
WHEN "01000" => ba_rot <= ba_sub(7 DOWNTO 0) & ba_sub(31 DOWNTO 8);
WHEN "00111" => ba_rot <= ba_sub(6 DOWNTO 0) & ba_sub(31 DOWNTO 7);
WHEN "00110" => ba_rot <= ba_sub(5 DOWNTO 0) & ba_sub(31 DOWNTO 6);
WHEN "00101" => ba_rot <= ba_sub(4 DOWNTO 0) & ba_sub(31 DOWNTO 5);
WHEN "00100" => ba_rot <= ba_sub(3 DOWNTO 0) & ba_sub(31 DOWNTO 4);
WHEN "00011" => ba_rot <= ba_sub(2 DOWNTO 0) & ba_sub(31 DOWNTO 3);
WHEN "00010" => ba_rot <= ba_sub(1 DOWNTO 0) & ba_sub(31 DOWNTO 2);
WHEN "00001" => ba_rot <= ba_sub(0) & ba_sub(31 DOWNTO 1);
WHEN OTHERS => ba_rot <= ba_sub;
END CASE;

--store new b
b<=ba_rot xor a_reg;--S[2×i+1]

--same for b
b_pre <= b_reg - skey(1);  -- B = B + S[1]  b - skey(1) ? b or breg?
END PROCESS;


--PART A
partA : process(ab_sub, a_reg, b, b_reg, ab_rot) 	--A=((A XOR B)<<<B) + S[2×i];
begin

--pre
ab_sub <= a_reg - skey(CONV_INTEGER(i_cnt & '0'));

--rotate
case b(4 DOWNTO 0) is
	WHEN "11111" => ab_rot <= ab_sub(30 DOWNTO 0) & ab_sub(31);
	WHEN "11110" => ab_rot <= ab_sub(29 DOWNTO 0) & ab_sub(31 DOWNTO 30); 
	WHEN "11101" => ab_rot <= ab_sub(28 DOWNTO 0) & ab_sub(31 DOWNTO 29);
	WHEN "11100" => ab_rot <= ab_sub(27 DOWNTO 0) & ab_sub(31 DOWNTO 28);
	WHEN "11011" => ab_rot <= ab_sub(26 DOWNTO 0) & ab_sub(31 DOWNTO 27);
	WHEN "11010" => ab_rot <= ab_sub(25 DOWNTO 0) & ab_sub(31 DOWNTO 26);
	WHEN "11001" => ab_rot <= ab_sub(24 DOWNTO 0) & ab_sub(31 DOWNTO 25);
	WHEN "11000" => ab_rot <= ab_sub(23 DOWNTO 0) & ab_sub(31 DOWNTO 24);
	WHEN "10111" => ab_rot <= ab_sub(22 DOWNTO 0) & ab_sub(31 DOWNTO 23);
	WHEN "10110" => ab_rot <= ab_sub(21 DOWNTO 0) & ab_sub(31 DOWNTO 22);
	WHEN "10101" => ab_rot <= ab_sub(20 DOWNTO 0) & ab_sub(31 DOWNTO 21);
	WHEN "10100" => ab_rot <= ab_sub(19 DOWNTO 0) & ab_sub(31 DOWNTO 20);
	WHEN "10011" => ab_rot <= ab_sub(18 DOWNTO 0) & ab_sub(31 DOWNTO 19);
	WHEN "10010" => ab_rot <= ab_sub(17 DOWNTO 0) & ab_sub(31 DOWNTO 18);
	WHEN "10001" => ab_rot <= ab_sub(16 DOWNTO 0) & ab_sub(31 DOWNTO 17);
	WHEN "10000" => ab_rot <= ab_sub(15 DOWNTO 0) & ab_sub(31 DOWNTO 16);
	WHEN "01111" => ab_rot <= ab_sub(14 DOWNTO 0) & ab_sub(31 DOWNTO 15);
	WHEN "01110" => ab_rot <= ab_sub(13 DOWNTO 0) & ab_sub(31 DOWNTO 14);
	WHEN "01101" => ab_rot <= ab_sub(12 DOWNTO 0) & ab_sub(31 DOWNTO 13);
	WHEN "01100" => ab_rot <= ab_sub(11 DOWNTO 0) & ab_sub(31 DOWNTO 12);
	WHEN "01011" => ab_rot <= ab_sub(10 DOWNTO 0) & ab_sub(31 DOWNTO 11);
	WHEN "01010" => ab_rot <= ab_sub(9 DOWNTO 0) & ab_sub(31 DOWNTO 10);
	WHEN "01001" => ab_rot <= ab_sub(8 DOWNTO 0) & ab_sub(31 DOWNTO 9);
	WHEN "01000" => ab_rot <= ab_sub(7 DOWNTO 0) & ab_sub(31 DOWNTO 8);
	WHEN "00111" => ab_rot <= ab_sub(6 DOWNTO 0) & ab_sub(31 DOWNTO 7);
	WHEN "00110" => ab_rot <= ab_sub(5 DOWNTO 0) & ab_sub(31 DOWNTO 6);
	WHEN "00101" => ab_rot <= ab_sub(4 DOWNTO 0) & ab_sub(31 DOWNTO 5);
	WHEN "00100" => ab_rot <= ab_sub(3 DOWNTO 0) & ab_sub(31 DOWNTO 4);
	WHEN "00011" => ab_rot <= ab_sub(2 DOWNTO 0) & ab_sub(31 DOWNTO 3);
	WHEN "00010" => ab_rot <= ab_sub(1 DOWNTO 0) & ab_sub(31 DOWNTO 2);
	WHEN "00001" => ab_rot <= ab_sub(0) & ab_sub(31 DOWNTO 1);
	WHEN OTHERS => ab_rot <= ab_sub;
END CASE;

--store new a.
a<=ab_rot xor b; --S[2×i]

a_pre <= a_reg - skey(0); --always initialize a_pre with first skey value
end process;


--output
dec_dout<=a_reg & b_reg;


-- a_reg. 
--if clr = 0, store a from din. else store new a for next time.
PROCESS(dec_clr, dec_clk)   
BEGIN
  IF(dec_clr='0') THEN a_reg<=(OTHERS=>'0');
  ELSIF(dec_clk'EVENT AND dec_clk='1') THEN
     IF(state=ST_ROUND_OP) THEN 
			a_reg<=a; 
	  ElSIF(state=ST_POST_ROUND) THEN   
			a_reg<=a_pre;
	  END IF;
  END IF;
END PROCESS;

-- b_reg if clr = 0, store b from din. else store b
PROCESS(dec_clr, dec_clk)
BEGIN
  IF(dec_clr='0') THEN b_reg<=(OTHERS=>'0');
  ELSIF(dec_clk'EVENT AND dec_clk='1') THEN 
	  IF(state=ST_ROUND_OP) THEN  b_reg<=b;
	  ELSIF(state=ST_POST_ROUND) THEN b_reg<=b_pre; 
	  END IF;
  END IF;
END PROCESS; 

--4bit downcounter (starts at 12 and rolls over at 1)
PROCESS(dec_clr, dec_clk)  
BEGIN
  IF(dec_clr='0') THEN --async clr/reset
	i_cnt<="1100";
  ELSIF(dec_clk'EVENT AND dec_clk='1') THEN
     IF(state=ST_ROUND_OP) THEN
       IF(i_cnt="0000") THEN
         i_cnt<="1100";
       ELSE
         i_cnt<=i_cnt-'1';
       END IF;
     END IF;
   END IF;
END PROCESS;

--decryption state machine
PROCESS(dec_clr, dec_clk)
BEGIN
      IF(dec_clr='0') THEN  --best to start idle
         state<=ST_IDLE;
			dec_do_rdy <= '0';
      ELSIF(dec_clk'EVENT AND dec_clk='1') THEN   --on clock high, change the state if nessisary 
         CASE state IS
            WHEN ST_IDLE => IF(dec_di_vld='1') THEN 
										state<=ST_ROUND_OP;  --if data valid change to round
										dec_do_rdy <= '0';
										END IF;
            WHEN ST_ROUND_OP=> IF(i_cnt="0001") THEN 
										 state<=ST_POST_ROUND;  --if done with round, move to postroundady when done
										 dec_do_rdy <= '0';
										 END IF;
			   WHEN ST_POST_ROUND=> state<=ST_READY;  --if postround change to ready
											dec_do_rdy <=	'1';
            WHEN ST_READY=> dec_do_rdy <=	'1'; 
									 
			END CASE;
      END IF;
END PROCESS;

end Behavioral;