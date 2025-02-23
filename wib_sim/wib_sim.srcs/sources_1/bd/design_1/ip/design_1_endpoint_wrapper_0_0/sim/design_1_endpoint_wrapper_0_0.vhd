-- (c) Copyright 1995-2020 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: user.org:user:endpoint_wrapper:1.0
-- IP Revision: 4

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY design_1_endpoint_wrapper_0_0 IS
  PORT (
    sclk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    tgrp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    stat : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    rec_clk : IN STD_LOGIC;
    rec_d : IN STD_LOGIC;
    sfp_los : IN STD_LOGIC;
    cdr_los : IN STD_LOGIC;
    cdr_lol : IN STD_LOGIC;
    clk : OUT STD_LOGIC;
    rst : OUT STD_LOGIC;
    rdy : OUT STD_LOGIC;
    sync : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    sync_stb : OUT STD_LOGIC;
    sync_first : OUT STD_LOGIC;
    tstamp : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
  );
END design_1_endpoint_wrapper_0_0;

ARCHITECTURE design_1_endpoint_wrapper_0_0_arch OF design_1_endpoint_wrapper_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF design_1_endpoint_wrapper_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT endpoint_wrapper IS
    PORT (
      sclk : IN STD_LOGIC;
      srst : IN STD_LOGIC;
      addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      tgrp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      stat : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      rec_clk : IN STD_LOGIC;
      rec_d : IN STD_LOGIC;
      sfp_los : IN STD_LOGIC;
      cdr_los : IN STD_LOGIC;
      cdr_lol : IN STD_LOGIC;
      clk : OUT STD_LOGIC;
      rst : OUT STD_LOGIC;
      rdy : OUT STD_LOGIC;
      sync : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      sync_stb : OUT STD_LOGIC;
      sync_first : OUT STD_LOGIC;
      tstamp : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
  END COMPONENT endpoint_wrapper;
  ATTRIBUTE IP_DEFINITION_SOURCE : STRING;
  ATTRIBUTE IP_DEFINITION_SOURCE OF design_1_endpoint_wrapper_0_0_arch: ARCHITECTURE IS "package_project";
BEGIN
  U0 : endpoint_wrapper
    PORT MAP (
      sclk => sclk,
      srst => srst,
      addr => addr,
      tgrp => tgrp,
      stat => stat,
      rec_clk => rec_clk,
      rec_d => rec_d,
      sfp_los => sfp_los,
      cdr_los => cdr_los,
      cdr_lol => cdr_lol,
      clk => clk,
      rst => rst,
      rdy => rdy,
      sync => sync,
      sync_stb => sync_stb,
      sync_first => sync_first,
      tstamp => tstamp
    );
END design_1_endpoint_wrapper_0_0_arch;
