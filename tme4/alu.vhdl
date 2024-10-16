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

	component adder32bit -- a remplacer par adder 32 bit
		port(
			A : in Std_Logic_Vector(31 downto 0);
			B : in Std_Logic_Vector(31 downto 0);
			cin : in Std_Logic;
			cout : out Std_Logic;
			Q : out Std_Logic_Vector(31 downto 0)
		);
	end component;
	signal resAdd : Std_Logic_Vector(31 downto 0);

begin

	adder32bit_0: adder32bit
	port map(
		A => op1,
		B => op2,
		cin => cin,
		cout => cout,
		Q => resAdd
	);
	process(op1,op2,cmd,resAdd)
  	begin
	
		res <= resAdd when cmd = "00" else
			op1 and op2 when cmd = "01" else
			op1 or op2 when cmd = "10" else
			op1 xor op2 when cmd = "11";
	end process;

	--zero flag
	z <= '1' when res = "00000000000000000000000000000000" else '0'; 
	--negative flag
	n <= res(31);
	--overflow flag
	v <= cout when cmd = "00" else '0';
	

end structure;


