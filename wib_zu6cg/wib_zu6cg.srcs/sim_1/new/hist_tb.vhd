library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use ieee.math_real.uniform;
use ieee.math_real.floor;

use work.accum_typedef.all;

entity hist_tb is
end hist_tb;

architecture Behavioral of hist_tb is
    signal clk : std_logic := '0';
    signal trigger : std_logic := '0';
    signal num_samples : std_logic_vector(31 downto 0);  -- Set the number of samples
    signal deframed_aligned : arraydata_alladcs(15 downto 0)(31 downto 0)(13 downto 0);
    signal deframed_state : arr8x2;
    signal ch_to_analyze : std_logic_vector(8 downto 0);

    signal hist_ready : std_logic;
    signal hist_rdout_addr : std_logic_vector(13 downto 0);
    signal hist_out : std_logic_vector(31 downto 0);
    
    signal analysis_link_id: integer;
    signal analysis_ch_id: integer;
    signal analysis_cd_id: integer;
    
    signal axi_clk : std_logic := '0';
    signal axi_write : std_logic := '0';
    signal axi_wr_addr : std_logic_vector(13 downto 0) := b"00000000000000";
    signal axi_din : std_logic_vector(31 downto 0);
    signal axi_dout : std_logic_vector(31 downto 0);
    

begin
    uut : entity work.histogram
        port map (
            clk => clk,
            trigger => trigger,
            num_samples => num_samples,
            deframed_aligned => deframed_aligned,
            deframed_state => deframed_state,
            ch_to_analyze => ch_to_analyze,
            
            axi_clk => axi_clk,
            axi_write => axi_write,
            axi_wr_addr => axi_wr_addr,
            hist_rdout_addr => hist_rdout_addr,
            axi_din => axi_din,
            axi_dout => axi_dout,
            
            hist_ready => hist_ready,
            
            hist_out => hist_out
        );

    clk125gen: process
        variable seed1 : positive;
        variable seed2 : positive;
        variable rand : real;
        variable delay : integer;
    begin
        --random clock delay
        seed1 := 420;
        seed2 := 69;
        uniform(seed1, seed2, rand);
        delay := integer(floor(rand * 8));
        report "Clk125 has delay of " & integer'image(delay) & "ns";
        
        -- Clock generation
        wait for delay * 1 ns;
        for i in 1 to 1000 loop  -- Simulate 1000 clock cycles
            clk <= not clk;
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
        seed1 := 1234;
        seed2 := 4321;
        uniform(seed1, seed2, rand);
        delay := integer(floor(rand * 8));
        report "Clk100 has delay of " & integer'image(delay) & "ns";
        
        -- Clock generation
        --wait for delay * 1 ns;
        for i in 1 to 1000 loop  -- Simulate 1000 clock cycles
            axi_clk <= not axi_clk;
            wait for 5 ns; -- Adjust the time delay as needed
        end loop;   
        wait; 
    end process clk100gen;
    
    process
    
    begin
        -- Set your simulation parameters here
        --ch_to_analyze <= "000000100"; -- Binary representation of 4
        deframed_aligned <= (others => (others => std_logic_vector(to_unsigned(0, 14))));
        --num_samples <= 1000;  -- Set the desired number of samples
        axi_din <= x"12344321";
        hist_rdout_addr <= b"00000111111111";
        axi_wr_addr <= b"00000000000010";
        
        wait for 5 * 10 ns;
        axi_write <= '1';
        wait for 1 * 10 ns;
        axi_write <= '0';
        
        wait for 3 * 10 ns;
        hist_rdout_addr <= b"00000000000010";
        wait for 3 * 10 ns;
        report "doutb = 0x" & to_hstring(axi_dout);
        
        
        
        
        
        
/*        for ch in 0 to 511 loop
            ch_to_analyze <= std_logic_vector(to_unsigned(ch, 9));
            wait for 20 ns;
            
            analysis_link_id <= to_integer(unsigned(ch_to_analyze(8 downto 5)));
            analysis_ch_id <= to_integer(unsigned(ch_to_analyze(4 downto 0)));
            analysis_cd_id <= to_integer(unsigned(ch_to_analyze(8 downto 6)));
            wait for 20 ns;
            
            --hist_rdout_addr <= std_logic_vector(to_unsigned(ch, 14));
            deframed_aligned(analysis_link_id)(analysis_ch_id) <= std_logic_vector(to_unsigned(ch, 14));
            deframed_state <= (others => (others => '1')); -- Set all elements to '1'           
            
            trigger <= '1';
            wait for 700 us;
            
            while hist_ready = '0' loop

        
        
        
                -- You can control trigger and num_samples as needed here
                
--                num_samples <= 100;  -- Set the desired number of samples
        
                wait for 10 ns;
        
                trigger <= '0';
                deframed_state <= (others => (others => '0')); -- Set all elements to '1'        
        
                wait for 100 ns; -- Simulate more clock cycles
                
    
                 
                wait for 100 ns; -- Simulate more clock cycles
                
                wait for 100 ns;
                deframed_state <= (others => (others => '1')); -- Set all elements to '1'
                wait for 100 ns;
--                deframed_state <= (others => (others => '0')); -- Set all elements to '1'
--                wait for 100 ns;
--                deframed_state <= (others => (others => '1')); -- Set all elements to '1'
--                -- You can add more test scenarios or wait for a certain condition       
            end loop;
            --check all values
            for bin in 0 to 16383 loop
                hist_rdout_addr <= std_logic_vector(to_unsigned(bin, 14));
                wait for 10*20 ns;
                if hist_out /= std_logic_vector(to_unsigned(0, 32)) then
                    if bin /= ch then
                        report " Oh no! Ch " & integer'image(ch) & " bin " & integer'image(bin) & " has count " & integer'image(to_integer(unsigned(hist_out)));
                    end if;
                end if;
                if bin = ch then
                    report "Ch " & integer'image(ch) & " bin " & integer'image(bin) & " has count " & integer'image(to_integer(unsigned(hist_out)));
                end if;    
                
            end loop;
            
            
            
        end loop;*/

        

        wait;
    end process;
end Behavioral;