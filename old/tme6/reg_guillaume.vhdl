library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg is
	port(
	-- Write Port 1 prioritaire (origine EXE) Rd
		wdata1		: in Std_Logic_Vector(31 downto 0);
		wadr1		: in Std_Logic_Vector(3 downto 0);
		wen1		: in Std_Logic; -- write enable

	-- Write Port 2 non prioritaire (origine MEM) Rd
		wdata2		: in Std_Logic_Vector(31 downto 0);
		wadr2		: in Std_Logic_Vector(3 downto 0);
		wen2		: in Std_Logic;

	-- Write CSPR Port (origine EXE)
		wcry		: in Std_Logic;
		wzero		: in Std_Logic;
		wneg		: in Std_Logic;
		wovr		: in Std_Logic;
		cspr_wb		: in Std_Logic;
		
	-- Read Port 1 32 bits Rn
		reg_rd1		: out Std_Logic_Vector(31 downto 0);
		radr1		: in Std_Logic_Vector(3 downto 0);
		reg_v1		: out Std_Logic;

	-- Read Port 2 32 bits Rs
		reg_rd2		: out Std_Logic_Vector(31 downto 0);
		radr2		: in Std_Logic_Vector(3 downto 0);
		reg_v2		: out Std_Logic;

	-- Read Port 3 32 bits Rm
		reg_rd3		: out Std_Logic_Vector(31 downto 0);
		radr3		: in Std_Logic_Vector(3 downto 0);
		reg_v3		: out Std_Logic;

	-- read CSPR Port
		reg_cry		: out Std_Logic;
		reg_zero	: out Std_Logic;
		reg_neg		: out Std_Logic;
		reg_cznv	: out Std_Logic; -- CNZ valide
		reg_ovr		: out Std_Logic; -- V
		reg_vv		: out Std_Logic; -- V valide
		
	-- Invalidate Port 
		inval_adr1	: in Std_Logic_Vector(3 downto 0);
		inval1		: in Std_Logic;

		inval_adr2	: in Std_Logic_Vector(3 downto 0);
		inval2		: in Std_Logic;

		inval_czn	: in Std_Logic;
		inval_ovr	: in Std_Logic;

	-- PC
		reg_pc		: out Std_Logic_Vector(31 downto 0);
		reg_pcv		: out Std_Logic;
		inc_pc		: in Std_Logic;
	
	-- global interface
		ck			: in Std_Logic;
		reset_n		: in Std_Logic;
		vdd			: in bit;
		vss			: in bit);
end Reg;

architecture Behavior OF Reg is

	component Add32b
		port(
			A : in Std_Logic_Vector(31 downto 0);
			B : in Std_Logic_Vector(31 downto 0);
			cin		: in Std_Logic;
			cout	: out Std_Logic;
			S : out Std_Logic_Vector(31 downto 0)
		);
	end component;

	--type reg_array is array(15 downto 0) of std_logic_vector(31 downto 0);
	--signal regs : reg_array;
	signal regs : std_logic_vector(511 downto 0);


	signal reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15 : std_logic_vector(31 downto 0);
	signal regs_valide : std_logic_vector(15 downto 0);
	
	-- 0 C (flags_valide[0])
	-- 1 N
	-- 2 Z
	-- 3 V (flags_valide[1])
	signal flags : std_logic_vector(3 downto 0);
	signal flags_valide : std_logic_vector(1 downto 0);

	signal pc_upd : std_logic_vector(31 downto 0);





	signal const_on : std_logic := '1';

	
	function r_reg(adr : std_logic_vector(3 downto 0);
								 preg0, preg1, preg2, preg3, preg4, preg5, preg6, preg7, preg8, preg9, preg10, preg11, preg12, preg13, preg14, preg15 : std_logic_vector(31 downto 0))
								 --reg_a : std_logic_vector(511 downto 0))---reg_array)
		return std_logic_vector is
		variable res : std_logic_vector(31 downto 0);
	begin
		case adr is
			when x"0" =>
				res := preg0;
			when x"1" =>
				res := preg1;--reg_a(63 downto 32);--reg_a(1);
			when x"2" =>
				res := preg2;--reg_a(95 downto 64);--reg_a(2);
			when x"3" =>
				res := preg3;--reg_a(127 downto 96);--reg_a(3);
			when x"4" =>
				res := preg4;--reg_a(159 downto 128);--reg_a(4);
			when x"5" =>
				res := preg5;--reg_a(191 downto 160);--reg_a(5);
			when x"6" =>
				res := preg6;--reg_a(223 downto 192);--reg_a(6);
			when x"7" =>
				res := preg7;--reg_a(255 downto 224);--reg_a(7);
			when x"8" =>
				res := preg8;--reg_a(287 downto 256);--reg_a(8);
			when x"9" =>
				res := preg9;--reg_a(319 downto 288);--reg_a(9);
			when x"A" =>
				res := preg10;--reg_a(351 downto 320);--reg_a(10);
			when x"B" =>
				res := preg11;--reg_a(383 downto 352);--reg_a(11);
			when x"C" =>
				res := preg12;--reg_a(415 downto 384);--reg_a(12);
			when x"D" =>
				res := preg13;--reg_a(447 downto 416);--reg_a(13);
			when x"E" =>
				res := preg14;--reg_a(479 downto 448);--reg_a(14);
			when x"F" =>
				res := preg15;--reg_a(511 downto 480);--reg_a(15);
			when others =>
				res := "UUUUUUUU" & "UUUUUUUU" & "UUUUUUUU" & "UUUUUUUU";
		end case;
		return res;
	end function;	
			
	function r_regv(adr : std_logic_vector(3 downto 0);
									reg_valide : std_logic_vector(15 downto 0))
		return std_logic is
		variable res : std_logic;
	begin
		case adr is
			when x"0" =>
				res := reg_valide(0);
			when x"1" =>
				res := reg_valide(1);
			when x"2" =>
				res := reg_valide(2);
			when x"3" =>
				res := reg_valide(3);
			when x"4" =>
				res := reg_valide(4);
			when x"5" =>
				res := reg_valide(5);
			when x"6" =>
				res := reg_valide(6);
			when x"7" =>
				res := reg_valide(7);
			when x"8" =>
				res := reg_valide(8);
			when x"9" =>
				res := reg_valide(9);
			when x"A" =>
				res := reg_valide(10);
			when x"B" =>
				res := reg_valide(11);
			when x"C" =>
				res := reg_valide(12);
			when x"D" =>
				res := reg_valide(13);
			when x"E" =>
				res := reg_valide(14);
			when x"F" =>
				res := reg_valide(15);
			when others =>
				res := 'U';
		end case;
		return res;
	end function;
	
	procedure w_reg(signal adr : in std_logic_vector(3 downto 0);
									signal val : in std_logic_vector(31 downto 0);
									signal preg0, preg1, preg2, preg3, preg4, preg5, preg6, preg7, preg8, preg9, preg10, preg11, preg12, preg13, preg14, preg15 : inout std_logic_vector(31 downto 0)) is
									--signal reg_a : inout std_logic_vector(511 downto 0)) is---reg_array) is
	begin
		case adr is
			when x"0" =>
				preg0 <= val;
			when x"1" =>
				preg1 <= val;
			when x"2" =>
				preg2 <= val;
			when x"3" =>
				preg3 <= val;
			when x"4" =>
				preg4 <= val;
			when x"5" =>
				preg5 <= val;
			when x"6" =>
				preg6 <= val;
			when x"7" =>
				preg7 <= val;
			when x"8" =>
				preg8 <= val;
			when x"9" =>
				preg9 <= val;
			when x"A" =>
				preg10 <= val;
			when x"B" =>
				preg11 <= val;
			when x"C" =>
				preg12 <= val;
			when x"D" =>
				preg13 <= val;
			when x"E" =>
				preg14 <= val;
			when x"F" =>
				preg15 <= val;
			when others =>
		end case;

		-- case adr is
		-- 	when x"0" =>
		-- 		reg_a(31 downto 0) <= val;
		-- 	when x"1" =>
		-- 		reg_a(63 downto 32) <= val;
		-- 	when x"2" =>
		-- 		reg_a(95 downto 64) <= val;
		-- 	when x"3" =>
		-- 		reg_a(127 downto 96) <= val;
		-- 	when x"4" =>
		-- 		reg_a(159 downto 128) <= val;
		-- 	when x"5" =>
		-- 		reg_a(191 downto 160) <= val;
		-- 	when x"6" =>
		-- 		reg_a(223 downto 192) <= val;
		-- 	when x"7" =>
		-- 		reg_a(255 downto 224) <= val;
		-- 	when x"8" =>
		-- 		reg_a(287 downto 256) <= val;
		-- 	when x"9" =>
		-- 		reg_a(319 downto 288) <= val;
		-- 	when x"A" =>
		-- 		reg_a(351 downto 320) <= val;
		-- 	when x"B" =>
		-- 		reg_a(383 downto 352) <= val;
		-- 	when x"C" =>
		-- 		reg_a(415 downto 384) <= val;
		-- 	when x"D" =>
		-- 		reg_a(447 downto 416) <= val;
		-- 	when x"E" =>
		-- 		reg_a(479 downto 448) <= val;
		-- 	when x"F" =>
		-- 		reg_a(511 downto 480) <= val;
		-- 	when others =>
		-- end case;
	end procedure;	
			
	procedure w_regv(signal adr : in std_logic_vector(3 downto 0);
									 signal val : in std_logic;
									 signal reg_valide : inout std_logic_vector(15 downto 0);
									 constant inverse : in boolean) is
		variable tmp : std_logic;
	begin
		if inverse then
			tmp := not val;
		else
			tmp := val;
		end if;
		case adr is
			when x"0" =>
				reg_valide(0) <= tmp;
			when x"1" =>
				reg_valide(1) <= tmp;
			when x"2" =>
				reg_valide(2) <= tmp;
			when x"3" =>
				reg_valide(3) <= tmp;
			when x"4" =>
				reg_valide(4) <= tmp;
			when x"5" =>
				reg_valide(5) <= tmp;
			when x"6" =>
				reg_valide(6) <= tmp;
			when x"7" =>
				reg_valide(7) <= tmp;
			when x"8" =>
				reg_valide(8) <= tmp;
			when x"9" =>
				reg_valide(9) <= tmp;
			when x"A" =>
				reg_valide(10) <= tmp;
			when x"B" =>
				reg_valide(11) <= tmp;
			when x"C" =>
				reg_valide(12) <= tmp;
			when x"D" =>
				reg_valide(13) <= tmp;
			when x"E" =>
				reg_valide(14) <= tmp;
			when x"F" =>
				reg_valide(15) <= tmp;
			when others =>
		end case;
	end procedure;
	

	
begin

	
	process( ck, reset_n )

	begin
		if reset_n = '0' then
			reg0 <= (others => '0');
			reg1 <= (others => '0');
			reg2 <= (others => '0');
			reg3 <= (others => '0');
			reg4 <= (others => '0');
			reg5 <= (others => '0');
			reg6 <= (others => '0');
			reg7 <= (others => '0');
			reg8 <= (others => '0');
			reg9 <= (others => '0');
			reg10 <= (others => '0');
			reg11 <= (others => '0');
			reg12 <= (others => '0');
			reg13 <= (others => '0');
			reg14 <= (others => '0');
			reg15 <= (others => '0');
			--regs <= (others => '0');
			regs_valide <= (others => '1');
			-- for i in 0 to 15 loop
			-- 	regs(i) <= x"00000000";
			-- 	regs_valide(i) <= '1';
			-- end loop;
			flags <= "0000";
			flags_valide <= "11";
		elsif rising_edge(ck) then
			--- PC
			if regs_valide(15) = '0' then
				if wen1 = '1' and wadr1 = "1111" then
					reg15 <= wdata1;
				elsif wen2 = '1' and wadr2 = "1111" then
					reg15 <= wdata2;
				end if;
			elsif inc_pc = '1' then
				reg15 <= pc_upd;
			end if;
			
			--- écriture registre destination
			if wen1 = '1' and r_regv(wadr1, regs_valide) = '0' then
				w_regv(wadr1, const_on, regs_valide, false);
				w_reg(wadr1, wdata1, reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15);
			end if;	
			if wen2 = '1' and wadr1 /= wadr2 and r_regv(wadr2, regs_valide) = '0' then
				w_regv(wadr2, const_on, regs_valide, false);
				w_reg(wadr2, wdata2, reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15);
			end if;	

			--- écriture des flags			
			if flags_valide(0) = '0' and cspr_wb = '1' then
				flags(0) <= wcry;
				flags(1) <= wzero;
				flags(2) <= wneg;
				flags_valide(0) <= '1';
			end if;
			if flags_valide(1) = '0' and cspr_wb = '1' then
				flags(3) <= wovr;
				flags_valide(1) <= '1';
			end if;

			
			--- Invalidation des ports
			w_regv(inval_adr1, inval1, regs_valide, true);
			w_regv(inval_adr2, inval2, regs_valide, true);
			flags_valide(0) <= not inval_czn;
			flags_valide(1) <= not inval_ovr;
						
			
		end if;
	end process;


	
	
	--- Lecture registre Source
	reg_rd1 <= r_reg(radr1, reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15);
	reg_v1 <= r_regv(radr1, regs_valide);
	reg_rd2 <= r_reg(radr2, reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15);
	reg_v2 <= r_regv(radr2, regs_valide);
	reg_rd3 <= r_reg(radr3, reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15);
	reg_v3 <= r_regv(radr3, regs_valide);

	--- Lecture flags
	reg_cry <= flags(0);
	reg_zero <= flags(1);
	reg_neg <= flags(2);
	reg_cznv <= flags_valide(0);
	reg_ovr <= flags(3);
	reg_vv <= flags_valide(1);

	--- Lecture PC
	reg_pc <= reg15;
	reg_pcv <= regs_valide(15);
	



	--- PC updater
	pc_adder : Add32b
		port map(
			A => reg15,
			B => x"00000004",
			cin => '0',
			cout => open,
			S => pc_upd
		);
	


end Behavior;