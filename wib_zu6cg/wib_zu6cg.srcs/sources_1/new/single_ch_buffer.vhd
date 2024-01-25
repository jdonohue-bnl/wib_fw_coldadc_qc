----------------------------------------------------------------------------------
-- Company: BNL
-- Engineer: Jillian Donohue
-- 
-- Create Date: 01/04/2024 03:09:27 PM
-- Design Name: wib_fw_coldadc_qc
-- Module Name: single_ch_buffer - Behavioral
-- Project Name: 
-- Target Devices: wib_zu6cg
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.accum_typedef.all;

entity single_ch_buffer is
  Port ( 
        --clk : in std_logic;
        axi_clk : in std_logic; --mem will also receive this clock, separately      
        reset : in std_logic;  
        trigger: in std_logic;
--        num_samples : in std_logic_vector(31 downto 0);          
        deframed_aligned : in arraydata_alladcs(15 downto 0)(31 downto 0)(13 downto 0);
        deframed_state : in arr8x2;
        ch_to_analyze : in std_logic_vector(8 downto 0);
        

        mem_en  : out std_logic;
        mem_write : out std_logic_vector(3 downto 0);
        mem_addr : out std_logic_vector(12 downto 0);
        mem_din : out std_logic_vector(31 downto 0);           
        mem_dout : in std_logic_vector(31 downto 0); 
        
        done : out std_logic
  );
attribute dont_touch : string;
attribute dont_touch of single_ch_buffer : entity is "true";
end single_ch_buffer;

architecture Behavioral of single_ch_buffer is

type state_t is (IDLE, CLEAR_MEM, READ0, WAIT_FOR_DATA1, READ1, WRITE, WAIT_FOR_DATA);
signal state : state_t := IDLE;
attribute fsm_encoding : string;
attribute fsm_encoding of state : signal is "sequential";

--fsm signals
signal mem_rst_count : integer := 0;
--signal samples_taken : unsigned(13 downto 0) := "00000000000000";
--constant samples_to_take : unsigned(13 downto 0) := "11111111111111";
signal analysis_link_id: integer;
signal analysis_ch_id: integer;
signal analysis_cd_id: integer;
signal write_offset : integer;


--synchronization
signal trigger_s : std_logic;
signal done_s : std_logic;
signal deframed_aligned_s : arraydata_alladcs(15 downto 0)(31 downto 0)(13 downto 0);
signal deframed_state_s : arr8x2;
signal ch_to_analyze_s : std_logic_vector(8 downto 0);


begin

sync : process(axi_clk)
begin
    if rising_edge(axi_clk) then
        trigger_s <= trigger;
        done <= done_s;
        deframed_aligned_s <= deframed_aligned;
        deframed_state_s <= deframed_state;
        ch_to_analyze_s <= ch_to_analyze;
    end if;
end process sync;

fsm : process (axi_clk)
begin
    if rising_edge(axi_clk) then
        if reset = '1' then
            state <= IDLE;
        else
            case state is
                when IDLE => --readout, etc    
    --                samples_taken <= (others => '0');
                    mem_en <= '0';
                    mem_write <= "0000";
                    if trigger_s = '1' then  
                        mem_addr <= (others => '0');
                        write_offset <= 0;
                        mem_din <= (others => '0');
                        
                        analysis_link_id <= to_integer(unsigned(ch_to_analyze_s(8 downto 5)));
                        analysis_ch_id <= to_integer(unsigned(ch_to_analyze_s(4 downto 0)));
                        analysis_cd_id <= to_integer(unsigned(ch_to_analyze_s(8 downto 6)));
                        mem_en <= '1';
                        done_s <= '0'; --clear ready flag       
                        
                        state <= CLEAR_MEM;               
                    end if;
                when CLEAR_MEM => --copied from histogram fsm
                    mem_write <= "1111"; --trigger already set mem_din to 0
                    mem_rst_count <= mem_rst_count + 1;
                    if mem_rst_count = 1 then
                       mem_addr <= std_logic_vector(unsigned(mem_addr) + 1);
                       mem_rst_count <= 0; 
                    end if;               
                    if mem_addr = "1111111111111" then
                        mem_write <= "0000";
                        mem_addr <= (others => '0');
                        state <= READ0;
                    end if;           
                when READ0 =>
                --read from datastream for lower memory write position
                    mem_din(15 downto 0) <= "00" & deframed_aligned_s(analysis_link_id)(analysis_ch_id);
                
    /*                if write_offset = 0 then
                        mem_din <= x"0000" & "00" & deframed_aligned(analysis_link_id)(analysis_ch_id);
                    else
                        mem_din <= "00" & deframed_aligned(analysis_link_id)(analysis_ch_id) & x"0000";
                    end if;*/
                    
                    if deframed_state_s(analysis_cd_id)(0) = '1' then
    --                    state <= WRITE;
                        state <= WAIT_FOR_DATA1;
                    end if;
                when WAIT_FOR_DATA1 =>
                    if deframed_state_s(analysis_cd_id)(0) = '0' then
                        state <= READ1;
                    end if;
                when READ1 =>
                --read from datastream for higher memory write position
                    mem_din(31 downto 16) <= "00" & deframed_aligned_s(analysis_link_id)(analysis_ch_id);
                     if deframed_state_s(analysis_cd_id)(0) = '1' then
    --                    state <= WRITE;
                        state <= WRITE;
                    end if;               
                when WRITE => 
                    mem_write <= "1111";
                    state <= WAIT_FOR_DATA;            
                when WAIT_FOR_DATA =>
                    mem_write <= "0000";
    --                if mem_addr = "1111111111111" and write_offset = 16 then --done
                    if mem_addr = "1111111111111" then    
                        done_s <= '1';
                        state <= IDLE;
                    elsif deframed_state_s(analysis_cd_id)(0) = '0' then
                        --"increment" memory address
    --                    if write_offset = 0 then
    --                        write_offset <= 16;
    --                    else
    --                        write_offset <= 0;
                        mem_addr <= std_logic_vector(unsigned(mem_addr) + 1);
    --                    end if;                                           
                        state <= READ0;
                    end if;
                when others =>
                    state <= IDLE;
           end case; 
       end if;
    end if;
end process fsm;

end Behavioral;
