

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use IEEE.STD_LOGIC_unsigned.all;

ENTITY adder32bit is 
	port( 
		
		A : in std_logic_vector(31 downto 0); 
		B : in std_logic_vector(31 downto 0); 
       	cin : in std_logic;	
		cout : out std_logic; 
		Q : out std_logic_vector(31 downto 0) 
    	 );
END ENTITY; 


architecture behavioural of adder32bit is
	
	signal temp : std_logic_vector(32 downto 0);
	begin
		process(a,b,cin)
		begin
			temp <= std_logic_vector(unsigned("0" & A) + unsigned("0" & B) + unsigned'(""&cin) ) ;
		end process;

		q  <= temp(31 downto 0);
		cout   <= temp(32);

end behavioural;
