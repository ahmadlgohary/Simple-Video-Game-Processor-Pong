-------------------------------------------------------------------------------
-- Copyright (c) 2024 Xilinx, Inc.
-- All Rights Reserved
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor     : Xilinx
-- \   \   \/     Version    : 13.4
--  \   \         Application: XILINX CORE Generator
--  /   /         Filename   : icon.vhd
-- /___/   /\     Timestamp  : Mon Nov 18 17:59:56 EST 2024
-- \   \  /  \
--  \___\/\___\
--
-- Design Name: VHDL Synthesis Wrapper
-------------------------------------------------------------------------------
-- This wrapper is used to integrate with Project Navigator and PlanAhead

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY icon IS
  port (
    CONTROL0: inout std_logic_vector(35 downto 0));
END icon;

ARCHITECTURE icon_a OF icon IS
BEGIN

END icon_a;
