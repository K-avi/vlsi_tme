library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg is

	port(
	-- Write Port 1 prioritaire
		wdata1		: in Std_Logic_Vector(31 downto 0); --port d'écriture, ecrit au registre numéro wadr1
		wadr1			: in Std_Logic_Vector(3 downto 0);
		wen1			: in Std_Logic; --est ce que on write ou pas ? 

	-- Write Port 2 non prioritaire
		wdata2		: in Std_Logic_Vector(31 downto 0); --port d'écriture, ecrit au registre numéro wadr2
		wadr2		: in Std_Logic_Vector(3 downto 0);
		wen2		: in Std_Logic; --est ce qu'on write ? 

	-- Write CSPR Port
		wcry			: in Std_Logic; --idx 0
		wzero			: in Std_Logic; --idx 1 
		wneg			: in Std_Logic; --idx 2 
		wovr			: in Std_Logic; --idx 3 
		cspr_wb			: in Std_Logic; --modifie  on les flags ? 
		
	-- Read Port 1 32 bits
		reg_rd1		: out Std_Logic_Vector(31 downto 0); --ports de sortie prend la valeur de reg numéro radr1 
		radr1		: in Std_Logic_Vector(3 downto 0); --numero du registre sur 4 bits 
		reg_v1		: out Std_Logic; -- bit de validité du registre de num radr1

	-- Read Port 2 32 bits
		reg_rd2		: out Std_Logic_Vector(31 downto 0); --port de sortie, prend la valeur de reg numéro radr1
		radr2		: in Std_Logic_Vector(3 downto 0);
		reg_v2		: out Std_Logic; -- bit de validité de radr2

	-- Read Port 3 32 bits
		reg_rd3		: out Std_Logic_Vector(31 downto 0); -- port de sortie prend la valeur de reg de numéro radr3 
		radr3		: in Std_Logic_Vector(3 downto 0);
		reg_v3		: out Std_Logic; -- bit de validité du registre num radr3

	-- read CSPR Port
		reg_cry		: out Std_Logic; --port dre sortie des flags
		reg_zero	: out Std_Logic;
		reg_neg		: out Std_Logic;
		reg_cznv	: out Std_Logic;
		reg_ovr		: out Std_Logic;
		reg_vv		: out Std_Logic;
		
	-- Invalidate Port 
		inval_adr1	: in Std_Logic_Vector(3 downto 0); --numero du registre a invalider
		inval1		: in Std_Logic; -- est ce qu'on invalide? 

		inval_adr2	: in Std_Logic_Vector(3 downto 0); --numero du registre a invalider 
		inval2		: in Std_Logic; -- est ce qu'on invalide ? 

		inval_czn	: in Std_Logic; --invalidité des flags carry, zero, negative
		inval_ovr	: in Std_Logic; --invalidité du flag overflow

	-- PC
		reg_pc		: out Std_Logic_Vector(31 downto 0); --sortie pc+4 
		reg_pcv		: out Std_Logic; --sortie bit de validité de pc 
		inc_pc		: in Std_Logic; --est ce qu'on incremente ? 
	
	-- global interface
		ck			: in Std_Logic;
		reset_n		: in Std_Logic;
		vdd			: in bit;
		vss			: in bit);
end Reg;

architecture Behavior OF Reg is
	
	type register_array is array(15 downto 0) of std_logic_vector(31 downto 0 );
	signal regs : register_array ;
	signal validity_bits : std_logic_vector(15 downto 0) ;

	signal flags_register : std_logic_vector(3 downto 0 );
	signal flags_validity_bits : std_logic_vector(1 downto 0 );


	begin

		--gestion reset_n 
		validity_bits <= x"FFFF" when reset_n = '1'; 
		flags_validity_bits <= b"11" when reset_n = '1' ; 

		--mise a jour des flags 
		
		flags_register(0) <=  wcry when cspr_wb = '1' ; 
		flags_register(1) <= wzero when cspr_wb = '1' ; 
		flags_register(2) <= wneg when cspr_wb = '1' ;
		flags_register(3) <= wovr when cspr_wb = '1' ;
		flags_validity_bits <= b"11" when cspr_wb = '1' ; --remet les bits de validite a 1 


		--affecte les valeurs des ports de lecture
		reg_rd1 <= regs(to_integer(unsigned(radr1))); --met valeurs des registres dans ports de lecture
		reg_rd2 <= regs(to_integer(unsigned(radr2)));
		reg_rd3 <= regs(to_integer(unsigned(radr3)));

		--affecte les bits de validité des ports de lecture
		reg_v1 <= validity_bits(to_integer(unsigned(radr1)));
		reg_v2 <= validity_bits(to_integer(unsigned(radr2)));
		reg_v3 <= validity_bits(to_integer(unsigned(radr3)));

		--le vhdl n'est pas censé fonctionner comme ça ; je ne sais pas ce qu'il va se passer
		--avec cette suite d'affectation 
		
		--je pense que ca va pas
		--ecrits les valeurs du port d'écriture dans les regsitres 
		
		regs(to_integer(unsigned(wadr1))) <= wdata1 when validity_bits(to_integer(unsigned(wadr1))) = '0' and wen1 = '1' ;
		regs(to_integer(unsigned(wadr2))) <= wdata2 when validity_bits(to_integer(unsigned(wadr2))) = '0' 
		and not wadr2 = wadr1 and wen2 = '1' ; --ignorée si sur le meme registre car vient de mem

		validity_bits(to_integer(unsigned(wadr1))) <= '1' when wen1 = '1' ; 
		validity_bits(to_integer(unsigned(wadr2))) <= '1' when wen2 = '1' ; 

		-- mise des flags en lecture
		reg_cry <= flags_register(0) ; 
		reg_zero <= flags_register(1) ;
		reg_neg <=  flags_register(2) ; 
		reg_cznv <= flags_validity_bits(0) ; 
		reg_ovr <=  flags_register(3)  ;
		reg_vv <= flags_validity_bits(1);


		--port d'invalidation 

		validity_bits(to_integer(unsigned(inval_adr1))) <= '0' when inval1 = '1' ; --invalide bit si inval 1 == 1 
		validity_bits(to_integer(unsigned(inval_adr2))) <= '0' when inval2 = '1' ;

		flags_validity_bits(0) <= '0' when inval_ovr = '1' ;
		flags_validity_bits(1) <= '0' when inval_czn = '1' ; 

		--incrémente pc de 4 quand inc_pc est égal à 1 
		regs(15) <= std_logic_vector(to_unsigned( to_integer(unsigned(regs(15)))+4, 16)) when inc_pc = '1' and 
		not (wadr1 = x"F" and wen1 = '1') and not(wadr2 = x"F" and wen2 = '1') ;

		reg_pc <= std_logic_vector(to_unsigned( to_integer(unsigned(regs(15)))+4, 16)) when inc_pc = '1' and 
		not (wadr1 = x"F" and wen1 = '1') and not(wadr2 = x"F" and wen2 = '1') ;
			

end Behavior;
