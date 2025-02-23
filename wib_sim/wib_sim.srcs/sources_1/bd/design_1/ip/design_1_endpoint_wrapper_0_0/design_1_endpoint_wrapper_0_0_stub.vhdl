-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1.1_AR73018 (win64) Build 2960000 Wed Aug  5 22:57:20 MDT 2020
-- Date        : Fri Nov 27 04:06:51 2020
-- Host        : uf-eng-srv-1 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/madorsky/github/wib_sim/wib_sim/wib_sim.srcs/sources_1/bd/design_1/ip/design_1_endpoint_wrapper_0_0/design_1_endpoint_wrapper_0_0_stub.vhdl
-- Design      : design_1_endpoint_wrapper_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xczu9eg-ffvb1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_endpoint_wrapper_0_0 is
  Port ( 
    sclk : in STD_LOGIC;
    srst : in STD_LOGIC;
    addr : in STD_LOGIC_VECTOR ( 7 downto 0 );
    tgrp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    stat : out STD_LOGIC_VECTOR ( 3 downto 0 );
    rec_clk : in STD_LOGIC;
    rec_d : in STD_LOGIC;
    sfp_los : in STD_LOGIC;
    cdr_los : in STD_LOGIC;
    cdr_lol : in STD_LOGIC;
    clk : out STD_LOGIC;
    rst : out STD_LOGIC;
    rdy : out STD_LOGIC;
    sync : out STD_LOGIC_VECTOR ( 3 downto 0 );
    sync_stb : out STD_LOGIC;
    sync_first : out STD_LOGIC;
    tstamp : out STD_LOGIC_VECTOR ( 63 downto 0 )
  );

end design_1_endpoint_wrapper_0_0;

architecture stub of design_1_endpoint_wrapper_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "sclk,srst,addr[7:0],tgrp[1:0],stat[3:0],rec_clk,rec_d,sfp_los,cdr_los,cdr_lol,clk,rst,rdy,sync[3:0],sync_stb,sync_first,tstamp[63:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "endpoint_wrapper,Vivado 2020.1.1_AR73018";
begin
end;
