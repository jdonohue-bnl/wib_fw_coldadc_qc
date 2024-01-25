--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.accum_typedef.all;

entity accumulator is
    port (
        clk : in std_logic;
        reset : in std_logic; 
        trigger: in std_logic;
        num_samples : in integer range 1 to 262144;
        deframed_aligned :  in arraydata_alladcs(15 downto 0)(31 downto 0)(13 downto 0);
        deframed_state : in arr8x2;
        
        accum_ready : out std_logic_vector(7 downto 0);
        total : out arraydata_alladcs(15 downto 0)(31 downto 0)(31 downto 0)        
    );
end accumulator;

architecture Behavioral of accumulator is

type arr64x8 is array(7 downto 0) of std_logic_vector(63 downto 0);

--signal deframed_aligned : arraydata_alladcs(15 downto 0)(31 downto 0)(13 downto 0);
--signal deframed_single_test : arraydata_alladcs(1 downto 0)(31 downto 0)(13 downto 0);
--signal deframed_state : arr8x2;
--signal accum_ready : std_logic_vector(7 downto 0);
--signal total : arraydata_alladcs(15 downto 0)(31 downto 0)(31 downto 0);



component accumulator_single is
    port (
        clk : in std_logic;
        reset : in std_logic; 
        trigger : in std_logic;
        deframed_aligned : in arraydata_alladcs(1 downto 0)(31 downto 0)(13 downto 0);
        deframed_state : in std_logic;
        num_samples : in integer range 1 to 262144;
                
        ready_out : out std_logic;
        total_out: out arraydata_alladcs(1 downto 0)(31 downto 0)(31 downto 0)
    );
end component accumulator_single;

begin

--deframed_single_test <= deframed_aligned(1 downto 0);


accum_singles :
for i in 0 to 7 generate
begin
    accum_single : entity work.accumulator_single
        port map(
            clk => clk,
            reset => reset,            
            trigger => trigger,
            deframed_aligned => deframed_aligned(i*2+1 downto i*2),
--                deframed_aligned_link0 => deframed_aligned(i*2),
--                deframed_aligned_link1 => deframed_aligned(i*2+1),
            deframed_state => deframed_state(i)(0),
            num_samples => num_samples,
            
            ready_out => accum_ready(i),
            total_out => total(i*2+1 downto i*2)
        );
end generate accum_singles;    

end Behavioral;
