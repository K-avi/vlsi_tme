library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity shifter is 
    port(
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
end Shifter;


architecture structure of shifter is 
begin

   
    dout <= std_logic_vector(shift_left(unsigned(din),to_integer(unsigned(shift_val)))) when shift_lsl = '1' else --lsl
            std_logic_vector(shift_right(unsigned(din),to_integer(unsigned(shift_val)))) when shift_lsr = '1' else  --lsr 
            std_logic_vector(shift_right(signed(din),to_integer(unsigned(shift_val)))) when shift_lsl = '1' else --asr

            std_logic_vector(shift_right(signed(din),1) or ('0'&cin)) when shift_rrx = '1' else --rrx 
            std_logic_vector( din( to_integer(unsigned(shift_val))-1  downto 0 ) & din(31 downto to_integer(unsigned(shift_val)))) 
            when shift_ror = '1' ;


    --doesnt take ror, asr and rrx into account
    cout <= din(0) when shift_lsl = '1' else 
            din(31) when shift_lsr = '1' or shift_asr = '1' or shift_ror = '1' or shift_rrx = '1'; 
            

end architecture;