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

package ipbus_decode_udp_core_top_mmap_ipb is

  constant IPBUS_SEL_WIDTH: positive := 2;
  subtype ipbus_sel_t is std_logic_vector(IPBUS_SEL_WIDTH - 1 downto 0);
  function ipbus_sel_udp_core_top_mmap_ipb(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t;

-- START automatically generated VHDL (Sun Mar 13 17:23:45 2022)
  constant N_SLV_UDP_CORE_CONTROL: integer := 0;
  constant N_SLV_ARP_MODE_CONTROL: integer := 1;
  constant N_SLV_FARM_MODE_LUT: integer := 2;
  constant N_SLAVES: integer := 3;
-- END automatically generated VHDL

    
end ipbus_decode_udp_core_top_mmap_ipb;

package body ipbus_decode_udp_core_top_mmap_ipb is

  function ipbus_sel_udp_core_top_mmap_ipb(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t is
    variable sel: ipbus_sel_t;
  begin

-- START automatically generated VHDL (Sun Mar 13 17:23:45 2022)
    if    std_match(addr, "---------------------00---------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_UDP_CORE_CONTROL, IPBUS_SEL_WIDTH)); -- udp_core_control / base 0x00000000 / mask 0x00000600
    elsif std_match(addr, "---------------------01---------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_ARP_MODE_CONTROL, IPBUS_SEL_WIDTH)); -- arp_mode_control / base 0x00000200 / mask 0x00000600
    elsif std_match(addr, "---------------------1----------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_FARM_MODE_LUT, IPBUS_SEL_WIDTH)); -- farm_mode_lut / base 0x00000400 / mask 0x00000400
-- END automatically generated VHDL

    else
        sel := ipbus_sel_t(to_unsigned(N_SLAVES, IPBUS_SEL_WIDTH));
    end if;

    return sel;

  end function ipbus_sel_udp_core_top_mmap_ipb;

end ipbus_decode_udp_core_top_mmap_ipb;

