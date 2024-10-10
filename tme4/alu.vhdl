library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity Alu is
	port ( op1 : in Std_Logic_Vector(31 downto 0);
	op2 : in Std_Logic_Vector(31 downto 0);
	cin : in Std_Logic;
	cmd : in Std_Logic_Vector(1 downto 0);
	res : out Std_Logic_Vector(31 downto 0);
	cout : out Std_Logic;
	z : out Std_Logic;
	n : out Std_Logic;
	v : out Std_Logic;
	vdd : in bit;
	vss : in bit);
end Alu;

architecture structure of Alu is 

	component adder4bit -- a remplacer par adder 32 bit
		port(
			A : in Std_Logic_Vector(3 downto 0);
			B : in Std_Logic_Vector(3 downto 0);
			cin : in Std_Logic;
			cout : out Std_Logic;
			Q : out Std_Logic_Vector(3 downto 0)
		);
	end component;
	signal resOp,resAdd : Std_Logic_Vector(31 downto 0);

begin
	
	resOp <= resAdd when cmd = "00" else
		op1 and op2 when cmd = "01" else
		op1 or op2 when cmd = "10" else
		op1 xor op2 when cmd = "11";
	
	--zero flag
	z <= '1' when not resOp = "00000000000000000000000000000000" else '0'; 
	--negative flag
	n <= resOp(31);
	--overflow flag
	v <= '1' when cmd = "00" and (resAdd < op1 or resAdd < op2) else '0';
	cout <= v;

	res <= resOp;

end structure;


