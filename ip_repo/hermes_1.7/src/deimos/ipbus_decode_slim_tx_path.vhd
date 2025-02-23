-- Address decode logic for ipbus fabric
-- 
-- This file has been AUTOGENERATED from the address table - do not hand edit
-- 
-- We assume the synthesis tool is clever enough to recognise exclusive conditions
-- in the if statement.
-- 
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package ipbus_decode_slim_tx_path is

  constant IPBUS_SEL_WIDTH: positive := 3;
  subtype ipbus_sel_t is std_logic_vector(IPBUS_SEL_WIDTH - 1 downto 0);
  function ipbus_sel_slim_tx_path(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t;

-- START automatically generated VHDL (Mon Feb 13 18:10:41 2023)
  constant N_SLV_UDP_CORE_0: integer := 0;
  constant N_SLV_UDP_CORE_1: integer := 1;
  constant N_SLV_UDP_CORE_2: integer := 2;
  constant N_SLV_UDP_CORE_3: integer := 3;
  constant N_SLV_DEBUG: integer := 4;
  constant N_SLV_FREQ: integer := 5;
  constant N_SLAVES: integer := 6;
-- END automatically generated VHDL

    
end ipbus_decode_slim_tx_path;

package body ipbus_decode_slim_tx_path is

  function ipbus_sel_slim_tx_path(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t is
    variable sel: ipbus_sel_t;
  begin

-- START automatically generated VHDL (Mon Feb 13 18:10:41 2023)
    if    std_match(addr, "-----------------------000------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_UDP_CORE_0, IPBUS_SEL_WIDTH)); -- udp_core_0 / base 0x00000000 / mask 0x000001c0
    elsif std_match(addr, "-----------------------001------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_UDP_CORE_1, IPBUS_SEL_WIDTH)); -- udp_core_1 / base 0x00000040 / mask 0x000001c0
    elsif std_match(addr, "-----------------------010------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_UDP_CORE_2, IPBUS_SEL_WIDTH)); -- udp_core_2 / base 0x00000080 / mask 0x000001c0
    elsif std_match(addr, "-----------------------011------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_UDP_CORE_3, IPBUS_SEL_WIDTH)); -- udp_core_3 / base 0x000000c0 / mask 0x000001c0
    elsif std_match(addr, "-----------------------100-0----") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_DEBUG, IPBUS_SEL_WIDTH)); -- debug / base 0x00000100 / mask 0x000001d0
    elsif std_match(addr, "-----------------------100-1----") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_FREQ, IPBUS_SEL_WIDTH)); -- freq / base 0x00000110 / mask 0x000001d0
-- END automatically generated VHDL

    else
        sel := ipbus_sel_t(to_unsigned(N_SLAVES, IPBUS_SEL_WIDTH));
    end if;

    return sel;

  end function ipbus_sel_slim_tx_path;

end ipbus_decode_slim_tx_path;

