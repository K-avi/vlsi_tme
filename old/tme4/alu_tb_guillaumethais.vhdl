library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--library work;
--use work.bidon.all;


--  A testbench has no ports.
entity alu_tb is
end alu_tb;
architecture Structurel of alu_tb is
	--  Declaration un composant
	component Alu
	port (
		op1 : in std_logic_vector(31 downto 0);
		op2 : in std_logic_vector(31 downto 0);
		cin : in std_logic;
		cmd : in std_logic_vector(1 downto 0);
		res : out std_logic_vector(31 downto 0);
		cout : out std_logic;
		z : out std_logic;
		n : out std_logic;
		v : out std_logic;
		vdd : in bit;
		vss : in bit
	);
	end component;

	signal A, B, S : std_logic_vector(31 downto 0);
	signal Cin : std_logic := '0';
	signal Cout, z, n, v : std_logic;
	signal cmd : std_logic_vector(1 downto 0);

	begin
	Alu_0: Alu
	port map (
		op1 => A,
		op2 => B,
		cin => Cin,
		res => S,
		Cout => Cout,
		cmd => cmd,
		z => z,
		n => n,
		v => v,
		vdd => '1',
		vss => '0'
	);

process

begin
	-- Test Case 1 add
	cmd <= "00";
    A <= x"FFFFFFFF";
    B <= x"00000001";
    wait on S;
    wait for 1 ns; 
    assert (S = x"00000000") report "Test Case 1 Failed" severity error;

    assert (Cout = '1') report "Test Case 1 Cout Failed" severity error;
	  assert (z = '1' and n = '0' and v = '1') report "Test Case 1 flag failed" severity error;

    -- Test Case 2 and
	cmd <= "01";
    A <= x"FFFFFFFF";
    B <= x"F0000001";
    wait for 10 ns;
    assert (S = x"F0000001") report "Test Case 2 Failed" severity error;
	assert (z = '0' and n = '1' and v = '0') report "Test Case 2 flag failed" severity error;

    -- Test Case 3 and
	cmd <= "01";
    A <= x"11111111";
    B <= x"22222222";
    wait for 10 ns;
    assert (S = x"00000000") report "Test Case 3 Failed" severity error;
	  assert (z = '1' and n = '0' and v = '0') report "Test Case 3 flag failed" severity error;

    -- Test Case 4 or
	cmd <= "10";
    A <= x"11111111";
    B <= x"33332222";
    wait for 10 ns;
    assert (S = x"33333333") report "Test Case 4 Failed" severity error;
	assert (z = '0' and n = '0' and v = '0') report "Test Case 4 flag failed" severity error;

    -- Test Case 5 xor
	cmd <= "11";
    A <= x"11111111";
    B <= x"33332222";
    wait for 10 ns;
    assert (S = x"22223333") report "Test Case 5 Failed" severity error;
	assert (z = '0' and n = '0' and v = '0') report "Test Case 4 flag failed" severity error;

assert false report "end of test" severity note;
--  Wait forever; this will finish the simulation.
wait;
end process;
end Structurel;
