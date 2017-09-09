----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:37:24 11/04/2016 
-- Design Name: 
-- Module Name:    rotr - Behavioral 
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
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL; --use CONV_INTEGER
--use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-----------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; --use CONV_INTEGER
use IEEE.NUMERIC_STD.ALL;

USE	WORK.rc5_pkg.ALL;
entity logic is
PORT  (
  clk: IN STD_LOGIC;   
  d_rdy: OUT STD_LOGIC := '0'; --rc5 result ready when '1'

  cath : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
  an : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --segselect
  Led : out std_logic_vector(7 downto 0);
  sw : in STD_LOGIC_VECTOR(7 DOWNTO 0); --user input switch 
  btn : in STD_LOGIC_VECTOR(4 DOWNTO 0) --user input button
  );
end logic;


architecture Behavioral of logic is

--components
COMPONENT button
PORT  (
  clk_in: IN STD_LOGIC;  -- Clock signal
  btn_out: OUT STD_LOGIC := '0'; --answer is ready when '1'
  Led_in : out std_logic_vector(7 downto 0);
  btn_in : in STD_LOGIC_VECTOR(4 DOWNTO 0) );
END COMPONENT;

COMPONENT disp
PORT  (
  clk_in: IN STD_LOGIC; 
  cath_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
  an_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);--segselect
  display_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0)--     holds data to display
  );
END COMPONENT;

COMPONENT rc5
PORT  (
  rc5_clr_in: IN STD_LOGIC;  -- Clr
  rc5_clk_in: IN STD_LOGIC;  -- Clock signal
  rc5_enc: IN STD_LOGIC := '1';  -- encrypt/decrypt
  rc5_din64 : in std_logic_vector(63 downto 0);
  rc5_input_vld: in STD_LOGIC; --input is ready = '1'
  rc5_dout64 : out std_logic_vector(63 downto 0);
  rc5_dout_vld: OUT STD_LOGIC--answer is ready = '1'
  );
END COMPONENT;

component register128
PORT(
    d   : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    ld  : IN STD_LOGIC; -- load/enable.
    clr : IN STD_LOGIC; -- async. clear.
    clk : IN STD_LOGIC; -- clock.
    q   : OUT STD_LOGIC_VECTOR(127 DOWNTO 0) -- output
);
END COMPONENT;

component register64
PORT(
    d   : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    ld  : IN STD_LOGIC; -- load/enable.
    clr : IN STD_LOGIC; -- async. clear.
    clk : IN STD_LOGIC; -- clock.
    q   : OUT STD_LOGIC_VECTOR(63 DOWNTO 0) -- output
);
END COMPONENT;

COMPONENT key_exp
PORT  (
      clr : IN STD_LOGIC;
		clk	: IN STD_LOGIC;
      key_in	: IN STD_LOGIC;
      ukey	: IN STD_LOGIC_VECTOR(127 DOWNTO 0);--16 byte user passphrase
      skey	: INOUT S_ARRAY; --26 entry ram
      key_rdy	: OUT STD_LOGIC := '0'
  );
END COMPONENT;


--SIGNALS

--rotate signals
signal rot_input : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal rot_by : STD_LOGIC_VECTOR(4 DOWNTO 0);
signal usr_input : STD_LOGIC_VECTOR(7 downto 0); --stores ab_rot

--din and Dout signals
signal dout: STD_LOGIC_VECTOR(31 DOWNTO 0);--       64-bit o/p
signal display: STD_LOGIC_VECTOR(15 DOWNTO 0);--     holds data to display
signal data_rdy: STD_LOGIC := '0';

--state machine temporary signals
signal temp : STD_LOGIC := '0';

--debounced button status signals
signal btn_debounced : STD_LOGIC := '0';
signal oldbutton : std_logic := '0';--used in update clk
signal selectB : boolean;

--input and answer signals
signal a_input_reg : STD_LOGIC_VECTOR(63 DOWNTO 0) := x"0000000000000000";
signal b_input_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"FFFFFFFF";
signal input_reg : STD_LOGIC_VECTOR(63 DOWNTO 0); --64b
signal load : STD_LOGIC := '0';
signal input_key : STD_LOGIC_VECTOR(127 DOWNTO 0);
signal output_reg : STD_LOGIC_VECTOR(63 DOWNTO 0);
signal output_ready : STD_LOGIC := '0';
shared variable answer_reg : STD_LOGIC_VECTOR(63 DOWNTO 0);
signal answer_ready : STD_LOGIC := '0';

--key generation
signal skey_rdy : STD_LOGIC := '0';
signal skey_in : STD_LOGIC := '0';
signal myskey : S_ARRAY;
signal myukey : STD_LOGIC_VECTOR(127 DOWNTO 0);

--encode or decode select
signal enc_dec : STD_LOGIC := '0';
signal clr: STD_LOGIC;

--state machine with 4 states
TYPE  StateCapture IS (ST_ENCDEC, ST_GETDIN, ST_CALC, ST_OUTRDY); --                 
SIGNAL  cstate : StateCapture := ST_ENCDEC; --

--for colleting encdec, din and userkey
type ramtype is array (0 to 7) of std_logic_vector(7 downto 0); 
signal din_arr : ramtype;  --definition of ram
shared VARIABLE state_inc : INTEGER := 0; --0 to 3(and beyond = done)

			--subtype T_SLV_8  is STD_LOGIC_VECTOR(7 downto 0);
			--type    T_SLVV_32 is array(NATURAL range <>) of T_SLV_8;

function to_slv(slvv : ramtype) return STD_LOGIC_VECTOR is
  variable slv : STD_LOGIC_VECTOR(63 downto 0);
begin
  for i in slvv'range loop
    slv( (i * 8) + 7 downto (i * 8) )  := slvv(i);
  end loop;
  return slv;
end function;

begin

--button debounce component
db_button : button PORT MAP (clk_in => clk, btn_in => btn, Led_in => Led, btn_out => btn_debounced);

--display component
mydisplay : disp PORT MAP (clk_in => clk, display_in => display, an_out => an, cath_out => cath); 

--RC5 encryption/decryption component
myrc : rc5 PORT MAP (rc5_clk_in => clk, rc5_clr_in => clr, rc5_enc => enc_dec, rc5_din64 => input_reg, rc5_input_vld => data_rdy, rc5_dout64 => output_reg, rc5_dout_vld => output_ready); 

--user key collection component
mykeyexp : key_exp PORT MAP ( clr => clr, clk => clk, key_in => skey_in, ukey =>myukey(127 downto 0), skey => myskey, key_rdy => skey_rdy);

myreg128 : register128 PORT MAP (clr=>clr, clk => clk, ld => load, d => input_key, q => myukey);

--output register
ans64 : register64 PORT MAP (clr=>clr, clk => clk, ld => temp, d => output_reg, q => answer_reg);

--toggle clear on startup
clr <= '1'; 

input_reg <= to_slv(din_arr);

																					--misc stuff used for testing input
																					--input_reg <= a_input_reg & b_input_reg; --regular input
																					--input_reg <= x"48e56c139616f90f"; --test input
																					--input_reg <= x"0000000000000000";
																					--input_reg <= x"1234567812345678";
																					--input_reg <= a_input_reg;
																					--enc_dec <= '1';


--switch input from user 
usr_input <= sw(7 downto 0);

--light LED on button press
Led(7 downto 0) <= "0000" & enc_dec & data_rdy & output_ready & btn_debounced; --middle button = rightmost led

--choose what to display in led arrays for each cstate
displayMode : process(clk, data_rdy, usr_input, cstate, a_input_reg, btn_debounced, selectB, output_ready, output_reg)
begin
case cstate is
	when ST_ENCDEC => if(usr_input(0)='0') then 
							display<= x"000D"; --indicate we are doing decryption
							else
							display<= x"000E"; --indicate we are doing encryption
							end if;
	when ST_GETDIN => case state_inc is
							when 0  | 9 => display(3 downto 0) <= x"0"; --display numeric representation of our cur state
							when 1  | 10 => display(3 downto 0) <= x"1";
							when 2  | 11 => display(3 downto 0) <= x"2";
							when 3  | 12 => display(3 downto 0) <= x"3";
							when 4  | 13 => display(3 downto 0) <= x"4";
							when 5  | 14 => display(3 downto 0) <= x"5";
							when 6  | 15 => display(3 downto 0) <= x"6";
							when 7  | 16 => display(3 downto 0) <= x"7";
							when 8  | 17 => display(3 downto 0) <= x"8"; 
							when 18 => display(3 downto 0) <= x"9"; --data_rdy <= '1';
							when 19 => display(3 downto 0) <= x"A";
							when 20 => display(3 downto 0) <= x"B";
							when 21 => display(3 downto 0) <= x"C";
							when 22 => display(3 downto 0) <= x"D";
							when 23 => display(3 downto 0) <= x"E";
							when 24 => display(3 downto 0) <= x"F";
							when others => display(3 downto 0) <= x"F"; 
							end case;
							display(15 downto 4) <= usr_input & x"B"; 
	when ST_CALC =>   display <= x"3333";
	when ST_OUTRDY =>	case usr_input is --when done collecting user input show all values
			when "00000001" => display <= answer_reg(15 downto 0);
			when "00000010" => display <= answer_reg(31 downto 16);
			when "00000100" => display <= answer_reg(47 downto 32);
			when "00001000" => display <= answer_reg(63 downto 48);
			when others => display <= x"FFFF"; --error
		   end case;
end case;
end process displayMode;


-- save user input to a register byte by byte. if clr = 0, store a from dinarr. else store new a for next time.
PROCESS(clr, clk)  
BEGIN
  IF(clr='0') THEN state_inc := 0;
  ELSIF(clk'EVENT AND clk='1') THEN
  
     --check for button press
	  if (btn_debounced = '1') and (btn_debounced'EVENT) THEN
	     state_inc := state_inc + 1;
	  END IF;
  
		--data collection
	  if (state_inc < 1) then
			enc_dec <= usr_input(0); --enc_dec
			load <= '0';
	  elsif (state_inc < 9) then
			din_arr(state_inc - 1) <= usr_input;--din
			load <= '0';
	  elsif (state_inc < 25 and state_inc > 8) then
			input_key(127 downto 0) <= myukey(119 downto 0) & usr_input;
			load <= '1';
	  else
	      load <= '0';
			data_rdy <= '1';
     end if;
  end if;
END PROCESS;


--primary state machine
PROCESS(clr, clk)
   BEGIN
      IF(clr='0') THEN  --start idle
         cstate<=ST_ENCDEC;
      ELSIF(clk'EVENT AND clk='1') THEN   --on clock high, change the state 
         CASE cstate IS
            WHEN ST_ENCDEC=> IF(state_inc = 1) THEN cstate<=ST_GETDIN;  --if data valid change to preround
									  END IF;
            WHEN ST_GETDIN=> IF(data_rdy='1') THEN cstate<=ST_CALC;
									  END IF;
            WHEN ST_CALC=>   IF(output_ready = '1') THEN 
				                 cstate<=ST_OUTRDY;
									  END IF;
				WHEN ST_OUTRDY=> temp <= '1';
            WHEN others => cstate <= ST_ENCDEC;	
         END CASE;
      END IF;
END PROCESS;

end Behavioral;

