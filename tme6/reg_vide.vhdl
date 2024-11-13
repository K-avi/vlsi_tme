library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg is
	port(
	-- Write Port 1 prioritaire
		wdata1		: in Std_Logic_Vector(31 downto 0);
		wadr1			: in Std_Logic_Vector(3 downto 0);
		wen1			: in Std_Logic;

	-- Write Port 2 non prioritaire
		wdata2		: in Std_Logic_Vector(31 downto 0);
		wadr2		: in Std_Logic_Vector(3 downto 0);
		wen2		: in Std_Logic;

	-- Write CSPR Port
		wcry			: in Std_Logic;
		wzero			: in Std_Logic;
		wneg			: in Std_Logic;
		wovr			: in Std_Logic;
		cspr_wb			: in Std_Logic;
		
	-- Read Port 1 32 bits
		reg_rd1		: out Std_Logic_Vector(31 downto 0); --ports de sortie prend la valeur de reg numéro radr1 
		radr1		: in Std_Logic_Vector(3 downto 0); --numero du registre sur 4 bits 
		reg_v1		: out Std_Logic;

	-- Read Port 2 32 bits
		reg_rd2		: out Std_Logic_Vector(31 downto 0); --port de sortie, prend la valeur de reg numéro radr1
		radr2		: in Std_Logic_Vector(3 downto 0);
		reg_v2		: out Std_Logic;

	-- Read Port 3 32 bits
		reg_rd3		: out Std_Logic_Vector(31 downto 0);
		radr3		: in Std_Logic_Vector(3 downto 0);
		reg_v3		: out Std_Logic;

	-- read CSPR Port
		reg_cry		: out Std_Logic;
		reg_zero	: out Std_Logic;
		reg_neg		: out Std_Logic;
		reg_cznv	: out Std_Logic;
		reg_ovr		: out Std_Logic;
		reg_vv		: out Std_Logic;
		
	-- Invalidate Port 
		inval_adr1	: in Std_Logic_Vector(3 downto 0);
		inval1		: in Std_Logic;

		inval_adr2	: in Std_Logic_Vector(3 downto 0);
		inval2		: in Std_Logic;

		inval_czn	: in Std_Logic;
		inval_ovr	: in Std_Logic;

	-- PC
		reg_pc		: out Std_Logic_Vector(31 downto 0); 
		reg_pcv		: out Std_Logic;
		inc_pc		: in Std_Logic;
	
	-- global interface
		ck			: in Std_Logic;
		reset_n		: in Std_Logic;
		vdd			: in bit;
		vss			: in bit);
end Reg;

architecture Behavior OF Reg is
	
	type register_array is array(15 downto 0) of std_logic_vector(31 downto 0 );
	signal regs : register_array ;


	begin

		--gestion reset_n 
		reg_v3 <= not reset_n;
		
		reg_rd1 <= regs(to_integer(unsigned(radr1)));
		
		reg_rd1 <= reg0 when radr1 = "0000" else 
				   reg1 when radr1 = "0001" else 
				   reg2 when radr1 = "0010" else 
				   reg3 when radr1 = "0011" else 

				   reg4 when radr1 = "0100" else 
				   reg5 when radr1 = "0101" else 
				   reg6 when radr1 = "0110" else 
				   reg7 when radr1 = "0111" else 

				   reg8 when radr1 = "1000" else 
				   reg9 when radr1 = "1001" else 
				   reg10 when radr1 = "1010" else 
				   reg11 when radr1 = "1011" else 

				   reg12 when radr1 = "1100" else 
				   reg13 when radr1 = "1101" else 
				   reg14 when radr1 = "1110" else 
				   reg15 when radr1 = "1111" ;
		
		reg_rd2 <= reg0 when radr2 = "0000" else 
				   reg1 when radr2 = "0001" else 
				   reg2 when radr2 = "0010" else 
				   reg3 when radr2 = "0011" else 

				   reg4 when radr2 = "0100" else 
				   reg5 when radr2 = "0101" else 
				   reg6 when radr2 = "0110" else 
				   reg7 when radr2 = "0111" else 

				   reg8 when radr2 = "1000" else 
				   reg9 when radr2 = "1001" else 
				   reg10 when radr2 = "1010" else 
				   reg11 when radr2 = "1011" else 

				   reg12 when radr2 = "1100" else 
				   reg13 when radr2 = "1101" else 
				   reg14 when radr2 = "1110" else 
				   reg15 when radr2 = "1111" ;
		
		reg_rd3 <= reg0 when radr3 = "0000" else 
				   reg1 when radr3 = "0001" else 
				   reg2 when radr3 = "0010" else 
				   reg3 when radr3 = "0011" else 

				   reg4 when radr3 = "0100" else 
				   reg5 when radr3 = "0101" else 
				   reg6 when radr3 = "0110" else 
				   reg7 when radr3 = "0111" else 

				   reg8 when radr3 = "1000" else 
				   reg9 when radr3 = "1001" else 
				   reg10 when radr3 = "1010" else 
				   reg11 when radr3 = "1011" else 

				   reg12 when radr3 = "1100" else 
				   reg13 when radr3 = "1101" else 
				   reg14 when radr3 = "1110" else 
				   reg15 when radr3 = "1111" ;

		reg0 <= wdata1 when wadr1 = "000" else 
				wdata2 when wadr2 = "000" else 
				reg0 ;
		
		reg1 <= wdata1 when wadr1 = "001" else 
				wdata2 when wadr2 = "001" else 
				reg0 ;




		
		
		


		
		

		-- ports de sortie

end Behavior;
