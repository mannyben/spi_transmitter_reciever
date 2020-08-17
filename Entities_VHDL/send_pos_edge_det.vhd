
--Emmanuel Benard, David Man (111441237,111940002) 
--ESE 382 Lab 08 task_1 
--send_pos_edge_det.vhd


--Context Clasues for Libraries needed
library ieee; 
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.all;



entity send_pos_edge_det is 
	port ( 
		rst_bar : in std_logic; --asynchronus system reset 
		clk: in std_logic;   	 --system clock
		send : in std_logic; 	 --debounced send input 
		send_en : out std_logic  --narrow send en. output pulse  
		);
	end send_pos_edge_det;
	

--Architecture Definition
--moore-fsm - A moore-fsm design of a positive edge detector to bypass level detection of send signal 

architecture moore_fsm of send_pos_edge_det is 
		type state is (state_a, state_b, state_c);	--creating enum 'state' w/ 3 different possible states  
		signal present_state, next_state : state;
	begin
		
		--Process that preforms fxn of a state register
		state_reg: process (clk, rst_bar)
		begin 
			if rst_bar = '0' then 
				present_state <= state_a;
			elsif rising_edge(clk) then 
				present_state <= next_state; 
			end if;
		 end process; 
		 
		--Process to determine outputs depending on the current state 

		 outputs: process (present_state) 
		 begin
			 case present_state is 
				 when state_c => send_en <= '1';
				 when others => send_en <= '0';
			 end case;
		    end process; 
			  
		 
		
		--Process to determine the next state depending on current state and current value of send signal
				 
	     nxt_state: process (present_state, send) 
		 begin 
			 case present_state is
				 when state_a => 
				 if send = '0' then 
					 next_state <= state_b;
				 else 
					 next_state <= state_a;
				 end if;
				 
				 when state_b => 
				 if send = '1' then 
					 next_state <= state_c;
				 else 
					 next_state <= state_b;
				 end if; 
				 
				 when others =>   
				 	if send = '0' then 
						 next_state <= state_b; 
				  	 else 
						 next_state <= state_a;
					 end if;
				end case; 
				end process; 
				end moore_fsm;
		




