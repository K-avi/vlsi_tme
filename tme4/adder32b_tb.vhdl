LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY adder32b_tb IS 
END ENTITY ; 

architecture structure of adder32b_tb is 

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

variable qv : integer;
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

	
La: for va in 0 to 15 loop
	Lb: for vb in 0 to 15 loop
		Lc: for vc in 0 to 1 loop
			a<= std_logic_vector(to_unsigned(va,32)); 
			b<= std_logic_vector(to_unsigned(vb,32)); 
			cin<= nat_to_std(vc); 
			
			--report "cin " & integer'image(cin)) ;
			--add elements in qv
			
			qv:= va+vb+vc;
			coutv := '0';
				   
			wait for 2 ns; 

			-- assert std_logic_vector(to_unsigned(qv,32))=q report integer'image(to_integer(unsigned(q))) severity error; 		
		
			 assert  std_logic_vector(to_unsigned(qv,32))=q report "q is " & integer'image(to_integer(unsigned(q))) & " qv is " & integer'image(qv)
			 severity error; 
			 assert cout=coutv report "erreur cout" severity error; 	

		end loop Lc; 
	end loop Lb; 
end loop La; 

	

assert false report  "end of test" severity error; 	
wait; 
end process; 
end structure;
