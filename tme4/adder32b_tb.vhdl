LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.MATH_REAL.ALL;

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

variable qv : std_logic_vector(32 downto 0);
variable coutv : std_logic;
variable ca : std_logic_vector(31 downto 0);
variable cb : std_logic_vector(31 downto 0);
variable cc : std_logic_vector(1 downto 0);

impure function rand_slv(len : integer) return std_logic_vector is
	variable r : real;
	variable slv : std_logic_vector(len - 1 downto 0);
	variable seed1, seed2 : integer;
  begin
	for i in slv'range loop
	  seed1 := 2 ; seed2 := 3;
	  uniform(seed1, seed2, r);
	  slv(i) := '1' when r > 0.5 else '0';
	end loop;
	return slv;
  end function;
begin 
	
La: for va in 0 to 1000 loop

			ca := rand_slv(32);
			cb := rand_slv(32);
			cc := rand_slv(2);
			a<= ca;
			b<= cb;
			cin<= cc(0);

			
			qv:= std_logic_vector(unsigned("0" & ca) + unsigned("0" & cb) + unsigned'(""&cc(0)) ) ;
				   
			wait for 1 ns; 		
			 assert  qv(31 downto 0)=q report "q is " & integer'image(to_integer(unsigned(q))) & " qv is "
			  & integer'image(to_integer(unsigned(qv(31 downto 0)))) severity error;
		
			 assert cout=qv(32) report "erreur cout" severity error; 	

	
end loop La; 

	

assert false report  "end of test" severity error; 	
wait; 
end process; 
end structure;
