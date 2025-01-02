library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Decod is
	port(
	-- Exec  operands
			dec_op1			: out Std_Logic_Vector(31 downto 0); -- first alu input
			dec_op2			: out Std_Logic_Vector(31 downto 0); -- shifter input
			dec_exe_dest	: out Std_Logic_Vector(3 downto 0); -- Rd destination
			dec_exe_wb		: out Std_Logic; -- Rd destination write back
			dec_flag_wb		: out Std_Logic; -- CSPR modifiy

	-- Decod to mem via exec
			dec_mem_data	: out Std_Logic_Vector(31 downto 0); -- data to MEM
			dec_mem_dest	: out Std_Logic_Vector(3 downto 0);
			dec_pre_index 	: out Std_logic;

			dec_mem_lw		: out Std_Logic;
			dec_mem_lb		: out Std_Logic;
			dec_mem_sw		: out Std_Logic;
			dec_mem_sb		: out Std_Logic;

	-- Shifter command
			dec_shift_lsl	: out Std_Logic;
			dec_shift_lsr	: out Std_Logic;
			dec_shift_asr	: out Std_Logic;
			dec_shift_ror	: out Std_Logic;
			dec_shift_rrx	: out Std_Logic;
			dec_shift_val	: out Std_Logic_Vector(4 downto 0);
			dec_cy			: out Std_Logic;

	-- Alu operand selection
			dec_comp_op1	: out Std_Logic;
			dec_comp_op2	: out Std_Logic;
			dec_alu_cy 		: out Std_Logic;

	-- Exec Synchro
			dec2exe_empty	: out Std_Logic;
			exe_pop			: in Std_logic;

	-- Alu command
			dec_alu_cmd		: out Std_Logic_Vector(1 downto 0);

	-- Exe Write Back to reg
			exe_res			: in Std_Logic_Vector(31 downto 0);

			exe_c				: in Std_Logic;
			exe_v				: in Std_Logic;
			exe_n				: in Std_Logic;
			exe_z				: in Std_Logic;

			exe_dest			: in Std_Logic_Vector(3 downto 0); -- Rd destination
			exe_wb			: in Std_Logic; -- Rd destination write back
			exe_flag_wb		: in Std_Logic; -- CSPR modifiy

	-- Ifetch interface
			dec_pc			: out Std_Logic_Vector(31 downto 0) ;
			if_ir				: in Std_Logic_Vector(31 downto 0) ;

	-- Ifetch synchro
			dec2if_empty	: out Std_Logic;
			if_pop			: in Std_Logic;

			if2dec_empty	: in Std_Logic;
			dec_pop			: out Std_Logic;

	-- Mem Write back to reg
			mem_res			: in Std_Logic_Vector(31 downto 0);
			mem_dest			: in Std_Logic_Vector(3 downto 0);
			mem_wb			: in Std_Logic;
			
	-- global interface
			ck					: in Std_Logic;
			reset_n			: in Std_Logic;
			vdd				: in bit;
			vss				: in bit);
end Decod;

----------------------------------------------------------------------

architecture Behavior OF Decod is

component reg
	port(
	-- Write Port 1 prioritaire
		wdata1		: in Std_Logic_Vector(31 downto 0);
		wadr1			: in Std_Logic_Vector(3 downto 0);
		wen1			: in Std_Logic;

	-- Write Port 2 non prioritaire
		wdata2		: in Std_Logic_Vector(31 downto 0);
		wadr2			: in Std_Logic_Vector(3 downto 0);
		wen2			: in Std_Logic;

	-- Write CSPR Port
		wcry			: in Std_Logic;
		wzero			: in Std_Logic;
		wneg			: in Std_Logic;
		wovr			: in Std_Logic;
		cspr_wb		: in Std_Logic;
		
	-- Read Port 1 32 bits
		reg_rd1		: out Std_Logic_Vector(31 downto 0);
		radr1			: in Std_Logic_Vector(3 downto 0);
		reg_v1		: out Std_Logic;

	-- Read Port 2 32 bits
		reg_rd2		: out Std_Logic_Vector(31 downto 0);
		radr2			: in Std_Logic_Vector(3 downto 0);
		reg_v2		: out Std_Logic;

	-- Read Port 3 32 bits
		reg_rd3		: out Std_Logic_Vector(31 downto 0);
		radr3			: in Std_Logic_Vector(3 downto 0);
		reg_v3		: out Std_Logic;

	-- read CSPR Port
		reg_cry		: out Std_Logic;
		reg_zero		: out Std_Logic;
		reg_neg		: out Std_Logic;
		reg_cznv		: out Std_Logic;
		reg_ovr		: out Std_Logic;
		reg_vv		: out Std_Logic;
		
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
		ck				: in Std_Logic;
		reset_n		: in Std_Logic;
		vdd			: in bit;
		vss			: in bit);
end component;

component fifo_127b
	port(
		din		: in std_logic_vector(126 downto 0);
		dout		: out std_logic_vector(126 downto 0);

		-- commands
		push		: in std_logic;
		pop		: in std_logic;

		-- flags
		full		: out std_logic;
		empty		: out std_logic;

		reset_n	: in std_logic;
		ck			: in std_logic;
		vdd		: in bit;
		vss		: in bit
	);
end component;

component fifo_32b
	port(
		din		: in std_logic_vector(31 downto 0);
		dout		: out std_logic_vector(31 downto 0);

		-- commands
		push		: in std_logic;
		pop		: in std_logic;

		-- flags
		full		: out std_logic;
		empty		: out std_logic;

		reset_n	: in std_logic;
		ck			: in std_logic;
		vdd		: in bit;
		vss		: in bit
	);
end component;

signal cond		: Std_Logic; --prédicat vrai ? 
signal condv	: Std_Logic; --validité de la condition
signal operv	: Std_Logic;

signal regop_t  : Std_Logic; --instruction de traitement de données? 
signal mult_t   : Std_Logic; --instruction de multiplication?
signal swap_t   : Std_Logic; --swap entre 1 registre et 1 adresse (load + store)
signal trans_t  : Std_Logic; --transfert mémoire simple
signal mtrans_t : Std_Logic; --transfert mémoire multiple
signal branch_t : Std_Logic; --branchement

-- regop instructions
signal and_i  : Std_Logic;
signal eor_i  : Std_Logic;
signal sub_i  : Std_Logic;
signal rsb_i  : Std_Logic;
signal add_i  : Std_Logic;
signal adc_i  : Std_Logic;
signal sbc_i  : Std_Logic;
signal rsc_i  : Std_Logic;
signal tst_i  : Std_Logic;
signal teq_i  : Std_Logic;
signal cmp_i  : Std_Logic;
signal cmn_i  : Std_Logic;
signal orr_i  : Std_Logic;
signal mov_i  : Std_Logic;
signal bic_i  : Std_Logic;
signal mvn_i  : Std_Logic;

-- mult instruction
signal mul_i  : Std_Logic;
signal mla_i  : Std_Logic;

-- trans instruction
signal ldr_i  : Std_Logic;
signal str_i  : Std_Logic;
signal ldrb_i : Std_Logic;
signal strb_i : Std_Logic;

-- mtrans instruction
signal ldm_i  : Std_Logic;
signal stm_i  : Std_Logic;

-- branch instruction
signal b_i    : Std_Logic;
signal bl_i   : Std_Logic;

-- link
signal blink    : Std_Logic;

-- Multiple transferts
signal mtrans_shift : Std_Logic; --mtrans pas implémenté 

signal mtrans_mask_shift : Std_Logic_Vector(15 downto 0); 
signal mtrans_mask : Std_Logic_Vector(15 downto 0);
signal mtrans_list : Std_Logic_Vector(15 downto 0);
signal mtrans_1un : Std_Logic;
signal mtrans_loop_adr : Std_Logic;
signal mtrans_nbr : Std_Logic_Vector(4 downto 0);
signal mtrans_rd : Std_Logic_Vector(3 downto 0);

-- RF read ports
signal radr1 : Std_Logic_Vector(3 downto 0);
signal rdata1 : Std_Logic_Vector(31 downto 0);
signal rvalid1 : Std_Logic;

signal radr2 : Std_Logic_Vector(3 downto 0);
signal rdata2 : Std_Logic_Vector(31 downto 0);
signal rvalid2 : Std_Logic;

signal radr3 : Std_Logic_Vector(3 downto 0);
signal rdata3 : Std_Logic_Vector(31 downto 0);
signal rvalid3 : Std_Logic;

-- RF inval ports
signal inval_exe_adr : Std_Logic_Vector(3 downto 0);
signal inval_exe : Std_Logic;

signal inval_mem_adr : Std_Logic_Vector(3 downto 0);
signal inval_mem : Std_Logic;

-- Flags
signal cry	: Std_Logic;
signal zero	: Std_Logic;
signal neg	: Std_Logic;
signal ovr	: Std_Logic;

signal reg_cznv : Std_Logic;
signal reg_vv : Std_Logic;

signal inval_czn : Std_Logic;
signal inval_ovr : Std_Logic;

-- PC
signal reg_pc : Std_Logic_Vector(31 downto 0);
signal reg_pcv : Std_Logic;
signal inc_pc : Std_Logic;

-- FIFOs
signal dec2if_full : Std_Logic;
signal dec2if_push : Std_Logic;

signal dec2exe_full : Std_Logic;
signal dec2exe_push : Std_Logic;

signal if2dec_pop : Std_Logic;

-- Exec  operands
signal op1			: Std_Logic_Vector(31 downto 0);
signal op2			: Std_Logic_Vector(31 downto 0);
signal alu_dest	: Std_Logic_Vector(3 downto 0);
signal alu_wb		: Std_Logic;
signal flag_wb		: Std_Logic;

signal offset32	: Std_Logic_Vector(31 downto 0);

-- Decod to mem via exec
signal mem_data	: Std_Logic_Vector(31 downto 0);--??
signal ld_dest		: Std_Logic_Vector(3 downto 0);
signal pre_index 	: Std_logic;

signal mem_lw		: Std_Logic;
signal mem_lb		: Std_Logic;
signal mem_sw		: Std_Logic;
signal mem_sb		: Std_Logic;

-- Shifter command
signal shift_lsl	: Std_Logic;
signal shift_lsr	: Std_Logic;
signal shift_asr	: Std_Logic;
signal shift_ror	: Std_Logic;
signal shift_rrx	: Std_Logic;
signal shift_val	: Std_Logic_Vector(4 downto 0);
signal cy			: Std_Logic;

-- Alu operand selection
signal comp_op1	: Std_Logic; --complémentaire pour op1 
signal comp_op2	: Std_Logic; --complémentaire pr op2 
signal alu_cy 	: Std_Logic; --valeur du carry?

-- Alu command
signal alu_cmd		: Std_Logic_Vector(1 downto 0);

-- DECOD FSM

type state_type is (FETCH, RUN, BRANCH, LINK, MTRANS);
signal cur_state, next_state : state_type;


signal debug_state : Std_Logic_Vector(3 downto 0) := X"0";

begin

	dec2exec : fifo_127b
	port map (	din(126) => pre_index,
					din(125 downto 94) => op1,
					din(93 downto 62)	 => op2,
					din(61 downto 58)	 => alu_dest,
					din(57)	 => alu_wb,
					din(56)	 => flag_wb,

					din(55 downto 24)	 => rdata3,
					din(23 downto 20)	 => ld_dest,
					din(19)	 => mem_lw,
					din(18)	 => mem_lb,
					din(17)	 => mem_sw,
					din(16)	 => mem_sb,

					din(15)	 => shift_lsl,
					din(14)	 => shift_lsr,
					din(13)	 => shift_asr,
					din(12)	 => shift_ror,
					din(11)	 => shift_rrx,
					din(10 downto 6)	 => shift_val,
					din(5)	 => cry,

					din(4)	 => comp_op1,
					din(3)	 => comp_op2,
					din(2)	 => alu_cy,

					din(1 downto 0)	 => alu_cmd,

					dout(126)	 => dec_pre_index,
					dout(125 downto 94)	 => dec_op1,
					dout(93 downto 62)	 => dec_op2,
					dout(61 downto 58)	 => dec_exe_dest,
					dout(57)	 => dec_exe_wb,
					dout(56)	 => dec_flag_wb,

					dout(55 downto 24)	 => dec_mem_data,
					dout(23 downto 20)	 => dec_mem_dest,
					dout(19)	 => dec_mem_lw,
					dout(18)	 => dec_mem_lb,
					dout(17)	 => dec_mem_sw,
					dout(16)	 => dec_mem_sb,

					dout(15)	 => dec_shift_lsl,
					dout(14)	 => dec_shift_lsr,
					dout(13)	 => dec_shift_asr,
					dout(12)	 => dec_shift_ror,
					dout(11)	 => dec_shift_rrx,
					dout(10 downto 6)	 => dec_shift_val,
					dout(5)	 => dec_cy,

					dout(4)	 => dec_comp_op1,
					dout(3)	 => dec_comp_op2,
					dout(2)	 => dec_alu_cy,

					dout(1 downto 0)	 => dec_alu_cmd,

					push		 => dec2exe_push,
					pop		 => exe_pop,

					empty		 => dec2exe_empty,
					full		 => dec2exe_full,

					reset_n	 => reset_n,
					ck			 => ck,
					vdd		 => vdd,
					vss		 => vss);

	dec2if : fifo_32b
	port map (	din	=> reg_pc,
					dout	=> dec_pc,

					push		 => dec2if_push,
					pop		 => if_pop,

					empty		 => dec2if_empty,
					full		 => dec2if_full,

					reset_n	 => reset_n,
					ck			 => ck,
					vdd		 => vdd,
					vss		 => vss);

	reg_inst  : reg
	port map(	wdata1		=> exe_res,
					wadr1			=> exe_dest,
					wen1			=> exe_wb,
                                          
					wdata2		=> mem_res,
					wadr2			=> mem_dest,
					wen2			=> mem_wb,
                                          
					wcry			=> exe_c,
					wzero			=> exe_z,
					wneg			=> exe_n,
					wovr			=> exe_v,
					cspr_wb		=> exe_flag_wb,
					               
					reg_rd1		=> rdata1,
					radr1			=> radr1,
					reg_v1		=> rvalid1,
                                          
					reg_rd2		=> rdata2,
					radr2			=> radr2,
					reg_v2		=> rvalid2,
                                          
					reg_rd3		=> rdata3,
					radr3			=> radr3,
					reg_v3		=> rvalid3,
                                          
					reg_cry		=> cry,
					reg_zero		=> zero,
					reg_neg		=> neg,
					reg_ovr		=> ovr,
					               
					reg_cznv		=> reg_cznv,
					reg_vv		=> reg_vv,
                                          
					inval_adr1	=> inval_exe_adr,
					inval1		=> inval_exe,
                                          
					inval_adr2	=> inval_mem_adr,
					inval2		=> inval_mem,
                                          
					inval_czn	=> inval_czn,
					inval_ovr	=> inval_ovr,
                                          
					reg_pc		=> reg_pc,
					reg_pcv		=> reg_pcv,
					inc_pc		=> inc_pc,
				                              
					ck				=> ck,
					reset_n		=> reset_n,
					vdd			=> vdd,
					vss			=> vss);

-- Execution condition
	--test explicite de chaque prédicat possible
	cond <= '1' when	(if_ir(31 downto 28) = X"0" and zero = '1') or
						(if_ir(31 downto 28) = X"1" and zero = '0') or
						(if_ir(31 downto 28) = X"2" and cry = '1') 	or
						(if_ir(31 downto 28) = X"3" and cry = '0')	or
						(if_ir(31 downto 28) = X"4" and neg = '1')	or
						(if_ir(31 downto 28) = X"5" and neg = '0')	or
						(if_ir(31 downto 28) = X"6" and ovr = '1')	or
						(if_ir(31 downto 28) = X"7" and ovr ='0')	or
						(if_ir(31 downto 28) = X"8" and (cry ='1' and zero = '0')) 	or
						(if_ir(31 downto 28) = X"9" and (cry = '0' or zero ='1')) 	or
						(if_ir(31 downto 28) = X"A" and (neg = '0' or zero ='1') and ovr = '0') 	or
						(if_ir(31 downto 28) = X"B" and neg = '1' and zero ='0' and ovr = '0')		or
						(if_ir(31 downto 28) = X"C" and neg ='0' and zero ='0' and ovr = '0')		or
						(if_ir(31 downto 28) = X"D" and (neg = '1' or zero ='1') and ovr = '0')		or
						(if_ir(31 downto 28) = X"A" and neg = '0' and ovr = '1') 					or
						(if_ir(31 downto 28) = X"B" and (neg = '1' or zero = '1') and ovr = '1')	or
						(if_ir(31 downto 28) = X"C" and neg ='0' and ovr = '1')						or
						(if_ir(31 downto 28) = X"D" and (neg = '1' or zero = '1') and ovr = '1')	or
						(if_ir(31 downto 28) = X"E") else '0';

	--vérifie la validité de la condition à l'aide de la validité des flags cznv 
	condv <= '1' when if_ir(31 downto 28) = X"E" or
							(reg_cznv = '1'	and (  --dépend de la validité des flags neg/cry/zero
											(if_ir(31 downto 28) = X"0") 	or
											(if_ir(31 downto 28) = X"0" ) 	or
											(if_ir(31 downto 28) = X"1" ) 	or 
											(if_ir(31 downto 28) = X"2" ) 	or
											(if_ir(31 downto 28) = X"3" ) 	or
											(if_ir(31 downto 28) = X"4" ) 	or
											(if_ir(31 downto 28) = X"5" ) 	or
											(if_ir(31 downto 28) = X"8" ) 	or
											(if_ir(31 downto 28) = X"9" )
											)) or
							--dépend de la validité du flag d'overflow
							(reg_vv = '1'  and ((if_ir(31 downto 28) = X"6" and ovr = '1')	or
												(if_ir(31 downto 28) = X"7" and ovr ='0')))
							else (reg_cznv and reg_vv) ;	



-- decod instruction type

	--on place swap ou mult avant regop pour éviter les conflits ? (pb à cause du délai des affectations signaux ?)
	mult_t <= '1' when	if_ir(27 downto 22) = "000000" and
				if_ir(7 downto 4) = "1001" else '0';
	swap_t <= '1' when	if_ir(27 downto 23) = "00010" and
				if_ir(11 downto 4) = "00001001" else '0';

	regop_t <= '1' when	if_ir(27 downto 26) = "00" and --regop si prédicat 00 et pas préfixe de swap ou mult
				mult_t = '0' and swap_t = '0' else '0';
	
	mtrans_t 	<= '1' when if_ir(27 downto 25) = 	"100" else '0';
	branch_t 	<= '1' when if_ir(27 downto 25) =	"101" else '0';

-- decod regop opcode

	--teste chaque opcode 1 par 1 pour voir quelle instruction est demandée
	and_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"0" else '0';
	eor_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"1" else '0';
	sub_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"2" else '0';
	rsb_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"3" else '0';
	add_i <= '1' when (regop_t = '1' and if_ir(24 downto 21) = X"4" ) 
			  	or (branch_t = '1')  else '0'; -- branch_t met add à 1 car pc doit être additionné à l'offset
	adc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"5" else '0';
	sbc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"6" else '0';
	rsc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"7" else '0';
	tst_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"8" else '0';
	teq_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"9" else '0';
	cmp_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"A" else '0';
	cmn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"B" else '0';
	orr_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"C" else '0';
	mov_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"D" else '0';
	bic_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"E" else '0';
	mvn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"F" else '0';

-- mult instruction

	mul_i <= '1' when mult_t = '1' and if_ir(21) = '0' else '0' ; 
	mla_i <= '1' when mult_t = '1' and if_ir(21) = '1' else '0' ; 

-- trans instruction

	--t3_run = 1 si le prédicat est vrai et que l'instruction doit être executée 
	--bit 20 : load/store , bit 22 : byte/word
	ldr_i 	<= '1'when trans_t ='1' and if_ir(20) = '1' and if_ir(22) = '0'
				else '0';
	str_i 	<= '1' when trans_t ='1' and if_ir(20) = '0' and if_ir(22) = '0'
				else '0' ;
	ldrb_i 	<= '1' when trans_t ='1' and if_ir(20) = '1' and if_ir(22) = '1'
				else '0';
	strb_i 	<= '1' when trans_t ='1' and if_ir(20) = '0' and if_ir(22) = '1'
				else '0';

-- mtrans instruction

	ldm_i  <= '1' when mtrans_t = '1' and if_ir(20) = '1' else '0'; 
	stm_i <= '1' when mtrans_t = '1' and if_ir(20) = '0' else '0' ;
-- branch instruction

	bl_i 	<= '1' when if_ir(24) = '1' and branch_t ='1' else '0'; 
	b_i 	<= '1' when if_ir(24) = '0' and branch_t ='1' else '0';

-- Decode interface operands
	op1 <=	 reg_pc	when branch_t = '1' and blink = '0' else --pc quand branch sans link
			 x"00000000" when regop_t = '1' and (mov_i = '1' or mvn_i = '1') else --000 quand "reçoit" d'un move
			 rdata1;--contenu de data 1 sinon

	offset32 <=	(31 downto 26 => if_ir(23)) & if_ir(23 downto 0) & "00"; --multiplie offset par 4 et le transforme sur 
	--32 bits depuis 23

	op2	<=   x"00000004" when branch_t = '1' and blink = '1' else --si b&l on ajoute 4 au résultat pour prendre la prochaine instr
			 offset32 	when branch_t = '1' else --branch | b&l ajoute l'offset
			 x"fffffffc" when mtrans_t = '1' and if_ir(23) = '0' else --soustrait offset (-4) si 'U'=0 
			 x"00000004" when mtrans_t = '1' and if_ir(23) = '1' else --ajoute 4 sinon 
			 (31 downto 12 => '0') & if_ir(11 downto 0) when trans_t = '1' and if_ir(25) = '0' else
			  --transfert simple, si 'I' = 1 l'offset est stocké dans les 12 lsb comme un immédiat
			 (31 downto 8 => '0') & if_ir(7 downto 0) when regop_t = '1' and if_ir(25) = '1' else 
			 --traitement de données, si 'I' = 1 l'op2 est un immédiat
			 rdata2;

	alu_dest <= "1110" when branch_t = '1' and blink = '1' else --registre 14 (link register) si branch and link
				"1111" when branch_t = '1' else --pc si branch
				if_ir(19 downto 16)	when mult_t  = '1' else --Rn dans mult
				if_ir(19 downto 16) when trans_t = '1' else --Rn dans trans
				if_ir(15 downto 12); --Rn dans regop

	alu_wb	<= '1' when ((regop_t = '1' and (tst_i = '0' and teq_i = '0' and cmp_i = '0' and cmn_i = '0')) 
				--dans le cas d'1 traitement de données, on vérifie que l'on execute pas une opération 
				--comme tst,teq,cmp qui positionnent simplement les flags sans écrire dans Rn 
				or mult_t = '1' or branch_t = '1') else --on écrit tjr dans Rn apres 1 branch (pc/lr) ou mult 
				if_ir(21) when trans_t = '1' or mtrans_t = '1' else '0';
				--on écrit dans Rn lors d'un load

	flag_wb	<= if_ir(20) when regop_t = '1' or mult_t = '1' else '0'; --bit S indique si on modifie les flags 
				--dans les opérations de registres / multiplications

-- reg read
	--rn 
	radr1 <= "1110" when branch_t = '1' and blink = '1' else --adresse de LR 
			 "1111" when branch_t = '1' and blink = '0' else --adresse de PC
			 (if_ir(15 downto 12)) when (mult_t = '1') else --adresse de Rn dans mult
			 (if_ir(19 downto 16)); -- adresse de Rn dans regop_t, swap_t trans_t, mtrans_t (branch_t pas de Rn)
	
	--rm
	radr2 <= if_ir(3 downto 0); --Rm est tjr codé sur les 3 lsb

	--rs
	radr3 <= "1111" when branch_t = '1' and blink = '1' else --PC est mis dans LR en cas de B&L
			if_ir(15 downto 12) when trans_t = '1' and (str_i = '1' or strb_i = '1') else --destination du store le registre
			--n'est plus "Rd" (destination) comme dans un load mais bien une source 
			if_ir(11 downto 8);--Rs est stocké dans les msb de op2 

-- Reg Invalid

	--on invalide des registres où lire pour exe 
	inval_exe_adr <= "1110" when branch_t = '1' and blink = '1' else --invalide LR
					"1111" when branch_t = '1' else --invalide PC
					if_ir(19 downto 16) when ( (trans_t = '1' or mtrans_t = '1') and if_ir(21) = '1' ) or mult_t = '1' else --invalide Rd
					--si load/store avc write back ou si mult 
					if_ir(15 downto 12); --invalide Rd pour regop / ldr 

	inval_exe <= '0' when dec2exe_push = '0' else
				 '1' when branch_t = '1' or 
				 (regop_t = '1' and tst_i = '0' and teq_i = '0' and cmp_i = '0' and cmn_i = '0') or
				 ((trans_t = '1' or mtrans_t = '1') and if_ir(21) = '1') or
				 mult_t = '1' else
				 '0';

	inval_mem_adr <= if_ir(15 downto 12) when trans_t = '1' else mtrans_rd; --on invalide Rd 

	inval_mem <= '1' when ((trans_t = '1' and (ldr_i = '1' or ldrb_i = '1')) or mtrans_t = '1') and dec2exe_push = '1' else
				 '0'; 

	inval_czn <= if_ir(20) when (regop_t = '1' or mult_t = '1') and dec2exe_push = '1' else
				 '0';
			

	inval_ovr <= '0' when dec2exe_push = '0' else
				 if_ir(20) when mult_t = '1' or
				 (regop_t = '1' and and_i = '0' and eor_i = '0' and
				 tst_i = '0' and teq_i = '0' and orr_i = '0' and 
				 mov_i = '0'	and bic_i = '0' and mvn_i = '0') else
				 '0';
	

-- operand validite

	operv <=	'1' when ((rvalid1 = '1' or (regop_t = '1' and(mov_i = '1' or mvn_i = '1'))) --
				
				and (((rvalid2 = '1' and branch_t = '0' and mtrans_t = '0' and ((regop_t = '1' and if_ir(25) = '0') or
				(trans_t = '1' and if_ir(25) = '1') or mult_t = '1'))
				or
				(branch_t = '1' or mtrans_t = '1' or
				(regop_t = '1' and if_ir(25) = '1') or
				(trans_t = '1' and if_ir(25) = '0'))))
				and 
				
				((rvalid3 = '1' and branch_t = '0' and mtrans_t = '0' and mult_t = '0'
				and
				((regop_t = '1' and if_ir(25) = '0' and if_ir(4) = '1') --1 si pas immédiat et Rs est bien un registre 
				--(décidé par bit 4) 
				or
				(trans_t = '1' and if_ir(25) = '1' and if_ir(4) = '1')))
				or
				((regop_t = '1' and ((if_ir(25) = '0' and if_ir(4) = '0') or if_ir(25) = '1')) or
				(trans_t = '1' and ((if_ir(25) = '1' and if_ir(4) = '0') or if_ir(25) = '0')) or
				(mtrans_t = '1' or branch_t = '1' or mtrans_t = '1' or mult_t = '1'))
				or
				(rvalid3 = '1' and branch_t = '1' and blink = '1' and
				regop_t = '0' and mtrans_t = '0' and mult_t = '0' and trans_t = '0'))) else
				'0';

-- Decode to mem interface 
	ld_dest <= if_ir(15 downto 12) when trans_t = '1' else mtrans_rd; --Rd dans if_ir si transfert
	pre_index <= if_ir(24) or (branch_t and blink); --pre index dépend du bit 24 (dans load/store etc) ; 
	--on ajoute 4 a PC avant de le stocker dans LR en cas de B&L

	mem_lw <= ldr_i; 
	mem_lb <= ldrb_i; 
	mem_sw <= str_i or (branch_t and blink);
	mem_sb <= strb_i;

-- Shifter command

	shift_lsl <= '1' when ((regop_t = '1' and if_ir(25) = '0') or (trans_t = '1' and if_ir(25) = '1'))
				 and if_ir(6 downto 5) = "00" else '0' ;

	shift_lsr <= '1' when (((regop_t = '1' and if_ir(25) = '0') or
				 (trans_t = '1' and if_ir(25) = '1')) and if_ir(6 downto 5) = "01") else '0';
	shift_asr <= '1' when (((regop_t = '1' and if_ir(25) = '0') or
				 (trans_t = '1' and if_ir(25) = '1')) and if_ir(6 downto 5) = "10") else '0';
	shift_ror <= '1' when (((regop_t = '1' and if_ir(25) = '0') or
				 (trans_t = '1' and if_ir(25) = '1')) and if_ir(6 downto 5) = "11") else '0';
	shift_rrx <= '1' when (((regop_t = '1' and if_ir(25) = '0') or(trans_t = '1' and if_ir(25) = '1')) 
				  and if_ir(6 downto 5) = "11" and if_ir(11 downto 7) = "00000" and if_ir(4) = '0') else --vrai si ror avec 
				  --valeur de 0 et pas de registre
				 '0';


	shift_val <= if_ir(11 downto 8) & "0" when regop_t = '1' and if_ir(25) = '1' else --valeur de rotation si immédiat
				 if_ir(11 downto 7) when ((regop_t = '1' and if_ir(25) = '0') or --valeur de shift si i=0
				 (trans_t = '1' and if_ir(25) = '1')) and if_ir(4) = '0' else --valeur de shift si pas registre (ir4) 
				 --et op2 de trans est 1 immédiat
				 rdata3(4 downto 0) when regop_t = '1' and if_ir(25) = '0' and if_ir(4) = '1' else
				 --lsb du registre contenu dans Rs si if_ir(4) est à 1
				 "00010" when branch_t = '1' else --ajoute 4 à PC  ??? (laissé car donné) A VERIFIER
	             "00000";

-- Alu operand selection


	comp_op1	<= '1' when (rsb_i = '1' or rsc_i = '1') else '0'; -- op2 - rn donc on demande le complémentaire de Rn 
	comp_op2	<= '1' when (sub_i = '1' or sbc_i = '1' or cmp_i = '1' or bic_i = '1' or mvn_i = '1') else
				   --Rn - op2 dans ces cas là donc on prend le complémentaire de op2
				   '1' when (branch_t = '1' and blink = '1') else
				   '0';

	alu_cy <= '1' when (sub_i = '1' or rsb_i = '1' or cmp_i = '1') else
			  cry when (adc_i = '1' or sbc_i = '1' or rsc_i = '1') else
			  '1' when (branch_t = '1' and blink = '1') else
			  '0';

-- Alu command

	alu_cmd <=	"11" when eor_i = '1' or teq_i = '1' else --xor
				"10" when orr_i = '1' or mov_i = '1' or mvn_i = '1' else --orr 
				"01" when and_i = '1' or tst_i = '1' or bic_i = '1' else --and 
				"00"; --add
-- Mtrans reg list

	
	process (ck)
	begin

	if (rising_edge(ck)) then
		--??????? le process est déjà en dessous ? 
	end if;

	end process; 

	mtrans_mask_shift <= X"FFFE" when if_ir(0) = '1' and mtrans_mask(0) = '1' else
								X"FFFC" when if_ir(1) = '1' and mtrans_mask(1) = '1' else
								X"FFF8" when if_ir(2) = '1' and mtrans_mask(2) = '1' else
								X"FFF0" when if_ir(3) = '1' and mtrans_mask(3) = '1' else
								X"FFE0" when if_ir(4) = '1' and mtrans_mask(4) = '1' else
								X"FFC0" when if_ir(5) = '1' and mtrans_mask(5) = '1' else
								X"FF80" when if_ir(6) = '1' and mtrans_mask(6) = '1' else
								X"FF00" when if_ir(7) = '1' and mtrans_mask(7) = '1' else
								X"FE00" when if_ir(8) = '1' and mtrans_mask(8) = '1' else
								X"FC00" when if_ir(9) = '1' and mtrans_mask(9) = '1' else
								X"F800" when if_ir(10) = '1' and mtrans_mask(10) = '1' else
								X"F000" when if_ir(11) = '1' and mtrans_mask(11) = '1' else
								X"E000" when if_ir(12) = '1' and mtrans_mask(12) = '1' else
								X"C000" when if_ir(13) = '1' and mtrans_mask(13) = '1' else
								X"8000" when if_ir(14) = '1' and mtrans_mask(14) = '1' else
								X"0000";

	mtrans_list <= if_ir(15 downto 0) and mtrans_mask;

	process (mtrans_list)
	begin
	end process;

	mtrans_1un <= '1' when mtrans_nbr = "00001" else '0';

	mtrans_rd <=	X"0" when mtrans_list(0) = '1' else
						X"1" when mtrans_list(1) = '1' else
						X"2" when mtrans_list(2) = '1' else
						X"3" when mtrans_list(3) = '1' else
						X"4" when mtrans_list(4) = '1' else
						X"5" when mtrans_list(5) = '1' else
						X"6" when mtrans_list(6) = '1' else
						X"7" when mtrans_list(7) = '1' else
						X"8" when mtrans_list(8) = '1' else
						X"9" when mtrans_list(9) = '1' else
						X"A" when mtrans_list(10) = '1' else
						X"B" when mtrans_list(11) = '1' else
						X"C" when mtrans_list(12) = '1' else
						X"D" when mtrans_list(13) = '1' else
						X"E" when mtrans_list(14) = '1' else
						X"F";

-- FSM

process (ck)
begin

if (rising_edge(ck)) then
	if (reset_n = '0') then
		cur_state <= FETCH;
	else
		cur_state <= next_state;
	end if;
end if;

end process;

inc_pc <= dec2if_push;

--state machine process.
process (cur_state, dec2if_full, cond, condv, operv, dec2exe_full, if2dec_empty, reg_pcv, bl_i,
			branch_t, and_i, eor_i, sub_i, rsb_i, add_i, adc_i, sbc_i, rsc_i, orr_i, mov_i, bic_i,
			mvn_i, ldr_i, ldrb_i, ldm_i, stm_i, if_ir, mtrans_rd, mtrans_mask_shift)
begin
	case cur_state is

	when FETCH =>
		debug_state <= X"1";
		if2dec_pop <= '0';
		dec2exe_push <= '0';
		blink <= '0';
		mtrans_shift <= '0';
		mtrans_loop_adr <= '0';

		if dec2if_full = '1' and reg_pcv = '1' then -- T2 (FETCH -> RUN)
			next_state <= RUN;
		else -- T1 (FETCH -> FETCH)
			if2dec_pop <= '0';
			next_state <= FETCH;
		end if;
	
	when RUN =>
	--- DEBUG
	debug_state <= x"1";
	if (branch_t = '1' and bl_i = '1') then
		blink <= '1';
	end if;

	--T1 Run -> Run 
	if (if2dec_empty = '1' and if2dec_pop = '0') then
		if (dec2if_full = '1') then 
			dec2if_push <= '0'; 
		end if;
		dec2exe_push <= '0'; 
		next_state <= RUN; --T1 -> Run, Run 
	else
		if (condv = '0' or operv = '0' or (dec2exe_full = '1' and exe_pop = '0')) then -- T1 Run -> Run 
			dec2exe_push <= '0';
			if2dec_pop <= '0';
			dec2if_push <= '0';
			next_state <= RUN;
		elsif (cond = '0') then -- T2 -> run , run 
			dec2exe_push <= '0';
			if2dec_pop <= '1';
			dec2if_push <= '1';
			next_state <= RUN;
		else
			if (branch_t = '1') then -- branch
				dec2exe_push <= '1'; -- push branch and flush instruction buffer
				if2dec_pop <= '0';
				dec2if_push <= '0';
				if (blink = '1') then -- branch and link
					next_state <= LINK; --T4 -> Run, link 
				else -- branch and not link
					next_state <= BRANCH; --T5 Run, link
				end if;
			elsif (mtrans_t = '1') then -- multiple transfer
				-- on exectue pas mtrans
				dec2if_push <= '0';
				dec2exe_push <= '1';
				if2dec_pop <= '0';
				next_state <= MTRANS;
			elsif (mult_t = '1') then 
				-- on execute pas mult
				dec2if_push <= '1';
				dec2exe_push <= '1';
				if2dec_pop <= '1';
				next_state <= RUN;
			elsif (regop_t = '1' or swap_t = '1' or trans_t = '1') then -- regular														
				-- push instruction and inc pc
				dec2exe_push <= '1';
				--- if writing in pc then we must flush the instruction buffer
				if (alu_dest = x"F" and alu_wb = '1') then
					dec2exe_push <= '1';
					if2dec_pop <= '0';
					dec2if_push <= '0';
					next_state <= BRANCH;
				else
					dec2if_push <= '1';
					if2dec_pop <= '1';
					next_state <= RUN;
				end if;
			else
				report "RUN error";
			end if;
		end if;
	end if;
	--- MTRANS state
	when MTRANS =>
		debug_state <= x"2";
		--gerer les push / pop fifo
		--retourne dans Run (on ignore l'instruction)
		next_state <= RUN; 


	--- BRANCH state
	when BRANCH =>
		debug_state <= x"3";
		dec2exe_push <= '0';
		if (reg_pcv = '1') then
			dec2if_push <= '1';
			if2dec_pop <= '1';
			next_state <= RUN;
		else
			if2dec_pop <= '0';
			next_state <= BRANCH;
		end if;
	

	--- LINK state
	when LINK =>
		debug_state <= x"4";
		blink <= '0';
		next_state <= BRANCH;
	
	end case;
end process;

dec_pop <= if2dec_pop;
end Behavior;
