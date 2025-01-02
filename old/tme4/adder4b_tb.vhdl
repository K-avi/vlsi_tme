LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY adder_test IS 
END ENTITY ; 

architecture structure of adder_test is 

	component adder4bit
	port( a, b : in std_logic_vector(3 downto 0);
	      cin : in std_logic;
	      q : out std_logic_vector(3 downto 0); 
	      cout : out std_logic);
	end component;
	signal a,b,q : std_logic_vector(3 downto 0); 
	signal cin, cout : std_logic;	
	begin 
		adder4bit_0: adder4bit
		port map( a=>a,
	       		  b=>b,
		  	  cin=>cin, 
			  q=>q,
			  cout=>cout);

process 

variable qv : natural ;
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
				a<= std_logic_vector(to_unsigned(va,4)); 
				b<= std_logic_vector(to_unsigned(vb,4)); 
				cin<= nat_to_std(vc); 
			        	
			        qv := va+ vb + vc ;  
			        
				if qv > 15 then 
					qv := qv - 16 ; 
					coutv := '1'; 
				else 
					coutv :='0';
				end if;
			      	 
				wait for 1 ns; 
			 	assert std_logic_vector(to_unsigned(qv,4))=q report integer'image(to_integer(unsigned(q))) severity error; 		
			 	assert cout=coutv report "erreur cout" severity error; 		
			end loop Lc; 
		end loop Lb; 
	end loop La; 
	

assert false report  "end of test" severity error; 	
wait; 
end process; 
end structure;
