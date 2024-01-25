----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/04/2024 05:58:18 PM
-- Design Name: 
-- Module Name: single_ch_buffer_sim - Behavioral
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

use ieee.math_real.uniform;
use ieee.math_real.floor;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.accum_typedef.all;

entity single_ch_buffer_sim is
end single_ch_buffer_sim;

architecture Behavioral of single_ch_buffer_sim is

    type control_state_t is (BUF, AXI);
    signal control : control_state_t := BUF;
    
    signal hist_clk : std_logic := '0';
    signal hist_trigger : std_logic := '0';
    signal num_samples : std_logic_vector(31 downto 0) := (others => '0');  -- Set the number of samples
    
    signal hist_ready : std_logic;
    signal hist_rdout_addr : std_logic_vector(12 downto 0);
    signal hist_out : std_logic_vector(31 downto 0);
    
    signal ch_to_analyze : std_logic_vector(8 downto 0) := (others => '0');
    signal deframed_aligned : arraydata_alladcs(15 downto 0)(31 downto 0)(13 downto 0);
    signal deframed_state : arr8x2;
    
    signal analysis_link_id: integer;
    signal analysis_ch_id: integer;
    signal analysis_cd_id: integer;
    
    signal axi_clk : std_logic := '0';
    signal axi_en : std_logic := '0';
    signal axi_write : std_logic_vector(3 downto 0) := "0000";
    signal axi_wr_addr : std_logic_vector(12 downto 0) := b"0000000000000"; --not actually writing
    signal axi_din : std_logic_vector(31 downto 0);
    signal axi_dout : std_logic_vector(31 downto 0);
    
    signal buf_en : std_logic := '0';
    signal buf_write : std_logic_vector(3 downto 0) := "0000";
    signal buf_addr : std_logic_vector(12 downto 0) := b"0000000000000";
    signal buf_din : std_logic_vector(31 downto 0);
    signal buf_dout : std_logic_vector(31 downto 0);
    
    signal histaxi_en : std_logic := '0';
    signal histaxi_write : std_logic_vector(3 downto 0) := "0000";
    signal histaxi_addr : std_logic_vector(12 downto 0) := b"0000000000000";
    signal histaxi_din : std_logic_vector(31 downto 0);
    signal histaxi_dout : std_logic_vector(31 downto 0);
    
    
    signal trigger: std_logic := '0';
    signal done : std_logic;

begin

    histaxi_en <= buf_en when control = BUF else axi_en;
    histaxi_write <= buf_write when control = BUF else axi_write;
    histaxi_addr <= buf_addr when control = BUF else axi_wr_addr;
    histaxi_din <= buf_din when control = BUF else axi_din;
    
    buf_dout <= histaxi_dout;
    axi_dout <= histaxi_dout;


    dut : entity work.single_ch_buffer
        port map (
            axi_clk => axi_clk,
            trigger => trigger,
            deframed_aligned => deframed_aligned,
            deframed_state => deframed_state,
            ch_to_analyze => ch_to_analyze,
            
            mem_en => buf_en,
            mem_write => buf_write,
            mem_addr => buf_addr,
            mem_din => buf_din,
            mem_dout => buf_dout,
            
            done => done
        );
        
    hist: entity work.histogram
        port map (
            clk => hist_clk,
            trigger => hist_trigger,
            num_samples => num_samples,
            deframed_aligned => deframed_aligned,
            deframed_state => deframed_state,
            ch_to_analyze => ch_to_analyze,
            
            axi_clk => axi_clk,
            axi_en => histaxi_en,
            axi_write => histaxi_write,
            hist_rdout_addr => histaxi_addr,
 
            axi_din => histaxi_din,
            axi_dout => histaxi_dout,
            
            hist_ready => hist_ready,
            
            hist_out => hist_out
        );
        
   --clk gen processes 
      clk125gen: process
        variable seed1 : positive;
        variable seed2 : positive;
        variable rand : real;
        variable delay : integer;
    begin
        --random clock delay
        seed1 := 4120;
        seed2 := 679;
        uniform(seed1, seed2, rand);
        delay := integer(floor(rand * 8));
        report "Clk125 has delay of " & integer'image(delay) & "ns";
        
        -- Clock generation
        wait for delay * 1 ns;
        for i in 1 to 128*10000000 loop  
            hist_clk <= not hist_clk;
            wait for 4 ns; -- Adjust the time delay as needed
        end loop;      
        wait;      
    end process clk125gen;
    
    clk100gen: process
        variable seed1 : positive;
        variable seed2 : positive;
        variable rand : real;
        variable delay : integer;
    begin
        --random clock delay
        seed1 := 124;
        seed2 := 321;
        uniform(seed1, seed2, rand);
        delay := integer(floor(rand * 8));
        report "Clk100 has delay of " & integer'image(delay) & "ns";
        
        -- Clock generation
        --wait for delay * 1 ns;
        for i in 1 to 128*10000000 loop 
            axi_clk <= not axi_clk;
            wait for 5 ns; -- Adjust the time delay as needed
        end loop;   
        wait; 
    end process clk100gen; 
   
   process
   variable val : integer := 0;
   begin
       
        for ch in 0 to 511 loop
            control <= BUF;
            ch_to_analyze <= std_logic_vector(to_unsigned(ch, 9));
            wait for 20 ns;
            
            analysis_link_id <= to_integer(unsigned(ch_to_analyze(8 downto 5)));
            analysis_ch_id <= to_integer(unsigned(ch_to_analyze(4 downto 0)));
            analysis_cd_id <= to_integer(unsigned(ch_to_analyze(8 downto 6)));
            wait for 20 ns;
            
            --hist_rdout_addr <= std_logic_vector(to_unsigned(ch, 14));
            deframed_aligned <= (others => (others => std_logic_vector(to_unsigned(0, 14))));
--            deframed_aligned(analysis_link_id)(analysis_ch_id) <= std_logic_vector(to_unsigned(ch, 14));
            deframed_state <= (others => (others => '0')); -- Set all elements to '0'           
            val := 0;
            trigger <= '1';
            wait for 200 us; --wait for memory to clear
            
            while done = '0' loop

        
        
        
                -- You can control trigger and num_samples as needed here
                
--                num_samples <= 100;  -- Set the desired number of samples
                
                wait for 10 ns;
        
                trigger <= '0';
                deframed_state <= (others => (others => '0')); -- Set all elements to '1'        
        
                wait for 100 ns; -- Simulate more clock cycles
                
    
--                deframed_aligned <= (others => (others => std_logic_vector(to_unsigned(val, 14)))); 
                deframed_aligned(analysis_link_id)(analysis_ch_id) <= std_logic_vector(to_unsigned(val, 14));
                wait for 100 ns; -- Simulate more clock cycles
                
                wait for 100 ns;
                deframed_state <= (others => (others => '1')); -- Set all elements to '1'
                wait for 100 ns;
                val := val + 1;
--                deframed_state <= (others => (others => '0')); -- Set all elements to '1'
--                wait for 100 ns;
--                deframed_state <= (others => (others => '1')); -- Set all elements to '1'
--                -- You can add more test scenarios or wait for a certain condition       
            end loop;
            
            --check all values
            control <= AXI;
            axi_en <= '1';
            wait for 100 ns;            
            for addr in 0 to 8191 loop
--                hist_rdout_addr <= std_logic_vector(to_unsigned(bin, 14));
                axi_wr_addr <= std_logic_vector(to_unsigned(addr, 13));
                
                wait for 10*20 ns;
                
                if axi_dout /= std_logic_vector(to_unsigned(addr*2+1, 16)) & std_logic_vector(to_unsigned(addr*2, 16)) then
--                if hist_out /= std_logic_vector(to_unsigned(0, 32)) then
--                    if bin /= ch then
                    report " Oh no! Ch " & integer'image(ch) & " addr " & integer'image(addr) & " has data " & integer'image(to_integer(unsigned(axi_dout)));
--                    end if;
--                end if;
--                if bin = ch then
--                    report "Ch " & integer'image(ch) & " bin " & integer'image(bin) & " has count " & integer'image(to_integer(unsigned(hist_out)));
                end if;    
                
            end loop;
            
            
            
        end loop;   
   --stim
   end process;
  
  
    

end Behavioral;
