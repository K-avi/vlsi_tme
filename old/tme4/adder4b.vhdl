LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY adder1bit IS 
PORT (	 
	     a : in std_logic;
     	     b : in std_logic;		     
	     cin : in std_logic; 
	     q : out std_logic;
	     cout : out std_logic

) ;
END ENTITY ; 

architecture structure of adder1bit is 

begin  
	q <= (a xor b) xor cin ;
       	cout <= (a and b) or ( a and cin) or (b and cin);
end structure;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY adder4bit is 
	port( 
		
		A : in std_logic_vector(3 downto 0); 
		B : in std_logic_vector(3 downto 0); 
       		cin : in std_logic;	
		cout : out std_logic; 
		Q : out std_logic_vector(3 downto 0) 
    	 );
END ENTITY; 

architecture structure2 of adder4bit is 


signal tmp0, tmp1, tmp2, tmp3: std_logic; 
component adder1bit
PORT (	 
	     a : in std_logic;
     	     b : in std_logic;		     
	     cin : in std_logic; 
	     q : out std_logic;
	     cout : out std_logic

) ;
end component;


begin 

adder1bit_0: adder1bit 
port map( a => A(0),
	  b => B(0),
	  cin => cin,
          q => Q(0), 
	  cout => tmp0
);
	
adder1bit_1: adder1bit 
port map( a => A(1),
	  b => B(1),
	  cin => tmp0,
          q => Q(1), 
	  cout => tmp1
);

	
adder1bit_2: adder1bit 
port map( a => A(2),
	  b => B(2),
	  cin => tmp1,
          q => Q(2), 
	  cout => tmp2
);

	
adder1bit_3: adder1bit 
port map( a => A(3),
	  b => B(3),
	  cin => tmp2,
          q => Q(3), 
	  cout => cout
);

end structure2; 
