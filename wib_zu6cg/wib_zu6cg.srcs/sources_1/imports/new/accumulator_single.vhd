----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/18/2023 03:51:28 PM
-- Design Name: 
-- Module Name: accumulator_single - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package accum_typedef is 
--    type data_array is array(15 downto 0) of std_logic_vector(13 downto 0);
--    type data_array32 is array(31 downto 0) of data_array;
--    type arraydata_2adcs is array(31 downto 0) of std_logic_vector(13 downto 0);    
--    type arraydata_alladcs is array(15 downto 0) of arraydata_2adcs; --input [13:0] deframed [15:0][31:0], // [link][sample]
--    type arraydata_single is array(1 downto 0) of arraydata_2adcs; --input [13:0] deframed [NLINKS-1:0][31:0], // [link][sample]
    type arraydata_2adcs is array(integer range<>) of std_logic_vector;   
    type arraydata_alladcs is array(integer range<>) of arraydata_2adcs;     
    
    type arr16x8 is array(15 downto 0) of std_logic_vector(7 downto 0);
    type arr16x16 is array(15 downto 0) of std_logic_vector(15 downto 0);
    type arr16x2 is array(15 downto 0) of std_logic_vector(1 downto 0);
    type arr8x2 is array(7 downto 0) of std_logic_vector(1 downto 0); 
    type arr6x2 is array(5 downto 0) of std_logic_vector(1 downto 0); 
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.accum_typedef.all;

entity accumulator_single is
    --implement generic determining # of samples?
    port (
        clk : in std_logic;
        trigger : in std_logic;
        deframed_aligned : in arraydata_alladcs(1 downto 0)(31 downto 0)(13 downto 0);  --input [13:0] deframed [NLINKS-1:0][31:0], // [link][sample] 
        deframed_state : in std_logic;
        num_samples : in integer range 1 to 262144;
        
        ready_out : out std_logic;
        total_out : out arraydata_alladcs(1 downto 0)(31 downto 0)(31 downto 0) --input [13:0] deframed [NLINKS-1:0][31:0], // [link][sample]   
    );
end accumulator_single;

architecture Behavioral of accumulator_single is

type accum_state_t is (IDLE, WAIT_FOR_DATA, ACCUMULATE);
signal accum_state : accum_state_t := IDLE;

signal accum_enable : std_logic := '0';
signal accum_clear : std_logic := '0';
signal accum_totals : arraydata_alladcs(1 downto 0)(31 downto 0)(31 downto 0); --last param length subject to change
--signal accum_totals_s : arraydata_alladcs(1 downto 0)(31 downto 0)(24 downto 0); 
signal samples_taken : integer := 0;
signal samples_to_take : integer := 0;
signal ready : std_logic := '0';

--for synchronization. see process io
signal trigger_s : std_logic := '0';
signal ready_s : std_logic;
signal total: arraydata_alladcs(1 downto 0)(31 downto 0)(31 downto 0);

--COMPONENT c_accum_13in_25out
--  PORT (
--    B : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
--    CLK : IN STD_LOGIC;
--    CE : IN STD_LOGIC;
--    SCLR : IN STD_LOGIC;
--    Q : OUT STD_LOGIC_VECTOR(24 DOWNTO 0) 
--  );
--END COMPONENT;

COMPONENT c_accum_14in_32out
  PORT (
    B : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    CLK : IN STD_LOGIC;
    CE : IN STD_LOGIC;
    SCLR : IN STD_LOGIC;
    Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
  );
END COMPONENT;

------ Not using in-firmware division
--function div_by_2048(a : std_logic_vector) 
--return std_logic_vector is 
--    variable single_ch_total : std_logic_vector(24 downto 0);
--    variable single_ch_average : std_logic_vector(13 downto 0);
--begin
--    single_ch_total := a;
--    single_ch_average := single_ch_total(24 downto 11);
--    return single_ch_average;
--end function;

begin

--LINK_AVG: for link in 0 to 1 generate
--    CHANNEL_AVG: for channel in 0 to 31 generate
            
--    end generate CHANNEL_AVG;
--end generate LINK_AVG;



io : process(clk)
begin
    if rising_edge(clk) then
        trigger_s <= trigger;
        total_out <= total;
        ready_s <= ready;
        ready_out <= ready_s;
    end if;
end process io;

--sample_counting : process(deframed_state)
--begin
--    if rising_edge(deframed_state) and accum_enable = '1' then
--        samples_taken <= samples_taken + 1; 
--    elsif 
    
--end process sample_counting;

fsm: process(clk)
begin
    if rising_edge(clk) then
        case accum_state is
            when IDLE =>
                accum_enable <= '0';
                total <= accum_totals;
                samples_taken <= 0;
--                accum_totals_s <= accum_totals; -- last param subject to change; is currently shifted to the right by 11 to integer divide by 2048
--                link_loop: for link in 0 to 1 loop 
--                    channel_loop: for channel in 0 to 31 loop
----                        --avg(link)(channel) <= div_by_2048(accum_totals(link)(channel));
--                          total(link)(channel) <= accum_totals(link)(channel);
--                    end loop channel_loop;
--                end loop link_loop;
                
                if trigger_s = '1' then                    
                 accum_clear <= '1'; --clear accumulators
                 samples_to_take <= num_samples;
                 ready <= '0'; --clear ready flag
--                    accum_enable <= '1';
                 accum_state <= ACCUMULATE;     
--                 accum_state <= WAIT_FOR_DATA;         
                end if;
            when ACCUMULATE =>
                accum_clear <= '0'; 
                if deframed_state = '1' then
                    accum_enable <= '1';
                    samples_taken <= samples_taken + 1;
                    accum_state <= WAIT_FOR_DATA;
                end if;
--                if rising_edge(deframed_state) then -- <- this might not work
        
            when WAIT_FOR_DATA =>
                accum_clear <= '0';
                accum_enable <= '0';
                if samples_taken >= samples_to_take then 
                    ready <= '1';
                    accum_enable <= '0';
                    accum_state <= IDLE;                 
                elsif deframed_state <= '0' then
                    accum_state <= ACCUMULATE;
                end if;                    
                
                    

                                      
--                end if;
                
        end case;
    end if;
end process fsm;

LINK_GEN: for link in 1 downto 0 generate
    CHANNEL_GEN: for channel in 31 downto 0 generate
--        accum_ch : c_accum_13in_25out
--          PORT MAP (
--            B =>  deframed_aligned(link)(channel),
--            CLK => deframed_state,
--            CE => accum_enable,
--            SCLR => accum_clear,
--            Q => accum_totals(link)(channel)
--          );   
        accum_ch : c_accum_14in_32out
          PORT MAP (
            B => deframed_aligned(link)(channel),
            CLK => clk,
            CE => accum_enable,
            SCLR => accum_clear,
            Q => accum_totals(link)(channel)
          );               
    end generate CHANNEL_GEN;
end generate LINK_GEN;
end Behavioral;
