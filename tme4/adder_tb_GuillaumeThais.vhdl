library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library work;
--use work.bidon.all;


--  A testbench has no ports.
entity adder_tb is
end adder_tb;

architecture Structurel of adder_tb is
	--  Declaration un composant
	component Add4b
	port (
		A : in std_logic_vector(3 downto 0);
		B : in std_logic_vector(3 downto 0);
		Cin : in std_logic;
		Cout : out std_logic;
		S : out std_logic_vector(3 downto 0)
	);
	end component;

	signal A, B, S : std_logic_vector(3 downto 0);
	signal Cin, Cout : std_logic;

	begin
	Add4b_0: Add4b
	port map (
		A => A,
		B => B,
		Cin => Cin,
		S => S,
		Cout => Cout
	);

process

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

function nat_to_std_vec (v: in natural; len: in natural) return std_logic_vector is
-- variable res : std_logic_vector;
begin
	return std_logic_vector(to_unsigned(v, len));
end function nat_to_std_vec;

variable vS : natural;
variable vS_vec : std_logic_vector(4 downto 0);

begin
La : for va in 0 to 15 loop
	Lb : for vb in 0 to 15 loop
		Lc : for vc in 0 to 1 loop
			A <= nat_to_std_vec(va, 4);
			B <= nat_to_std_vec(vb, 4);
			Cin <= nat_to_std(vc);
			vS := va + vb + vc;
			vS_vec := nat_to_std_vec(vS, 5);
			wait for 1 ns;
			assert vS_vec(3 downto 0) = S report "Erreur sur S" severity error;
			assert vS_vec(4) = Cout report "Erreur sur Cout" severity error;
		end loop Lc;
	end loop Lb;
end loop La;
assert false report "end of test" severity note;
--  Wait forever; this will finish the simulation.
wait;
end process;
end Structurel;
