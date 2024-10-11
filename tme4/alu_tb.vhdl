
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.MATH_REAL.ALL;

ENTITY alu_tb IS 
END ENTITY ; 

architecture structure of alu_tb is 


    component alu
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
    end component;

    signal op1,op2 : Std_Logic_Vector(31 downto 0);
    signal cin, cout : Std_Logic;
    signal cmd : Std_Logic_Vector(1 downto 0);
    signal res : Std_Logic_Vector(31 downto 0);
    signal z,n,v : Std_Logic;
    signal vdd,vss : bit;


begin
    alu0: alu 
    port map(
        op1 => op1,
        op2 => op2,
        cin => cin,
        cmd => cmd,
        res => res,
        cout => cout,
        z => z,
        n => n,
        v => v,
        vdd => vdd,
        vss => vss
    );

process 

variable resAdd : Std_Logic_Vector(32 downto 0);
variable resOp : Std_Logic_Vector(31 downto 0);
variable ca : std_logic_vector(31 downto 0);
variable cb : std_logic_vector(31 downto 0);
variable ccmd : std_logic_vector(1 downto 0);
variable ccin : std_logic_vector(1 downto 0);

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
        ccmd := rand_slv(2);
        op1 <= ca;
        op2 <= cb;
        cmd <= ccmd;

        ccin := rand_slv(2);
        cin <= ccin(0);


        wait for 1 ns; 

        resAdd:= std_logic_vector(unsigned("0" & ca) + unsigned("0" & cb) + unsigned'(""&ccin(0)) ) ;
        
        resOp := ca and cb when ccmd = "01" else
                 ca or cb when ccmd = "10" else
                 ca xor cb when ccmd = "11";
        
        
        if ccmd ="00" then 
            assert resAdd(31 downto 0) = res report "res is " & integer'image(to_integer(unsigned(res(30 downto 0)))) & " resAdd is "
               &  integer'image(to_integer(unsigned(resAdd(30 downto 0)))) severity error;
            assert resAdd(31) = cout report "erreur cout" ;
        else 
            assert resOp = res report "res is " & integer'image(to_integer(unsigned(res(30 downto 0)))) & " resOp is "
                   & integer'image(to_integer(unsigned(resOp(30 downto 0)))) severity error;
        end if;

        
        
end loop La;

wait; 
end process; 

end structure;