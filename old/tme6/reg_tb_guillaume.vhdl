library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--library work;

entity reg_tb is
end reg_tb;

architecture sim of reg_tb is

	component Reg
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
	end component Reg;

	constant period : time := 100 ns;
	signal valide : std_logic := '1';

	signal data_in_1, data_in_2 : std_logic_vector(31 downto 0) := x"00000000";
	signal addr_in_1, addr_in_2 : std_logic_vector(3 downto 0) := "0000";
	signal w_en_1, w_en_2 : std_logic := '0';

	signal wcry, wzero, wneg, wovr, cspr_wb : std_logic;
	signal cry, zero, neg, ovr, czn_val, ovr_val : std_logic;

	signal data_out_1, data_out_2, data_out_3 : std_logic_vector(31 downto 0);
	signal addr_out_1, addr_out_2, addr_out_3 : std_logic_vector(3 downto 0) := "0000";
	signal val_out_1, val_out_2, val_out_3 : std_logic;

	signal inval_1, inval_2 : std_logic := '0';
	signal inval_addr_1, inval_addr_2 : std_logic_vector(3 downto 0) := "0000";

	signal inval_czn, inval_ovr : std_logic;

	signal pc : std_logic_vector(31 downto 0) := x"00000000";
	signal pc_val : std_logic;
	signal inc_pc : std_logic := '0';

	signal ck : std_logic := '0';
	signal reset_n : std_logic := '0';

	signal wover : std_logic;

	
	
begin
	reg_0 : Reg
		port map (
			-- Write Port 1 prioritaire (origine EXE) Rd
			wdata1 => data_in_1, 
			wadr1 => addr_in_1,
			wen1 => w_en_1, -- write enable

			-- Write Port 2 non prioritaire (origine MEM) Rd
			wdata2 => data_in_2,
			wadr2 => addr_in_2,
			wen2 => w_en_2,

			-- Write CSPR Port (origine EXE)
			wcry => wcry,
			wzero => wzero,
			wneg => wneg,
			wovr => wover,
			cspr_wb	=> cspr_wb,
			
			-- Read Port 1 32 bits Rn
			reg_rd1 => data_out_1,
			radr1 => addr_out_1,
			reg_v1 => val_out_1,

			-- Read Port 2 32 bits Rs
			reg_rd2 => data_out_2,
			radr2 => addr_out_2,
			reg_v2 => val_out_2,
			
			-- Read Port 3 32 bits Rm
			reg_rd3 => data_out_3,
			radr3 => addr_out_3,
			reg_v3 => val_out_3,

			-- read CSPR Port
			reg_cry => cry,
			reg_zero => zero,
			reg_neg => neg,
			reg_cznv => czn_val, -- CNZ valide
			reg_ovr => ovr, -- V
			reg_vv => ovr_val, -- V valide
			
			-- Invalidate Port 
			inval_adr1 => inval_addr_1,
			inval1 => inval_1,
 
			inval_adr2 => inval_addr_2,
			inval2 => inval_2,

			inval_czn => inval_czn,
			inval_ovr =>inval_ovr,

			-- PC
			reg_pc => pc,
			reg_pcv => pc_val,
			inc_pc => inc_pc,
			
			-- global interface
			ck => ck,
			reset_n => reset_n,
			vdd => '1',
			vss => '0'
		);
	ck <= not ck after period/2 when valide = '1' else '0';

	
	process
	begin

		report "start of test";

		wait until rising_edge(ck);
		reset_n <= '1';
		addr_out_1 <= "0000";
		addr_out_2 <= "0001";
		addr_out_3 <= "0010";

		--write 16 in reg 1 and 17 in reg 2
		
		data_in_1 <= x"00000010";
		addr_in_1 <= "0000";
		w_en_1 <= '1';
		data_in_2 <= x"00000011";
		addr_in_2 <= "0001";
		w_en_2 <= '1';

		wait on data_in_1 ;

		report "setting stuf idk" ; 

		--set flags to their default values
		wcry <= '1';
		wzero <= '1';
		wneg <= '1';
		wovr <= '1';
		cspr_wb <= '1';

		--wait for the write to be done
		wait until rising_edge(ck);

		wait for period;

		--report the read values
		report "reg 1 = " & integer'image(to_integer(unsigned(data_out_1)));
		report "reg 2 = " & integer'image(to_integer(unsigned(data_out_2)));

	end process;
end sim;
