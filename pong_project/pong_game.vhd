----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 16:17:10 11/09/2024
-- Design Name:
-- Module Name: pong_game - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY pong_game IS
	PORT (
		-- Clock Signal to synchronize all modules
		clock : IN STD_LOGIC;		
		
		-- VGA sync and DAC clock outputs
		h_sync : OUT STD_LOGIC;
		v_sync : OUT STD_LOGIC;
		DAC_clock : OUT STD_LOGIC;
		
		-- RGB colouroutput for VGA display
		blue_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		green_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		red_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		
		-- Paddle control switches
		SW0 : IN STD_LOGIC; 		-- switch 0 moves blue paddle
		SW1 :	IN STD_LOGIC; 		-- switch 1 enable blue paddle to move
		SW2 : IN STD_LOGIC; 		-- switch 2 moves red paddle
		SW3 :	IN STD_LOGIC 		-- switch 3 enable red paddle to move
	); 
END pong_game;

ARCHITECTURE Behavioral OF pong_game IS

	---------------------------------------------------------
	-- ChipScope components and signals.
	---------------------------------------------------------
	COMPONENT icon
	PORT (
	CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT ila
	PORT (
	CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
	CLK : IN STD_LOGIC;
	DATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	TRIG0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	END COMPONENT;
	
	SIGNAL control0 : STD_LOGIC_VECTOR(35 DOWNTO 0);
	SIGNAL ila_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL trig0 : STD_LOGIC_VECTOR(7 DOWNTO 0);

	---------------------------------------------------------
	-- System components and signals.
	---------------------------------------------------------


	-- Horizontal sync counter (H-counter for VGA)
	SIGNAL horizontal_counter : INTEGER RANGE 0 TO 799;

	-- Vertical sync counter (V-counter for VGA)
	SIGNAL vertical_counter : INTEGER RANGE 0 TO 524;

	-- Pixel Clock Counter
	SIGNAL pixel_clock : std_logic;

	-- Refresh Rate Counter
	SIGNAL refresh_clock : std_logic;
	SIGNAL refresh_counter : INTEGER := 0;

	-- RGB output signals for the VGA display
	SIGNAL red_colour: std_logic_vector(7 DOWNTO 0);
	SIGNAL green_colour : std_logic_vector(7 DOWNTO 0);
	SIGNAL blue_colour : std_logic_vector(7 DOWNTO 0);

	-- Top-left boundary coordinates
	SIGNAL top_left_x1 : INTEGER := 10;
	SIGNAL top_left_x2 : INTEGER := 20;
	SIGNAL top_left_y1 : INTEGER := 10;
	SIGNAL top_left_y2 : INTEGER := 160;

	-- Top horizontal boundary coordinates
	SIGNAL top_horizontal_x1 : INTEGER := 10;
	SIGNAL top_horizontal_x2 : INTEGER := 630;
	SIGNAL top_horizontal_y1 : INTEGER := 10;
	SIGNAL top_horizontal_y2 : INTEGER := 20;

	-- Top-right boundary coordinate
	SIGNAL top_right_x1 : INTEGER := 620;
	SIGNAL top_right_x2 : INTEGER := 630;
	SIGNAL top_right_y1 : INTEGER := 10;
	SIGNAL top_right_y2 : INTEGER := 160;

	-- Bottom-left boundary coordinates
	SIGNAL bottom_left_x1 : INTEGER := 10;
	SIGNAL bottom_left_x2 : INTEGER := 20;
	SIGNAL bottom_left_y1 : INTEGER := 300;
	SIGNAL bottom_left_y2 : INTEGER := 470;

	-- Bottom horizontal boundary coordinates
	SIGNAL bottom_horizontal_x1 : INTEGER := 10;
	SIGNAL bottom_horizontal_x2 : INTEGER := 630;
	SIGNAL bottom_horizontal_y1 : INTEGER := 460;
	SIGNAL bottom_horizontal_y2 : INTEGER := 470;

	-- Bottom-right boundary coordinates
	SIGNAL bottom_right_x1 : INTEGER := 620;
	SIGNAL bottom_right_x2 : INTEGER := 630;
	SIGNAL bottom_right_y1 : INTEGER := 300;
	SIGNAL bottom_right_y2 : INTEGER := 470;

	-- Mid-field center line coordinates
	SIGNAL middle_line_x1 : INTEGER := 316;
	SIGNAL middle_line_x2 : INTEGER := 324;
	SIGNAL middle_line_y1 : INTEGER := 30;
	SIGNAL middle_line_y2 : INTEGER := 450;

	-- Red paddle dimensions
	SIGNAL red_paddle_x1 : INTEGER := 600;
	SIGNAL red_paddle_x2 : INTEGER := 615;
	SIGNAL red_paddle_y1 : INTEGER := 200;
	SIGNAL red_paddle_y2 : INTEGER := 275;


	-- Blue paddle dimensions
	SIGNAL blue_paddle_x1 : INTEGER := 25; 
	SIGNAL blue_paddle_x2 : INTEGER := 40; 
	SIGNAL blue_paddle_y1 : INTEGER := 200;
	SIGNAL blue_paddle_y2 : INTEGER := 275;


	-- Ball dimensions
	SIGNAL ball_x1 : INTEGER := 310;
	SIGNAL ball_x2 : INTEGER := 325;
	SIGNAL ball_y1 : INTEGER := 230;
	SIGNAL ball_y2 : INTEGER := 245;

	-- Goal line coordinates for red and blue paddles
	SIGNAL red_goal_x : INTEGER := 625;
	SIGNAL blue_goal_x : INTEGER := 15;

	--Flags for score detection and reset
	SIGNAL score_flag : std_logic;
	SIGNAL reset_flag : std_logic;

	-- Ball direction flags (X and Y direction)
	SIGNAL ball_x_direction : std_logic;
	SIGNAL ball_y_direction : std_logic;
	SIGNAL ball_x_direction_int: INTEGER;
	SIGNAL ball_y_direction_int: INTEGER;

BEGIN

	---------------------------------------------------------
	-- ChipScope components.
	---------------------------------------------------------
	sys_icon : icon
	PORT MAP (
	CONTROL0 => control0
	);
	sys_ila : ila
	PORT MAP (
	CONTROL => control0,
	CLK => clock,
	DATA => ila_data,
	TRIG0 => trig0
	);
	
	---------------------------------------------------------
	-- System components.
	---------------------------------------------------------

	-- Pixel clock module
	-- Pixel clock generation (25 MHz using a 50 MHz system clock)
	PROCESS (clock)
	BEGIN
		-- Pixel clock is generated
		-- Pixel clock's value changes on every rising edge of the main clock
		-- This means the pixel clock has half the frequency of the main clock
		IF rising_edge(clock) THEN
			pixel_clock <= NOT(pixel_clock); 		
		END IF;
	END PROCESS;

	-- Assigning the pixel clock to the DAC_clock output
	DAC_clock <= pixel_clock;

	-- H-sync and V-sync counter setup for VGA
	PROCESS (pixel_clock, horizontal_counter, vertical_counter) 
	BEGIN
		IF rising_edge(pixel_clock)THEN

			-- horizontal counts from 0 to 799
			horizontal_counter <= horizontal_counter + 1;
			-- if the horizontal_counter is 799 then increment the vertical counter
			-- and reset the horizontal counter to 0 to start a new line
			IF (horizontal_counter = 799) THEN
				vertical_counter <= vertical_counter + 1;
				horizontal_counter <= 0;
			END IF;
			
			-- vertical counts from 0 to 524
			-- if vertical counter is 524 then reset it to 0
			IF (vertical_counter = 524) THEN
				vertical_counter <= 0;
			END IF;
		END IF;
	END PROCESS;
 
	-- H-sync and V-sync signal intitilization 
	-- they are low only during the sync pulse
	h_sync <= '0' WHEN horizontal_counter <= 96 ELSE '1';
	v_sync <= '0' WHEN vertical_counter <= 2 ELSE '1';

	-- Display colouroutput when in the active region
	PROCESS BEGIN
			IF (horizontal_counter >= 143 AND horizontal_counter <= 783 AND vertical_counter >= 34 AND vertical_counter <= 514) THEN
				red_out <= red_colour;
				green_out <= green_colour;
				blue_out <= blue_colour;
			ELSE
				red_out <= (OTHERS => '0');
				green_out <= (OTHERS => '0');
				blue_out <= (OTHERS => '0');
			END IF;
	END PROCESS;

	-- Refresh rate clock generation for game movement
	PROCESS (pixel_clock) BEGIN
		-- Refresh clock module
		IF rising_edge(pixel_clock) THEN		
			-- Check if the refresh counter has reached the threshold of 416667 cycles.
			-- This threshold is calculated to create a clock that toggles around 60 Hz given the 25 MHz pixel clock. 
			-- (25,000,000 Hz / 416,667 is approximately 60 Hz)
			IF (refresh_counter >= 416667) THEN
				-- Refresh clock's value changes on every rising edge of the Pixle clock,  This is used to update elements
				refresh_clock <= NOT(refresh_clock);
				-- Reset the counter
				refresh_counter <= 0;
			ELSE
				-- Increment the refresh counter
				refresh_counter <= refresh_counter + 1;
			END IF;
		END IF;
	END PROCESS;

	--Ball movement and collision detection
	PROCESS (refresh_clock) BEGIN
	
		IF rising_edge(refresh_clock) THEN

			--Wall and paddle collision detection
			IF  --Ball hits top-left boundary
				(ball_x1 <= top_left_x2 + 10 AND (ball_y1 >= top_horizontal_y2 AND ball_y2 <= top_right_y2 + 2))  
				OR
				--Ball hits bottom-left boundary
				(ball_x1 <= bottom_left_x2 + 10 AND (ball_y1 >= bottom_right_y1 - 2 AND ball_y2 <= bottom_right_y2)) 
				OR
				-- Blue Paddle Collision 
				(ball_x2 >= blue_paddle_x1 AND ball_x1 <= blue_paddle_x2 AND -- X-axis overlap with blue paddle
				 ball_y2 >= blue_paddle_y1 AND ball_y1 <= blue_paddle_y2) 	 -- Y-axis overlap with blue paddle
				THEN
					--Ball has hit a boundry on the left, send ball to positive x direction
					ball_x_direction <= '1';
			ELSIF 
					--Ball hits top-right boundary
					(ball_x2 >= top_right_x1 - 7 AND (ball_y2 >= top_horizontal_y2 AND ball_y1 <= top_right_y2)) 
					OR
					--Ball hits bottom-right boundary
					(ball_x2 >= bottom_right_x1 - 7 AND (ball_y2 >= bottom_left_y1 AND ball_y1 <= bottom_right_y2))
					OR
					-- Red Paddle Collision 
					(ball_x2 >= red_paddle_x1 AND ball_x1 <= red_paddle_x2 AND -- X-axis overlap with red paddle
					ball_y2 >= red_paddle_y1 AND ball_y1 <= red_paddle_y2) 	  -- Y-axis overlap with red paddle
					THEN
						--Ball has hit a boundry on the right, send ball to negative x direction
						ball_x_direction <= '0';
			END IF;

			--Ball has hit top boundary; send ball in negative y direction			
			IF (ball_y1 <= top_horizontal_y2 + 7) THEN
				ball_y_direction <= '0';
				
			--Ball has hit bottom boundary; send ball in positive y direction
			ELSIF (ball_y2 >= bottom_horizontal_y1 - 7) THEN
				ball_y_direction <= '1';
			END IF;
		
			-- These two statements are seperated to allow the ball's colourto change to red in the next cycles
			-- Goal collision detection
			IF (ball_x1 < blue_goal_x 	--Ball reaches left goal line; red paddle scores
			OR ball_x2 > red_goal_x		--Ball reaches right goal line; blue paddle scores
			) 
			THEN
				score_flag <= '1';
			ELSE --Otherwise, if none of the conditions have been met, there is no scoring
				score_flag <= '0';
			END IF;
			
			IF (ball_x1 <= 5 or ball_x2 >= 635) THEN
				--Ball has reached end of screen (left, right); reset_flag ball location
				ball_x1 <= 310;
				ball_x2 <= 325;
				ball_y1 <= 230;
				ball_y2 <= 245;
				ball_y_direction <= '1';
				-- flip direction
				ball_x_direction <= NOT(ball_x_direction);
			ELSE

				--Ball movement
				-- https://stackoverflow.com/questions/34039510/std-logic-to-integer-conversion
				ball_x_direction_int <= conv_integer(ball_x_direction);
				ball_y_direction_int <= conv_integer(ball_y_direction); 
				
				
				--Move ball in x direction
				-- This will add 6 if the ball_x_direction_int  is '1'
				-- and subtact 6 if the ball_x_direction_int  is '0'
				ball_x1 <= ball_x1 + 6 * ((ball_x_direction_int * 2) - 1);
				ball_x2 <= ball_x2 + 6 * ((ball_x_direction_int * 2) - 1);
				
				--Move ball in positive y direction
				-- This will add 6 if the ball_x_direction_int  is '0'
				-- and subtact 6 if the ball_x_direction_int  is '1'
				ball_y1 <= ball_y1 - 6 * ((ball_y_direction_int * 2) - 1);
				ball_y2 <= ball_y2 - 6 * ((ball_y_direction_int * 2) - 1);
			
			END IF;

		END IF;
	END PROCESS;
				
	--Paddle movement and collision detection
	PROCESS (refresh_clock)
	BEGIN
	
		IF rising_edge(refresh_clock) THEN
		
			-- Move the blue paddle based on the state of SW0 (up or down)
			IF (SW0 = '1' AND SW1 = '1' AND  blue_paddle_y1 > top_horizontal_y2) THEN
			
			-- Move blue paddle up if within the top boundary
				blue_paddle_y1 <= blue_paddle_y1 - 10;
				blue_paddle_y2 <= blue_paddle_y2 - 10;
			ELSIF (SW0 = '0' AND SW1 = '1' AND blue_paddle_y2 < bottom_horizontal_y1) THEN

				-- Move blue paddle down if within the bottom boundary
				blue_paddle_y1 <= blue_paddle_y1 + 10;
				blue_paddle_y2 <= blue_paddle_y2 + 10;
			END IF;

			-- Move the red paddle based on the state of SW1 (up or down)
			IF (SW2 = '1' AND SW3 = '1' AND red_paddle_y1 > top_horizontal_y2) THEN
				   
					--Move red paddle up if within the top boundary
					red_paddle_y1 <= red_paddle_y1 - 10;
					red_paddle_y2 <= red_paddle_y2 - 10;
			ELSIF (SW2 = '0' AND SW3 = '1' AND red_paddle_y2 < bottom_horizontal_y1) THEN
					
					-- Move red paddle down if within the bottom boundary
					red_paddle_y1 <= red_paddle_y1 + 10;
					red_paddle_y2 <= red_paddle_y2 + 10;
			END IF;
		END IF;
	END PROCESS;

	--Display VGA Controller
	PROCESS (horizontal_counter, vertical_counter)
		VARIABLE x : INTEGER RANGE 0 TO 639;
		VARIABLE y : INTEGER RANGE 0 TO 479;
		BEGIN
			x := horizontal_counter - 143;
			y := vertical_counter - 34;
			--Every pixel that isn't an object on the screen is set to display green
			--colour: #1e6f1e
			red_colour<= "00011110";
			green_colour <= "01101111";
			blue_colour <= "00011110";
			
			--Displaying the ball
			IF (x > ball_x1 AND x < ball_x2 AND y > ball_y1 AND y < ball_y2) THEN
			
				--Changing the ball colour to red when either side has scored
				IF (score_flag = '1') THEN
					-- colour: #dc143c
					red_colour<= "11011100";
					green_colour <= "00010100";
					blue_colour <= "00111100";
				ELSE
					-- colour: #ffd700
					red_colour<= "11111111";
					green_colour <= "11010111";
					blue_colour <= "00000000";
				END IF;

				--Displaying the boundaries of the field
			ELSIF
				-- TOP Left Vertical Bar
				(x > top_left_x1 AND x < top_left_x2 AND y > top_left_y1 AND y < top_left_y2)
				OR
				-- TOP Horizontal Bar
				(x > top_horizontal_x1 AND x < top_horizontal_x2 AND y > top_horizontal_y1 AND y < top_horizontal_y2)
				OR
				-- TOP Right Vertical Bar
				(x > top_right_x1 AND x < top_right_x2 AND y > top_right_y1 AND y < top_right_y2)
				OR
				-- Bottom Left Vertical Bar
				(x > bottom_left_x1 AND x < bottom_left_x2 AND y > bottom_left_y1 AND y < bottom_left_y2)
				OR
				-- TOP Vertical Bar
				(x > bottom_horizontal_x1 AND x < bottom_horizontal_x2 AND y > bottom_horizontal_y1 AND y < bottom_horizontal_y2)
				OR
				-- Bottom Right Vertical Bar
				(x > bottom_right_x1 AND x < bottom_right_x2 AND y > bottom_right_y1 AND y < bottom_right_y2)
				THEN
				-- colour: #2F2F2F
					red_colour<= "00101111";
					green_colour <= "00101111";
					blue_colour <= "00101111";

			-- Middle Line
			ELSIF (x > middle_line_x1 AND x < middle_line_x2 AND y > middle_line_y1 AND y < middle_line_y2) THEN
				-- This if statement is used to make the line dashed
				IF (y MOD 64 > 31) THEN
					-- colour: #F8F8FF
					red_colour<= "11111000";
					green_colour <= "11111000";
					blue_colour <= "11111111";
				END IF;

			--Displaying the paddles
			ELSIF (x > red_paddle_x1 AND x < red_paddle_x2 AND y > red_paddle_y1 AND y < red_paddle_y2) THEN
				--Red paddle
				-- colour: #ff4040
				red_colour<= "11111111";
				green_colour <= "01000000";
				blue_colour <= "01000000";


			ELSIF (x > blue_paddle_x1 AND x < blue_paddle_x2 AND y > blue_paddle_y1 AND y < blue_paddle_y2) THEN
				--Blue paddle
				-- colour: #1e90ff
				red_colour<= "00011110";
				green_colour <= "10010000";
				blue_colour <= "11111111";
			END IF;
	END PROCESS;
	
	---------------------------------------------------------
	-- ChipScope Signals.
	---------------------------------------------------------
	ila_data(0) <= '0';
	ila_data(1) <= pixel_clock;
	ila_data(2) <= '0' WHEN horizontal_counter <= 96 ELSE '1';
	ila_data(3) <= '0' WHEN vertical_counter <= 2 ELSE '1';
	ila_data(14 DOWNTO 7) <= red_colour;
	ila_data(22 DOWNTO 15) <= green_colour;
	ila_data(30 DOWNTO 23) <= blue_colour;
	ila_data(31) <= '0';
	

END behavioral;

