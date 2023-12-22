----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/03/2023 05:49:30 PM
-- Design Name: 
-- Module Name: histogram - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.accum_typedef.all;

entity histogram is
  Port (
        clk : in std_logic;
        trigger: in std_logic;
        num_samples : in std_logic_vector(31 downto 0);           
        deframed_aligned : in arraydata_alladcs(15 downto 0)(31 downto 0)(13 downto 0);
        deframed_state : in arr8x2;       
        ch_to_analyze : in std_logic_vector(8 downto 0);
        
        axi_clk : in std_logic;
        axi_write : in std_logic; --debug purposes
        axi_wr_addr : in std_logic_vector(13 downto 0);  
        hist_rdout_addr : in std_logic_vector(13 downto 0);    --axi_rd_addr    
        axi_din : in std_logic_vector(31 downto 0); --debug purposes
        axi_dout : out std_logic_vector(31 downto 0);
        
        hist_ready : out std_logic;        
        hist_out: out std_logic_vector(31 downto 0)
   );
attribute dont_touch : string;
attribute dont_touch of histogram : entity is "true";
end histogram;

architecture Behavioral of histogram is


type hist_state_t is (IDLE, CLEAR_MEM, READ, WRITE, WAIT_FOR_DATA);
signal hist_state : hist_state_t := IDLE;

--type ctrller is (WRITER, READER);
--signal mem_ctrl : ctrller := WRITER;

--memory input signals
signal mem_rst : std_logic := '0'; 
signal mem_rst_busy : std_logic;
signal mem_write : std_logic_vector(0 downto 0) := "0";
signal mem_addr : std_logic_vector(13 downto 0);
signal mem_din : std_logic_vector(31 downto 0); 
signal mem_dout : std_logic_vector(31 downto 0); 

constant mem_read_latency : integer := 2;
signal mem_latency_count : integer;
signal mem_rst_count : integer := 0;

--for synchronization. see process io
signal trigger_s : std_logic := '0';
signal ready_s : std_logic;
signal hist_rdout_ch_s : std_logic_vector(31 downto 0);

--histogram signals
signal samples_taken : unsigned(31 downto 0);
signal samples_to_take : unsigned(31 downto 0);
signal ready : std_logic := '0';
signal analysis_link_id: integer;
signal analysis_ch_id: integer;
signal analysis_cd_id: integer;
signal deframed_data_ready : std_logic;

--axi signals
signal axi_addr : std_logic_vector(13 downto 0);
signal axi_write_delay : std_logic;
signal axi_wr_strb : std_logic;


COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    rsta : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    rsta_busy : OUT STD_LOGIC;
    rstb_busy : OUT STD_LOGIC 
  );
END COMPONENT;

begin



io : process(clk)
begin
    if rising_edge(clk) then
        trigger_s <= trigger;
        ready_s <= ready;
        hist_ready <= ready_s;
        hist_out <= hist_rdout_ch_s;
    end if;
end process io;


fsm: process(clk)
begin
    if rising_edge(clk) then
        case hist_state is
            when IDLE => --readout, etc
                samples_taken <= (others => '0');
                deframed_data_ready <= '0';
                --let user read out memory:
                mem_addr <= hist_rdout_addr; 
                hist_rdout_ch_s <= mem_dout;
                
                if trigger_s = '1' then  
                    mem_addr <= (others => '0');
                    mem_din <= (others => '0');
                    mem_rst_count <= 0;
                    
                    
                    samples_to_take <= unsigned(num_samples);                   
                    analysis_link_id <= to_integer(unsigned(ch_to_analyze(8 downto 5)));
                    analysis_ch_id <= to_integer(unsigned(ch_to_analyze(4 downto 0)));
                    analysis_cd_id <= to_integer(unsigned(ch_to_analyze(8 downto 6)));
                    ready <= '0'; --clear ready flag
                    
                    --hist_state <= READ;   
                    hist_state <= CLEAR_MEM;  
                end if;
            when CLEAR_MEM => --manually clear each register >:(
                --mem_rst <= '1'; 
                mem_write <= "1";
                mem_rst_count <= mem_rst_count + 1;
                if mem_rst_count = 1 then
                   mem_addr <= std_logic_vector(unsigned(mem_addr) + 1);
                   mem_rst_count <= 0; 
                end if;
                
                
                if mem_addr = "11111111111111" then
                    mem_write <= "0";
                    hist_state <= READ;
                end if;
            when READ =>                
--                mem_rst <= '0'; 
                deframed_data_ready <= deframed_state(analysis_cd_id)(0);
--                if mem_rst_busy = '0' then --may not be the case for the first few clock cycles
                if deframed_data_ready = '1' then --deframed data valid + ready                 
                    mem_addr <= deframed_aligned(analysis_link_id)(analysis_ch_id);
                    mem_latency_count <= 0;
                    hist_state <= WRITE;
                end if;
--                end if;
            when WRITE =>
                mem_latency_count <= mem_latency_count + 1;
                if mem_latency_count = 2 then
                    mem_din <= std_logic_vector(unsigned(mem_dout) + 1);
                elsif mem_latency_count = 3 then
                    mem_write <= "1";
                    samples_taken <= samples_taken + 1;
                    deframed_data_ready <= deframed_state(analysis_cd_id)(0);
                    hist_state <= WAIT_FOR_DATA;
                    
                end if; 
            when WAIT_FOR_DATA =>
                mem_write <= "0";
                deframed_data_ready <= deframed_state(analysis_cd_id)(0);
                if samples_taken >= samples_to_take then
                    ready <= '1';
                    mem_addr <= hist_rdout_addr; 
                    hist_rdout_ch_s  <= mem_dout;                    
                    hist_state <= IDLE;                     
                elsif deframed_data_ready <= '0' then
                    hist_state <= READ;
                end if;
        end case;
    end if;
end process fsm;

/*hist_mem : blk_mem_gen_0
  PORT MAP (
    clka => clk,
    rsta => mem_rst,
    ena => '1',
    wea => mem_write,
    addra => mem_addr,
    dina => mem_din,
    douta => mem_dout,
    rsta_busy => mem_rst_busy
  );*/


axi_wr_strb <= axi_write or axi_write_delay;
axi_addr <= axi_wr_addr when axi_wr_strb = '1' else hist_rdout_addr;

extend_wrstrb : process(axi_clk)
begin
    if rising_edge(axi_clk) then
        if axi_write = '1' then
            axi_write_delay <= '1';
        else
            axi_write_delay <= '0';
        end if;       
    end if;
end process extend_wrstrb;

hist_mem : blk_mem_gen_0
  PORT MAP (
    clka => clk,
    rsta => mem_rst,
    ena => '1',
    wea => mem_write,
    addra => mem_addr,
    dina => mem_din,
    douta => mem_dout,
    
    clkb => axi_clk,
    enb => ready, --only let AXI bus read stuff when histogram is done
    web => (others => axi_wr_strb),
    addrb => axi_addr,
    dinb => axi_din, --for debug purposes
    doutb => axi_dout,
    
    rsta_busy => mem_rst_busy,
    rstb_busy => open --not used
  );

end Behavioral;
