library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg is

	port(
	-- Write Port 1 prioritaire
		wdata1		: in Std_Logic_Vector(31 downto 0); --port d'écriture, ecrit au registre numéro wadr1
		wadr1			: in Std_Logic_Vector(3 downto 0);--registre d'écriture
		wen1			: in Std_Logic; --est ce que on write ou pas ? si = 1 on write

	-- Write Port 2 non prioritaire
		wdata2		: in Std_Logic_Vector(31 downto 0); --port d'écriture, ecrit au registre numéro wadr2
		wadr2		: in Std_Logic_Vector(3 downto 0);--registre d'écriture
		wen2		: in Std_Logic; --est ce qu'on write ? 

	-- Write CSPR Port
		wcry			: in Std_Logic; --idx 0 valeur de la retenue 
		wzero			: in Std_Logic; --idx 1 valeur du flag zero
		wneg			: in Std_Logic; --idx 2  valeur du flag négatif
		wovr			: in Std_Logic; --idx 3  valeur du flag overflow
		cspr_wb			: in Std_Logic; --modifie  on les flags ? 
		
	-- Read Port 1 32 bits
		reg_rd1		: out Std_Logic_Vector(31 downto 0); --ports de sortie prend la valeur de reg numéro radr1 
		radr1		: in Std_Logic_Vector(3 downto 0); --numero du registre sur 4 bits 
		reg_v1		: out Std_Logic; -- bit de validité du registre de num radr1

	-- Read Port 2 32 bits
		reg_rd2		: out Std_Logic_Vector(31 downto 0); --port de sortie, prend la valeur de reg numéro radr1
		radr2		: in Std_Logic_Vector(3 downto 0); --numero du registre sur 4 bits
		reg_v2		: out Std_Logic; -- bit de validité de radr2

	-- Read Port 3 32 bits
		reg_rd3		: out Std_Logic_Vector(31 downto 0); -- port de sortie prend la valeur de reg de numéro radr3 
		radr3		: in Std_Logic_Vector(3 downto 0);--numero du registre sur 4 bits
		reg_v3		: out Std_Logic; -- bit de validité du registre num radr3

	-- read CSPR Port
		reg_cry		: out Std_Logic; --port dre sortie des flags
		reg_zero	: out Std_Logic;
		reg_neg		: out Std_Logic;
		reg_cznv	: out Std_Logic; --bit de validité des flags carry, zero, negative
		reg_ovr		: out Std_Logic; --valeur de l'oerflow
		reg_vv		: out Std_Logic;--bit de validité de l'overflow
		
	-- Invalidate Port 
		inval_adr1	: in Std_Logic_Vector(3 downto 0); --registre invalidé par decod, pas possible d'écrire dedans
		inval1		: in Std_Logic; -- 1 = on invalide

		inval_adr2	: in Std_Logic_Vector(3 downto 0); --numero du registre a invalider 
		inval2		: in Std_Logic; -- est ce qu'on invalide ? 

		inval_czn	: in Std_Logic; --invalidité des flags carry, zero, negative
		inval_ovr	: in Std_Logic; --invalidité du flag overflow

	-- PC
		reg_pc		: out Std_Logic_Vector(31 downto 0); --
		reg_pcv		: out Std_Logic; --sortie bit de validité de pc 
		inc_pc		: in Std_Logic; --si 1 : pc+=4 sinon valeur d'un branchement
	
	-- global interface
		ck			: in Std_Logic;
		reset_n		: in Std_Logic;
		vdd			: in bit;
		vss			: in bit);
end Reg;

architecture Behavior OF Reg is
	
	type register_array is array(15 downto 0) of std_logic_vector(31 downto 0 );
	signal regs : register_array ;--le banc de registres
	signal validity_bits : std_logic_vector(15 downto 0)  ; --les bits de validité des registres

	signal c, ovr, z, n, czn_valid, ovr_valid : std_logic;--signaux des flags

	begin 

	--pour REG, on va eviter toute conversion pour rendre synthétisable. Pour cela on va 
	--éviter d'indexer regs en convertissant wadr / radr, et on va utiliser des 
	--if, ce qui est très verbeux :/

	--on separe les process d'écriture et de lecture

	proc_write : process(ck, reset_n)

	--process variables
	variable regs_var: register_array;--process local copy of regs
	variable valid_var: std_logic_vector(15 downto 0);
	variable czn_valid_var, ovr_valid_var: std_logic;
	variable pc_33_bits : std_logic_vector(32 downto 0) ;
	variable pc_int : integer;

	begin 
	
	if rising_edge(ck) then --on ne fait rien si on est pas sur un front montant de l'horloge
		if reset_n = '0' then --if reset on met tout à 0 et on valide les flags/regs
			regs(0) <= X"00000000";
			regs(1) <= X"00000000";
			regs(2) <= X"00000000";
			regs(3) <= X"00000000";
			regs(4) <= X"00000000";
			regs(5) <= X"00000000";
			regs(6) <= X"00000000";
			regs(7) <= X"00000000";
			regs(8) <= X"00000000";
			regs(9) <= X"00000000";
			regs(10) <= X"00000000";
			regs(11) <= X"00000000";
			regs(12) <= X"00000000";
			regs(13) <= X"00000000";
			regs(14) <= X"00000000";
			regs(15) <= X"00000000";
			c <= '0';
			z <= '0';
			n <= '0';
			ovr <= '0';
			czn_valid <= '1';
			ovr_valid <= '1';
			validity_bits <= X"FFFF";
		else
			regs_var := regs;
			valid_var := validity_bits;

			--on écrit dans les registres
			if wadr1 = "0000" and wen1 = '1' then
				regs_var(0) := wdata1;
				valid_var(0) := '1';
			elsif wadr2 = "0000" and wen2 = '1' then
				regs_var(0) := wdata2;
				valid_var(0) := '1';
			end if;
			if wadr1 = "0001" and wen1 = '1' then
				regs_var(1) := wdata1;
				valid_var(1) := '1';
			elsif wadr2 = "0001" and wen2 = '1' then
				regs_var(1) := wdata2;
				valid_var(1) := '1';
			end if;
			if wadr1 = "0010" and wen1 = '1' then
				regs_var(2) := wdata1;
				valid_var(2) := '1';
			elsif wadr2 = "0010" and wen2 = '1' then
				regs_var(2) := wdata2;
				valid_var(2) := '1';
			end if;
			if wadr1 = "0011" and wen1 = '1' then
				regs_var(3) := wdata1;
				valid_var(3) := '1';
			elsif wadr2 = "0011" and wen2 = '1' then
				regs_var(3) := wdata2;
				valid_var(3) := '1';
			end if;
			if wadr1 = "0100" and wen1 = '1' then
				regs_var(4) := wdata1;
				valid_var(4) := '1';
			elsif wadr2 = "0100" and wen2 = '1' then
				regs_var(4) := wdata2;
				valid_var(4) := '1';
			end if;
			if wadr1 = "0101" and wen1 = '1' then
				regs_var(5) := wdata1;
				valid_var(5) := '1';
			elsif wadr2 = "0101" and wen2 = '1' then
				regs_var(5) := wdata2;
				valid_var(5) := '1';
			end if;
			if wadr1 = "0110" and wen1 = '1' then
				regs_var(6) := wdata1;
				valid_var(6) := '1';
			elsif wadr2 = "0110" and wen2 = '1' then
				regs_var(6) := wdata2;
				valid_var(6) := '1';
			end if;
			if wadr1 = "0111" and wen1 = '1' then
				regs_var(7) := wdata1;
				valid_var(7) := '1';
			elsif wadr2 = "0111" and wen2 = '1' then
				regs_var(7) := wdata2;
				valid_var(7) := '1';
			end if;
			if wadr1 = "1000" and wen1 = '1' then
				regs_var(8) := wdata1;
				valid_var(8) := '1';
			elsif wadr2 = "1000" and wen2 = '1' then
				regs_var(8) := wdata2;
				valid_var(8) := '1';
			end if;
			if wadr1 = "1001" and wen1 = '1' then
				regs_var(9) := wdata1;
				valid_var(9) := '1';
			elsif wadr2 = "1001" and wen2 = '1' then
				regs_var(9) := wdata2;
				valid_var(9) := '1';
			end if;
			if wadr1 = "1010" and wen1 = '1' then
				regs_var(10) := wdata1;
				valid_var(10) := '1';
			elsif wadr2 = "1010" and wen2 = '1' then
				regs_var(10) := wdata2;
				valid_var(10) := '1';
			end if;
			if wadr1 = "1011" and wen1 = '1' then
				regs_var(11) := wdata1;
				valid_var(11) := '1';
			elsif wadr2 = "1011" and wen2 = '1' then
				regs_var(11) := wdata2;
				valid_var(11) := '1';
			end if;
			if wadr1 = "1100" and wen1 = '1' then
				regs_var(12) := wdata1;
				valid_var(12) := '1';
			elsif wadr2 = "1100" and wen2 = '1' then
				regs_var(12) := wdata2;
				valid_var(12) := '1';
			end if;
			if wadr1 = "1101" and wen1 = '1' then
				regs_var(13) := wdata1;
				valid_var(13) := '1';
			elsif wadr2 = "1101" and wen2 = '1' then
				regs_var(13) := wdata2;
				valid_var(13) := '1';
			end if;
			if wadr1 = "1110" and wen1 = '1' then
				regs_var(14) := wdata1;
				valid_var(14) := '1';
			elsif wadr2 = "1110" and wen2 = '1' then
				regs_var(14) := wdata2;
				valid_var(14) := '1';
			end if;
			if wadr1 = "1111" and wen1 = '1' then
				regs_var(15) := wdata1;
				valid_var(15) := '1';
			elsif wadr2 = "1111" and wen2 = '1' then
				regs_var(15) := wdata2;
				valid_var(15) := '1';
			end if;

			--on invalide les registres
			if (inval_adr1 = "0000" and inval1 = '1') or (inval_adr2 = "0000" and inval2 = '1') then
				valid_var(0) := '0';
			end if;
			if (inval_adr1 = "0001" and inval1 = '1') or (inval_adr2 = "0001" and inval2 = '1') then
				valid_var(1) := '0';
			end if;
			if (inval_adr1 = "0010" and inval1 = '1') or (inval_adr2 = "0010" and inval2 = '1') then
				valid_var(2) := '0';
			end if;
			if (inval_adr1 = "0011" and inval1 = '1') or (inval_adr2 = "0011" and inval2 = '1') then
				valid_var(3) := '0';
			end if;
			if (inval_adr1 = "0100" and inval1 = '1') or (inval_adr2 = "0100" and inval2 = '1') then
				valid_var(4) := '0';
			end if;
			if (inval_adr1 = "0101" and inval1 = '1') or (inval_adr2 = "0101" and inval2 = '1') then
				valid_var(5) := '0';
			end if;
			if (inval_adr1 = "0110" and inval1 = '1') or (inval_adr2 = "0110" and inval2 = '1') then
				valid_var(6) := '0';
			end if;
			if (inval_adr1 = "0111" and inval1 = '1') or (inval_adr2 = "0111" and inval2 = '1') then
				valid_var(7) := '0';
			end if;
			if (inval_adr1 = "1000" and inval1 = '1') or (inval_adr2 = "1000" and inval2 = '1') then
				valid_var(8) := '0';
			end if;
			if (inval_adr1 = "1001" and inval1 = '1') or (inval_adr2 = "1001" and inval2 = '1') then
				valid_var(9) := '0';
			end if;
			if (inval_adr1 = "1010" and inval1 = '1') or (inval_adr2 = "1010" and inval2 = '1') then
				valid_var(10) := '0';
			end if;
			if (inval_adr1 = "1011" and inval1 = '1') or (inval_adr2 = "1011" and inval2 = '1') then
				valid_var(11) := '0';
			end if;
			if (inval_adr1 = "1100" and inval1 = '1') or (inval_adr2 = "1100" and inval2 = '1') then
				valid_var(12) := '0';
			end if;
			if (inval_adr1 = "1101" and inval1 = '1') or (inval_adr2 = "1101" and inval2 = '1') then
				valid_var(13) := '0';
			end if;
			if (inval_adr1 = "1110" and inval1 = '1') or (inval_adr2 = "1110" and inval2 = '1') then
				valid_var(14) := '0';
			end if;
			if (inval_adr1 = "1111" and inval1 = '1') or (inval_adr2 = "1111" and inval2 = '1') then
				valid_var(15) := '0';
			end if;

			--on met les flags à jour
			czn_valid_var := czn_valid;
			ovr_valid_var := ovr_valid;
			if cspr_wb = '1' then
				c <= wcry;
				z <= wzero;
				n <= wneg;
				ovr <= wovr;
				czn_valid_var := '1';
				ovr_valid_var := '1';
			end if;

			if inval_czn = '1' then
				czn_valid_var := '0';
			end if;
			if inval_ovr = '1' then
				ovr_valid_var := '0';
			end if;

			czn_valid <= czn_valid_var;
			ovr_valid <= ovr_valid_var;


			if inc_pc = '1' then
				pc_int := to_integer(unsigned(regs(15)));
				pc_int := pc_int + 4;
				pc_33_bits := std_logic_vector(to_signed(pc_int, 33));
				regs_var(15) := pc_33_bits(31 downto 0);
			end if;

			regs <= regs_var;
			validity_bits <= valid_var;
			--on mappe le PC
			reg_pc <= regs(15);
			reg_pcv <= validity_bits(15);

		end if;
		
	end if;
	end process proc_write;

	--process d'écriture mappe simplement les adresse demandées au registre (avec la validité)
	proc_read : process(radr1, radr2, radr3, c, z, n, ovr, czn_valid, ovr_valid, regs, validity_bits)
	variable index : integer;

	begin 
			--on mappe les sorties du composant avec les registres
			index := to_integer(unsigned(radr1));
			reg_rd1 <= regs(index);
			reg_v1 <= validity_bits(index);
			index := to_integer(unsigned(radr2));
			reg_rd2 <= regs(index);
			reg_v2 <= validity_bits(index);
			index := to_integer(unsigned(radr3));
			reg_rd3 <= regs(index);
			reg_v3 <= validity_bits(index);

			--on mappe les flags
			reg_cry <= c;
			reg_zero <= z;
			reg_neg <= n;
			reg_ovr <= ovr;
			reg_cznv <= czn_valid;
			reg_vv <= ovr_valid;
	end process ;

end Behavior;
