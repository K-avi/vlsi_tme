LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.MATH_REAL.ALL;

ENTITY shifter_tb IS 
END ENTITY ; 

architecture structure of shifter_tb is 

    component shifter
    port (  
        shift_lsl : in Std_Logic;
        shift_lsr : in Std_Logic;
        shift_asr : in Std_Logic;
        shift_ror : in Std_Logic;
        shift_rrx : in Std_Logic;
        shift_val : in Std_Logic_Vector(4 downto 0);
        din : in Std_Logic_Vector(31 downto 0);
        cin : in Std_Logic;
        dout : out Std_Logic_Vector(31 downto 0);
        cout : out Std_Logic;
        -- global interface
        vdd : in bit;
        vss : in bit
      );
    end component;

    signal shift_lsl, shift_lsr, shift_asr, shift_ror, shift_rrx  : Std_Logic;
    signal shift_val :  Std_Logic_Vector(4 downto 0);
    signal din :  Std_Logic_Vector(31 downto 0);
    signal cin : Std_Logic;
    signal dout :  Std_Logic_Vector(31 downto 0);
    signal cout :  Std_Logic;
    -- global interface
    signal vdd :  bit;
    signal vss : bit ;

begin 

shifter_0 : shifter 
port map (

        shift_lsl => shift_lsl, 
        shift_lsr => shift_lsr, 
        shift_asr => shift_asr, 
        shift_ror => shift_ror, 
        shift_rrx => shift_rrx, 
        shift_val => shift_val, 
        din => din, 
        cin => cin, 
        dout => dout, 
        cout => cout, 
        -- global interface
        vdd => vdd, 
        vss => vss
);

process 

variable resOp :  Std_Logic_Vector(31 downto 0);
variable vdin : std_logic_vector(31 downto 0);
variable vval : std_logic_vector(4 downto 0);

variable vcin : std_logic_vector(1 downto 0);

variable vcout : std_logic;
variable ccmd,s1,s2 : integer;
variable rnum : real;

impure function rand_slv(len : integer) return std_logic_vector is
	variable r : real;
	variable slv : std_logic_vector(len - 1 downto 0);
	variable seed1, seed2 : integer;
  begin
	for i in slv'range loop
	  seed1 := 2 ; seed2 := 3;
	  uniform(seed1, seed2, r);
	  slv(i) := '1' when r > 0.5 else '0';
	end loop;
	return slv;
  end function;

begin 


    La: for va in 0 to 1000 loop

        vdin := rand_slv(32);
        vval := rand_slv(5);
        vcin := rand_slv(2);
        s1:= 2; 
        s2:=3;

        uniform(s1,s2,rnum);

        if rnum > 0.8 then 
            shift_lsl <= '1' ; 
        elsif rnum > 0.6 then 
            shift_lsr <= '1' ; 
        elsif rnum > 0.4 then 
            shift_asr <= '1'; 
        elsif rnum > 0.2 then 
            shift_ror <= '1' ;
        else
            shift_rrx <= '1' ; 
        end if;

        din <= vdin ; 
        cin <= vcin(0) ;
        shift_val <= vval; 

        wait for 1 ns;

        resOp := std_logic_vector(shift_left(unsigned(din),to_integer(unsigned(shift_val)))) when shift_lsl = '1' else --lsl
                std_logic_vector(shift_right(unsigned(din),to_integer(unsigned(shift_val)))) when shift_lsr = '1' else  --lsr 
                std_logic_vector(shift_right(signed(din),to_integer(unsigned(shift_val)))) when shift_lsl = '1' else --asr

                std_logic_vector(shift_right(signed(din),1) or ('0'&cin)) when shift_rrx = '1' else --rrx 
                std_logic_vector( din( to_integer(unsigned(shift_val))-1  downto 0 ) & din(31 downto to_integer(unsigned(shift_val)))) ;

        vcout := vdin(0) when shift_lsl = '1' else 
                 vdin(31) when shift_lsr = '1' or shift_asr = '1' or shift_ror = '1' or shift_rrx = '1'; 


        assert resOp = dout report "dout is " & integer'image(to_integer(unsigned(dout(30 downto 0)))) & " resOp is "
        &  integer'image(to_integer(unsigned(resOp(30 downto 0)))) severity error;
        assert vcout = cout report "error cout";


    end loop La;

wait; 
end process; 

end structure; 
