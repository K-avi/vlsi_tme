LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY adder_32b_tb IS 
END ENTITY ; 

architecture structure of adder_32b_tb is 

	component adder32bit
	port( a, b : in std_logic_vector(31 downto 0);
	      cin : in std_logic;
	      q : out std_logic_vector(31 downto 0); 
	      cout : out std_logic);
	end component;
	signal a,b,q : std_logic_vector(31 downto 0); 
	signal cin, cout : std_logic;	
	begin 
		adder32bit_0: adder32bit
		port map( a=>a,
	       		  b=>b,
		  	  cin=>cin, 
			  q=>q,
			  cout=>cout);

process 

variable qv : natural;
variable coutv : std_logic;

function nat_to_std (v: in natural) return std_logic is
	variable res : std_logic;
begin
	if v = 1 then
		res := '1';
	else
		res := '0';
	end if;
	return res;
end function nat_to_std;


begin 

	
	

assert false report  "end of test" severity error; 	
wait; 
end process; 
end structure;
