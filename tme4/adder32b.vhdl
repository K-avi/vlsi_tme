

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY adder32bit is 
	port( 
		
		A : in std_logic_vector(31 downto 0); 
		B : in std_logic_vector(31 downto 0); 
       	cin : in std_logic;	
		cout : out std_logic; 
		Q : out std_logic_vector(31 downto 0) 
    	 );
END ENTITY; 

architecture structure2 of adder32bit is 

signal total : std_logic_vector(31 downto 0);

begin  
	total <= std_logic_vector( unsigned(A) + unsigned(B) + unsigned'('0'&cin) );
	Q <= total(31 downto 0);
	cout <= (A(31) and B(31) and not total(31)) or (not A(31) and not B(31) and total(31));

end structure2; 
