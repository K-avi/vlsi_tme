library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity Alu is
	port ( op1 : in Std_Logic_Vector(31 downto 0); --premiere opérande
	op2 : in Std_Logic_Vector(31 downto 0); --deuxieme opérande
	cin : in Std_Logic; --retenue d'entrée
	cmd : in Std_Logic_Vector(1 downto 0); --00:add, 01:and, 10:or, 11:xor
	res : out Std_Logic_Vector(31 downto 0); --résultat 
	cout : out Std_Logic; --retenue de sortie
	z : out Std_Logic; --flag zero
	n : out Std_Logic; --flag négatif
	v : out Std_Logic; --flag overflow
	vdd : in bit; --pas utilisé? 
	vss : in bit); --pas utilisé?
end Alu;

architecture behavior of Alu is 
    --on change en behavior pour pouvoir utiliser des if / else. 
    --je pensais que when était mieux mais visiblement non (d'après ce 
    --que j'ai compris? ). En tout cas cela permet une meilleure clarté.


    --on remplace les signaux de l'ancienne version par des variables dans un process. Les 
    --variables étant mises à jour directement à l'affectation, cela permet d'éviter des erreurs 
    --de programmation.
begin

    process(op1,op2,cmd)
        variable resAdd : Std_Logic_Vector(32 downto 0);
        --32 bits pour l'addition, les 31 premiers pour le résultat, le dernier pour la retenue

        variable resVar : Std_Logic_Vector(31 downto 0); --variable pour la sortie
	
    begin
        resAdd := Std_Logic_Vector('0' & unsigned(op1) + ('0' & unsigned(op2)) + (X"00000000" & cin)) ;


	if unsigned(cmd) = b"00" then  --addition
        resVar := resAdd(31 downto 0);
        cout <= resAdd(32);
    elsif unsigned(cmd) = b"01" then --and
        resVar := op1 and op2;
        cout <= cin;
    elsif unsigned(cmd) = b"10" then --or
        resVar := op1 or op2;
        cout <= cin;
    elsif unsigned(cmd) = b"11" then --xor
        resVar := op1 xor op2;
        cout <= cin;
    end if;

    --mise à jour des flags
    --on change bien les flags dans chaque cas, pour 
    --maintenir des valeurs cohérentes (d'où les if ET else).

    --flag zero 
    if resVar = X"00000000" then
        z <= '1'; 
    else
        z <= '0';
    end if;

    --flag négatif
    if resVar(31) = '1' then
        n <= '1';
    else
        n <= '0';
    end if;

    --flag overflow
    if resAdd(32) = '1' then 
        v <= '1';
    else
        v <= '0';
    end if;

    res <= resVar;

    end process;
end behavior;
