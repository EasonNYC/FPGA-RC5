library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity RC5 is
PORT  (
  rc5_clr_in: IN STD_LOGIC := '0';  
  rc5_clk_in: IN STD_LOGIC;
  rc5_enc: IN STD_LOGIC;  --  1 = encrypt
   
  --input data
  rc5_din64 : in std_logic_vector(63 downto 0);
  rc5_input_vld: in STD_LOGIC := '0';
  
  --output data
  rc5_dout64 : out std_logic_vector(63 downto 0);
  rc5_dout_vld: OUT STD_LOGIC := '0'
  );
end RC5;


architecture Behavioral of RC5 is 

COMPONENT decryption
PORT  (
  dec_clr: IN STD_LOGIC := '0';  
  dec_clk: IN STD_LOGIC; 
  dec_din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit i/p
  dec_di_vld: IN STD_LOGIC;  -- input is valid
  dec_dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit o/p
  dec_do_rdy: OUT STD_LOGIC --answer is ready when '1'
  );
END COMPONENT;

COMPONENT encryption
PORT  (
  enc_clr: IN STD_LOGIC := '0';  
  enc_clk: IN STD_LOGIC; 
  enc_din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  enc_di_vld: IN STD_LOGIC; 
  enc_dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
  enc_do_rdy: OUT STD_LOGIC 
  );
END COMPONENT;

COMPONENT register64 
PORT(
    d   : IN STD_LOGIC_VECTOR(63 DOWNTO 0); -- data
    ld  : IN STD_LOGIC; -- load/enable.
    clr : IN STD_LOGIC; -- async. clear.
    clk : IN STD_LOGIC; -- clock.
    q   : OUT STD_LOGIC_VECTOR(63 DOWNTO 0) -- output
);
END COMPONENT;


--SIGNALS 

--temporary output related
SIGNAL dout_enc: STD_LOGIC_VECTOR(63 DOWNTO 0); 
SIGNAL do_rdy_enc: STD_LOGIC := '0';
SIGNAL dout_dec: STD_LOGIC_VECTOR(63 DOWNTO 0);
SIGNAL do_rdy_dec: STD_LOGIC := '0';
--to hold answer
SIGNAL dout: STD_LOGIC_VECTOR(63 DOWNTO 0); 
SIGNAL dout_rdy: STD_LOGIC := '0'; 
SIGNAL sol_reg: STD_LOGIC_VECTOR(63 DOWNTO 0); 
SIGNAL din_reg: STD_LOGIC_VECTOR(63 DOWNTO 0); 

--Secret Key to pass to encyption and decryption components
TYPE rom IS ARRAY (0 TO 25) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
CONSTANT skey : rom := rom'(x"9bbbd8c8", x"1a37f7fb", x"46F8E8C5", x"460C6085",
								  x"70F83B8A", x"284B8303", x"513E1454", x"F621ED22",
								  x"3125065D", x"11A83A5D", x"D427686B", x"713AD82D",
								  x"4B792F99", x"2799A4DD", x"A7901C49", x"DEDE871A",
								  x"36C03196", x"A7EFC249", x"61A78BB8", x"3B0A1D2B",
								  x"4DBFCA76", x"AE162167", x"30D76B0A", x"43192304",
								  x"F6CC1431", x"65046380");
  
begin

-- encryption 
myencr : encryption PORT MAP (enc_clk => rc5_clk_in, enc_clr => rc5_clr_in, enc_din => din_reg, enc_di_vld => rc5_input_vld, enc_dout => dout_enc, enc_do_rdy => do_rdy_enc); 

-- decryption 
mydecr : decryption PORT MAP (dec_clk => rc5_clk_in, dec_clr => rc5_clr_in, dec_din => din_reg, dec_di_vld => rc5_input_vld, dec_dout => dout_dec, dec_do_rdy => do_rdy_dec); 

myreg64 : register64 PORT MAP (clr=>rc5_clr_in, clk => rc5_clk_in, ld => rc5_input_vld, d => rc5_din64, q => din_reg);


-- solution_reg. 
--if clr = 0, store a from din. else store new a for next time.
PROCESS(rc5_clr_in, rc5_clk_in)  
BEGIN
  IF(rc5_clr_in='0') THEN sol_reg <=(OTHERS=>'0');
  ELSIF(rc5_clk_in'EVENT AND rc5_clk_in='1') THEN --on rising edge
	  IF(dout_rdy='1') THEN 
			sol_reg<=dout;
	  ELSE
			sol_reg<=sol_reg; 
	  END IF;
  END IF;
END PROCESS;


rc5_dout64 <= sol_reg;
rc5_dout_vld <= dout_rdy;

--choose encryption or decryption answer (both calculated simultaneusly)
process(rc5_enc, dout_enc, do_rdy_enc, dout_dec, do_rdy_dec)
begin
	if (rc5_enc = '1') then
			--output encryption answer
			dout <= dout_enc;
			dout_rdy <= do_rdy_enc;
	else
			--else output decryption answer
			dout <= dout_dec;
			dout_rdy <= do_rdy_dec;
	end if;
end process;

end Behavioral;


