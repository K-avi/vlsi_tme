library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exec_tb is 
end entity;

architecture structure of exec_tb is 
    component exec 
        port(
        -- Decode interface synchro
                dec2exe_empty	: in Std_logic;
                exe_pop			: out Std_logic;
        -- Decode interface operands
                dec_op1			: in Std_Logic_Vector(31 downto 0); -- first alu input
                dec_op2			: in Std_Logic_Vector(31 downto 0); -- shifter input
                dec_exe_dest	: in Std_Logic_Vector(3 downto 0); -- Rd destination
                dec_exe_wb		: in Std_Logic; -- Rd destination write back
                dec_flag_wb		: in Std_Logic; -- CSPR modifiy
        -- Decode to mem interface 
                dec_mem_data	: in Std_Logic_Vector(31 downto 0); -- data to MEM W
                dec_mem_dest	: in Std_Logic_Vector(3 downto 0); -- Destination MEM R
                dec_pre_index 	: in Std_logic;
                -- Read in fifo 
                dec_mem_lw		: in Std_Logic;
                dec_mem_lb		: in Std_Logic;
                dec_mem_sw		: in Std_Logic;
                dec_mem_sb		: in Std_Logic;
        -- Shifter command
                -- passed to shifter 
                dec_shift_lsl	: in Std_Logic;
                dec_shift_lsr	: in Std_Logic;
                dec_shift_asr	: in Std_Logic;
                dec_shift_ror	: in Std_Logic;
                dec_shift_rrx	: in Std_Logic;
                dec_shift_val	: in Std_Logic_Vector(4 downto 0);
                -- carry passed to shifter
                dec_cy			: in Std_Logic;
        -- Alu operand selection
                -- used before alu to select negation or op 1
                dec_comp_op1	: in Std_Logic;
                dec_comp_op2	: in Std_Logic;
                -- carry passed to alu
                dec_alu_cy 		: in Std_Logic;
        -- Alu command
                dec_alu_cmd		: in Std_Logic_Vector(1 downto 0);
        -- Exe bypass to decod
                exe_res			: out Std_Logic_Vector(31 downto 0); --mapped to alu_res
                exe_c			: out Std_Logic; --the carry out is the carry of the 
                                                -- alu when an add is performed else 
                                                -- it's the carry of the shifter
                exe_v			: out Std_Logic; --mapped to alu_v
                exe_n			: out Std_Logic; --mapped to alu_n
                exe_z			: out Std_Logic; --mapped to alu_z
                --doesn't go through the fifo ; directly mapped with dec_exe
                exe_dest		: out Std_Logic_Vector(3 downto 0); -- Rd destination
                exe_wb			: out Std_Logic; -- Rd destination write back
                exe_flag_wb		: out Std_Logic; -- CSPR modifiy
        -- Mem interface
                -- read from fifo 
                exe_mem_adr		: out Std_Logic_Vector(31 downto 0); -- Alu res register
                exe_mem_data	: out Std_Logic_Vector(31 downto 0); 
                exe_mem_dest	: out Std_Logic_Vector(3 downto 0);
                exe_mem_lw		: out Std_Logic; 
                exe_mem_lb		: out Std_Logic; 
                exe_mem_sw		: out Std_Logic; 
                exe_mem_sb		: out Std_Logic; 
                exe2mem_empty	: out Std_logic; --read from fifo
                mem_pop			: in Std_logic;
        -- global interface
                ck				: in Std_logic;
                reset_n			: in Std_logic;
                vdd				: in bit;
                vss				: in bit
        );
    end component;
    signal dec2exe_empty	:  Std_logic;
    signal exe_pop			:  Std_logic;
    signal dec_op1			: Std_Logic_Vector(31 downto 0); -- first alu input
    signal dec_op2			: Std_Logic_Vector(31 downto 0); -- shifter input
    signal dec_exe_dest	: Std_Logic_Vector(3 downto 0); -- Rd destination
    signal dec_exe_wb		: Std_Logic; -- Rd destination write back
    signal dec_flag_wb		: Std_Logic; -- CSPR modifiy
    signal dec_mem_data	: Std_Logic_Vector(31 downto 0); -- data to MEM W
    signal dec_mem_dest	: Std_Logic_Vector(3 downto 0); -- Destination MEM R
    signal dec_pre_index 	: Std_logic;
    signal dec_mem_lw		: Std_Logic;
    signal dec_mem_lb		: Std_Logic;
    signal dec_mem_sw		: Std_Logic;
    signal dec_mem_sb		: Std_Logic;
    signal dec_shift_lsl	: Std_Logic;
    signal dec_shift_lsr	: Std_Logic;
    signal dec_shift_asr	: Std_Logic;
    signal dec_shift_ror	: Std_Logic;
    signal dec_shift_rrx	: Std_Logic;
    signal dec_shift_val	: Std_Logic_Vector(4 downto 0);
    signal dec_cy		: Std_Logic;
    signal dec_comp_op1	        : Std_Logic;
    signal dec_comp_op2	        : Std_Logic;
    signal dec_alu_cy 		: Std_Logic;
    signal dec_alu_cmd		: Std_Logic_Vector(1 downto 0);
    signal exe_res		: Std_Logic_Vector(31 downto 0); --mapped to alu_res
    signal exe_v		: Std_Logic; --mapped to alu_v
    signal exe_n		: Std_Logic; --mapped to alu_n
    signal exe_z		: Std_Logic; --mapped to alu_z
    signal exe_c                : std_logic;
    signal exe_dest		: Std_Logic_Vector(3 downto 0); -- Rd destination
    signal exe_wb		: Std_Logic; -- Rd destination write back
    signal exe_flag_wb		: Std_Logic; -- CSPR modifiy
    signal exe_mem_adr		: Std_Logic_Vector(31 downto 0); -- Alu res register
    signal exe_mem_data	        : Std_Logic_Vector(31 downto 0); 
    signal exe_mem_dest	        : Std_Logic_Vector(3 downto 0);
    signal exe_mem_lw		: Std_Logic; 
    signal exe_mem_lb		: Std_Logic; 
    signal exe_mem_sw		: Std_Logic; 
    signal exe_mem_sb		: Std_Logic; 
    signal exe2mem_empty	: Std_logic; --read from fifo
    signal mem_pop		: Std_logic;
    -- global interface
    signal ck			: Std_logic;
    signal reset_n		: Std_logic;
    signal vdd			: bit;
    signal vss			: bit ;

begin 
    exec_0 : exec 
        port map(
        -- Decode interface synchro
                dec2exe_empty	=> dec2exe_empty,
                exe_pop			=> exe_pop,
        -- Decode interface operands
                dec_op1			=> dec_op1,
                dec_op2			=> dec_op2,
                dec_exe_dest	=> dec_exe_dest,
                dec_exe_wb		=> dec_exe_wb,
                dec_flag_wb		=> dec_flag_wb,
        -- Decode to mem interface
                dec_mem_data	=> dec_mem_data,
                dec_mem_dest	=> dec_mem_dest,
                dec_pre_index 	=> dec_pre_index,
                dec_mem_lw	=> dec_mem_lw,
                dec_mem_lb	=> dec_mem_lb,
                dec_mem_sw	=> dec_mem_sw,
                dec_mem_sb	=> dec_mem_sb,
        -- Shifter command
                dec_shift_lsl	=> dec_shift_lsl,
                dec_shift_lsr	=> dec_shift_lsr,
                dec_shift_asr	=> dec_shift_asr,
                dec_shift_ror	=> dec_shift_ror,
                dec_shift_rrx	=> dec_shift_rrx,
                dec_shift_val	=> dec_shift_val,
                dec_cy		=> dec_cy,
        -- Alu operand selection
                dec_comp_op1	=> dec_comp_op1,
                dec_comp_op2	=> dec_comp_op2,
                dec_alu_cy 	=> dec_alu_cy,
        -- Alu command
                dec_alu_cmd	=> dec_alu_cmd,
        -- Exe bypass to decod
                exe_res		=> exe_res,
                exe_c		=> exe_c,
                exe_v		=> exe_v,
                exe_n		=> exe_n,
                exe_z		=> exe_z,
                exe_dest	=> exe_dest,
                exe_wb		=> exe_wb,
                exe_flag_wb	=> exe_flag_wb,
        -- Mem interface
                exe_mem_adr	=> exe_mem_adr,
                exe_mem_data	=> exe_mem_data,
                exe_mem_dest	=> exe_mem_dest,
                exe_mem_lw	=> exe_mem_lw,
                exe_mem_lb	=> exe_mem_lb,
                exe_mem_sw	=> exe_mem_sw,
                exe_mem_sb	=> exe_mem_sb,
                exe2mem_empty	=> exe2mem_empty,
                mem_pop		=> mem_pop,
        -- global interface
                ck		=> ck,
                reset_n		=> reset_n,
                vdd		=> vdd,
                vss		=> vss
        );



    process 
        
    begin 
        -- init values
        dec2exe_empty <= '1';
        dec_op1 <= "00000000000000000000000000000000" ;
        dec_op2 <= "00000000000000000000000000000000";
        dec_exe_dest <= "0000";
        dec_exe_wb <= '1';
        dec_flag_wb <= '0';

        dec_mem_data <= "00000000000000000000000000000000" ;
        dec_mem_dest <= "0000";

        dec_pre_index <= '1'; 

        dec_mem_lw <= '1'; 
        dec_mem_sw <= '0'; 
        dec_mem_lb <= '0' ; 
        dec_mem_sb <= '0'; 

        dec_shift_lsl	<= '1';
	dec_shift_lsr	<= '0';
	dec_shift_asr	<= '0';
	dec_shift_ror	<= '0';
	dec_shift_rrx	<= '0';

        dec_shift_val <= "00000";

        dec_cy <= '0'; 

        dec_comp_op1 <= '1'; 
        dec_comp_op2 <= '1'; 

        -- test add and load
        dec_alu_cy <= '1'; 
        dec_alu_cmd <= "00";

        mem_pop <= '0';

        wait for 1 ns;
        assert exe_wb = '0' report "im going to kms" severity error;
        assert exe_res = "00000000000000000000000000000001" report 
        integer'image(to_integer(unsigned(exe_res(30 downto 0)))) severity error;

        --test xor
        dec_op1 <= "00000000000000000000000000000000" ;
        dec_op2 <= "11111111111111111111111111111111";

        dec_alu_cmd <= "11";

        
        wait for 1 ns;
        assert exe_wb = '0' report "im going to kms" severity error;
        --assert dec_op1 = "11111111111111111111111111111111" report "op1 wrong" severity error;
        --assert dec_op2 = "11111111111111111111111111111111" report "op2 wrong" severity error;
        assert exe_res = "11111111111111111111111111111111" report  
        integer'image(to_integer(unsigned(exe_res(30 downto 0)))) severity error;

    wait;
    end process;
end architecture;
