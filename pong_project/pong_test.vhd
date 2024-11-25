--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:07:58 11/18/2024
-- Design Name:   
-- Module Name:   /home/student1/aelgohar/coe758/project_2/pong_project/pong_test.vhd
-- Project Name:  pong_project
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: pong_game
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY pong_test IS
END pong_test;
 
ARCHITECTURE behavior OF pong_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT pong_game
    PORT(
         clock : IN  std_logic;
         h_sync : OUT  std_logic;
         v_sync : OUT  std_logic;
         DAC_clock : OUT  std_logic;
         blue_out : OUT  std_logic_vector(7 downto 0);
         green_out : OUT  std_logic_vector(7 downto 0);
         red_out : OUT  std_logic_vector(7 downto 0);
         SW0 : IN  std_logic;
         SW1 : IN  std_logic;
         SW2 : IN  std_logic;
         SW3 : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clock : std_logic := '0';
   signal SW0 : std_logic := '0';
   signal SW1 : std_logic := '0';
   signal SW2 : std_logic := '0';
   signal SW3 : std_logic := '0';

 	--Outputs
   signal h_sync : std_logic;
   signal v_sync : std_logic;
   signal DAC_clock : std_logic;
   signal blue_out : std_logic_vector(7 downto 0);
   signal green_out : std_logic_vector(7 downto 0);
   signal red_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
   constant DAC_clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pong_game PORT MAP (
          clock => clock,
          h_sync => h_sync,
          v_sync => v_sync,
          DAC_clock => DAC_clock,
          blue_out => blue_out,
          green_out => green_out,
          red_out => red_out,
          SW0 => SW0,
          SW1 => SW1,
          SW2 => SW2,
          SW3 => SW3
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 
   DAC_clock_process :process
   begin
		DAC_clock <= '0';
		wait for DAC_clock_period/2;
		DAC_clock <= '1';
		wait for DAC_clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		

		wait for clock_period;
		SW0 <='0'; 
		SW1 <='0'; 
		SW2 <='0'; 
		SW3 <='0'; 


		wait for clock_period;
		SW0 <='0'; 
		SW1 <='0'; 
		SW2 <='0'; 
		SW3 <='1';


		wait for clock_period;
		SW0 <='0'; 
		SW1 <='0'; 
		SW2 <='1'; 
		SW3 <='0';


		wait for clock_period;
		SW0 <='0'; 
		SW1 <='0'; 
		SW2 <='1'; 
		SW3 <='1';


		wait for clock_period;
		SW0 <='0'; 
		SW1 <='1'; 
		SW2 <='0'; 
		SW3 <='0';


		wait for clock_period;
		SW0 <='0'; 
		SW1 <='1'; 
		SW2 <='0'; 
		SW3 <='1';


		wait for clock_period;
		SW0 <='0'; 
		SW1 <='1'; 
		SW2 <='1'; 
		SW3 <='0';


		wait for clock_period;
		SW0 <='0'; 
		SW1 <='1'; 
		SW2 <='1'; 
		SW3 <='1';


		wait for clock_period;
		SW0 <='1'; 
		SW1 <='0'; 
		SW2 <='0'; 
		SW3 <='0';


		wait for clock_period;
		SW0 <='1'; 
		SW1 <='0'; 
		SW2 <='0'; 
		SW3 <='1';


		wait for clock_period;
		SW0 <='1'; 
		SW1 <='0'; 
		SW2 <='1'; 
		SW3 <='0';


		wait for clock_period;
		SW0 <='1'; 
		SW1 <='0'; 
		SW2 <='1'; 
		SW3 <='1';


		wait for clock_period;
		SW0 <='1'; 
		SW1 <='1'; 
		SW2 <='0'; 
		SW3 <='0';


		wait for clock_period;
		SW0 <='1'; 
		SW1 <='1'; 
		SW2 <='0'; 
		SW3 <='1';


		wait for clock_period;
		SW0 <='1'; 
		SW1 <='1'; 
		SW2 <='1'; 
		SW3 <='0';


		wait for clock_period;
		SW0 <='1'; 
		SW1 <='1'; 
		SW2 <='1'; 
		SW3 <='1';


      wait;
   end process;

END;
