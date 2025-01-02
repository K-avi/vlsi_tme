library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_tb is 
begin 
end reg_tb ;

architecture dataflow of reg_tb is 

    component Reg is
        port(
        -- Write Port 1 prioritaire
            wdata1		: in Std_Logic_Vector(31 downto 0); --port d'écriture, ecrit au registre numéro wadr1
            wadr1			: in Std_Logic_Vector(3 downto 0);
            wen1			: in Std_Logic; --est ce que on write ou pas ? 

        -- Write Port 2 non prioritaire
            wdata2		: in Std_Logic_Vector(31 downto 0); --port d'écriture, ecrit au registre numéro wadr2
            wadr2		: in Std_Logic_Vector(3 downto 0);
            wen2		: in Std_Logic; --est ce qu'on write ? 

        -- Write CSPR Port
            wcry			: in Std_Logic; --idx 0
            wzero			: in Std_Logic; --idx 1 
            wneg			: in Std_Logic; --idx 2 
            wovr			: in Std_Logic; --idx 3 
            cspr_wb			: in Std_Logic; --modifie  on les flags ? 
            
        -- Read Port 1 32 bits
            reg_rd1		: out Std_Logic_Vector(31 downto 0); --ports de sortie prend la valeur de reg numéro radr1 
            radr1		: in Std_Logic_Vector(3 downto 0); --numero du registre sur 4 bits 
            reg_v1		: out Std_Logic; -- bit de validité du registre de num radr1

        -- Read Port 2 32 bits
            reg_rd2		: out Std_Logic_Vector(31 downto 0); --port de sortie, prend la valeur de reg numéro radr1
            radr2		: in Std_Logic_Vector(3 downto 0);
            reg_v2		: out Std_Logic; -- bit de validité de radr2

        -- Read Port 3 32 bits
            reg_rd3		: out Std_Logic_Vector(31 downto 0); -- port de sortie prend la valeur de reg de numéro radr3 
            radr3		: in Std_Logic_Vector(3 downto 0);
            reg_v3		: out Std_Logic; -- bit de validité du registre num radr3

        -- read CSPR Port
            reg_cry		: out Std_Logic; --port dre sortie des flags
            reg_zero	: out Std_Logic;
            reg_neg		: out Std_Logic;
            reg_cznv	: out Std_Logic;
            reg_ovr		: out Std_Logic;
            reg_vv		: out Std_Logic;
            
        -- Invalidate Port 
            inval_adr1	: in Std_Logic_Vector(3 downto 0); --numero du registre a invalider
            inval1		: in Std_Logic; -- est ce qu'on invalide? 

            inval_adr2	: in Std_Logic_Vector(3 downto 0); --numero du registre a invalider 
            inval2		: in Std_Logic; -- est ce qu'on invalide ? 

            inval_czn	: in Std_Logic; --invalidité des flags carry, zero, negative
            inval_ovr	: in Std_Logic; --invalidité du flag overflow
        -- PC
            reg_pc		: out Std_Logic_Vector(31 downto 0); --sortie pc+4 
            reg_pcv		: out Std_Logic; --sortie bit de validité de pc 
            inc_pc		: in Std_Logic; --est ce qu'on incremente ? 
        
        -- global interface
            ck			: in Std_Logic;
            reset_n		: in Std_Logic;
            vdd			: in bit;
            vss			: in bit);
    end component;

    signal wdata1, wdata2, reg_rd1, reg_rd2, reg_rd3, reg_pc : std_logic_vector(31 downto 0);
    signal wadr1, wadr2, radr1, radr2, radr3, inval_adr1, inval_adr2: std_logic_vector(3 downto 0);
    signal wen1, wen2, wcry, wzero, wneg, wovr, cspr_wb, reg_v1, reg_v2, reg_v3, reg_cry, reg_zero, reg_neg, reg_cznv, reg_ovr, reg_vv, inval1, inval2, inval_czn, inval_ovr, reg_pcv, inc_pc, ck, reset_n: std_logic;
    signal vdd, vss : bit;

begin 

    reg0 : reg 
    port map(
            wdata1 => wdata1,
            wadr1 => wadr1,
            wen1 => wen1,

            wdata2 => wdata2,
            wadr2 => wadr2,
            wen2 => wen2,

            wcry => wcry,
            wzero => wzero,
            wneg => wneg,
            wovr => wovr,
            cspr_wb => cspr_wb,
            
            reg_rd1 => reg_rd1,
            radr1 => radr1,
            reg_v1 => reg_v1,

            reg_rd2 => reg_rd2,
            radr2 => radr2,
            reg_v2 => reg_v2,

            reg_rd3 => reg_rd3,
            radr3 => radr3,
            reg_v3 => reg_v3,

            reg_cry => reg_cry,
            reg_zero => reg_zero,
            reg_neg => reg_neg,
            reg_cznv => reg_cznv,
            reg_ovr => reg_ovr,
            reg_vv => reg_vv,
             
            inval_adr1 => inval_adr1,
            inval1 => inval1,

            inval_adr2 => inval_adr2,
            inval2 => inval2,

            inval_czn => inval_czn,
            inval_ovr => inval_ovr,
 
            reg_pc => reg_pc,
            reg_pcv => reg_pcv,
            inc_pc => inc_pc,
        
            ck => ck,	
            reset_n => reset_n,
            vdd => vdd,
            vss => vss
    );

 
    process  
    begin

        reset_n <= '1' ; 
        wait on reset_n ; 

        -- met les registres 1 et 15 a valide
        inval_adr1 <= "0001";
        inval1 <= '1';

        inval_adr2 <= "1111";
        inval2 <= '1';

        wait on inval_adr1 ;
       

        -- write valeur dans reg1
        
        wdata1 <= x"00000000";
        wadr1 <= "0001";
        wen1 <= '1'; --on write

         --write valeur dans reg15
        wdata2 <= x"00000010";
        wadr2 <= "1111"; 
        wen2 <= '1';  --on write pas

         --set tout les flags à 0 et le wb a true
        wcry <= '0';
        wzero <= '0';
        wneg <= '0';
        wovr <= '0';
        cspr_wb <= '1';

        -- lis les registres 0, 1 et 15
        radr1 <= "0001";
        radr2 <= "0001";
        radr3 <= "1111";


        -- invalide les registres 8 et 12 pour test
        inval_adr1 <= "1000";
        inval1 <= '0';

        inval_adr2 <= "1100";
        inval2 <= '0';

        -- n'invalide pas les flags
        inval_czn <= '0';
        inval_ovr <= '0';

       -- incrément pc true
        inc_pc <= '1';

        ck <= '0';
        vdd <= '1';
        vss <= '0';
         
        report "qqqqbalbalbl";
        --wait on ;
        wait on radr3;
        report "radr 3 is : " & integer'image(to_integer(unsigned(radr3)));

  

        wait for 10 ns;
        
        report "here" ;

        assert reg_rd3(0) = '1' report "1 val" ;
        assert reg_rd3(0) = 'U' report "uninit" ; 
        assert reg_rd3(0) = '0' report "0 val" ; 
        
        --assert reg_rd3 = x"00000018" report ":((((((" severity error ; 
        assert reg_rd1(0) = '0'  report "read rd1 wrong L" severity error ; 
        report "reg_rd1 1 is : " & integer'image(to_integer(unsigned(reg_rd1)));
        --assert reg_rd2 = 

wait;
end process;
end architecture;

