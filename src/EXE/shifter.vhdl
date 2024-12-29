library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity shifter is 
    port(
        shift_lsl : in Std_Logic;--shift left logical
        shift_lsr : in Std_Logic;--shift right logical
        shift_asr : in Std_Logic;--shift right arithmetic
        shift_ror : in Std_Logic;--rotate right
        shift_rrx : in Std_Logic;--rotate right with carry
        shift_val : in Std_Logic_Vector(4 downto 0); --valeur du shift
        din : in Std_Logic_Vector(31 downto 0);--valeur d'entrée
        cin : in Std_Logic;--retenue d'entrée
        dout : out Std_Logic_Vector(31 downto 0);--valeurs de sortie
        cout : out Std_Logic;--retenue de sortie
        -- global interface
        vdd : in bit;--pas utilisé?
        vss : in bit
    );
end Shifter;


architecture behavior of shifter is 
begin

    --l'ancienne version utilisait beaucoup de conversions, ce n'est pas une bonne 
    --pratique, la nouvelle sera plus verbeuse. PS : 
    --la version actuelle n'est pas synthétisable, pour cela, il faudrait complètement 
    --se passer des conversions et des fonctions de shift. On se contentera de cette solution 
    --pour l'instant.
    
    
    --dout <= std_logic_vector(shift_left(unsigned(din),to_integer(unsigned(shift_val)))) when shift_lsl = '1' else --lsl
    --       std_logic_vector(shift_right(unsigned(din),to_integer(unsigned(shift_val)))) when shift_lsr = '1' else  --lsr 
    --        std_logic_vector(shift_right(signed(din),to_integer(unsigned(shift_val)))) when shift_lsl = '1' else --asr

    --        std_logic_vector(shift_right(signed(din),1) or ('0'&cin)) when shift_rrx = '1' else --rrx 
    --        std_logic_vector( din( to_integer(unsigned(shift_val))-1  downto 0 ) & din(31 downto to_integer(unsigned(shift_val)))) 
    --        when shift_ror = '1' ;

    process(shift_lsl,shift_lsr,shift_ror, shift_asr) 

    --le résultat de chaque shift possible va être effectué avant l'affectation des 
    --sorties. Ce résultat est stocké dans les variables res_shift_left, res_shift_right, etc
    variable res_shift_lsl : Std_Logic_Vector(31 downto 0);
    variable res_shift_lsr : Std_Logic_Vector(31 downto 0);
    variable res_shift_ror : Std_Logic_Vector(31 downto 0);
    variable res_shift_asr : Std_Logic_Vector(31 downto 0);
    variable res_shift_rrx : Std_Logic_Vector(31 downto 0);


    variable carry_out_lsl, carry_out_lsr, carry_out_asr, carry_out_ror, carry_out_rrx : Std_Logic;

    begin 
    --je crois que cette version du shifter n'est pas synthétisable, il faudrait 
    --éviter des opérations avec shift_left et les conversions ? Honnêtement j'ai du mal avec le vhdl

    --traitement du shift gauche logique
    res_shift_lsl := std_logic_vector(shift_left(unsigned(din),to_integer(unsigned(shift_val))));
    if shift_val = "00000" then 
        carry_out_lsl := '0';
    else 
        carry_out_lsl := din(32-to_integer(unsigned(shift_val))); --recupérer le bit n-1 depuis le lsb
    end if;

    --traitement du shift droit logique
    res_shift_lsr := std_logic_vector(shift_right(unsigned(din),to_integer(unsigned(shift_val))));
    if shift_val = "00000" then 
        carry_out_lsr := '0';
    else 
        carry_out_lsr := din(to_integer(unsigned(shift_val))-1); --recupérer le bit n-1 depuis le lsb
    end if;

    --traitement du shift droit arithmétique
    res_shift_asr := std_logic_vector(shift_right(signed(din),to_integer(unsigned(shift_val))));
    if shift_val = "00000" then 
        carry_out_asr := '0';
    else 
        carry_out_asr := din(to_integer(unsigned(shift_val))-1); --recupérer le bit n-1 depuis le lsb
    end if;

    --traitement de la rotation droite
    res_shift_ror := std_logic_vector(rotate_right(unsigned(din),to_integer(unsigned(shift_val))));
    if shift_val = "00000" then 
        carry_out_ror := '0';
    else 
        carry_out_ror := din(to_integer(unsigned(shift_val))-1); --recupérer le bit n-1 depuis le lsb
    end if;

    --traitement de la rotation sur 32 bits avec la retenue
    res_shift_rrx := ("" &  cin) & din(31 downto 1); --concaténation de la retenue et des 30 premiers bits
    carry_out_rrx := din(0); --retenue = ancien bit 0

    --affectation des sorties
    if(shift_lsl = '1') then
        dout <= res_shift_lsl ;
        cout <= carry_out_lsl ;
    elsif (shift_lsr = '1' or shift_asr = '1') then
        dout <= res_shift_lsr ;
        cout <= carry_out_lsr ;
    elsif(shift_asr = '1') then
        dout <= res_shift_asr ;
        cout <= carry_out_asr ;
    elsif(shift_ror = '1') then
        dout <= res_shift_ror ;
        cout <= carry_out_ror ;
    elsif(shift_rrx = '1') then
        dout <= res_shift_rrx ;
        cout <= carry_out_rrx ;
    end if;

    end process;


end behavior;