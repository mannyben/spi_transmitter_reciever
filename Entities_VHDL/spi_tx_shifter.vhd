
 --Emmanuel Benard, David Man (111441237,111940002)
--ESE 382 Lab 08 task_2
--spi_tx_shifter.vhd
  


--Context Clasues for libraries needed
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all ;
library work;
use work.all; 



entity spi_tx_shifter is 
	port(	
		signal rst_bar : in std_logic; 					-- asynchronous system reset
		signal clk : in std_logic;						-- system clock
		signal send_en : in std_logic; 					-- enable data transmission
		signal data_in : in std_logic_vector(7 downto 0); -- data to send   
		signal cpha : in std_logic;						-- clock phase 
		signal cpol : std_logic;						-- clock polarity	
		signal dord : in std_logic;						-- data order					  
		signal txd : out std_logic; 					-- serial output data 
		signal sck : out std_logic; 					-- synchronous shift clock
		signal ss_bar : out std_logic;					-- slave select
		signal spi_rxen : out std_logic 				--enable reciever to shift data  
		); 				    
end spi_tx_shifter; 											   



--Architecture defintion
--fsm - A 3 process fsm that generates the system_clock pulse, which determines when
		--data is read and when it is shifted
	
architecture fsm of spi_tx_shifter is
 type state is (idle, ph0_1, ph0_2,ph1_1, ph1_2); --2 groups of ph1+ph2, one for CPHA = 0 and another for CPOL = 1 
signal present_state, next_state : state; 
signal bit_addr : unsigned(2 downto 0);			  --variable that will represent the current index of data vector to read from 
												  --and when to return to idle state


begin 
	
	--SPI_RXEN starts at '0'
	--spi_rxen <= '0';

	  --Process that preforms fxn of a state register 

	state_reg: process (clk, rst_bar) 
		begin 
			if rst_bar = '0' then 
				present_state <= idle; 
			elsif rising_edge(clk) then 
				present_state <= next_state; 
			end if; 
		end process; 		   
		
     
	 --Process to determine the next state depending on current state
	 --and the vaules of send_en and bit_addr
	 
	 nxt_state: process (present_state, send_en, bit_addr) 
	 	begin 
	 		case present_state is 
			 	when idle => 
					if send_en = '1' and cpha = '0' then 
				 		next_state <= ph0_1; 
					elsif send_en = '1' and cpha = '1' then	
						next_state <= ph1_1;
					else 
				 		next_state <= idle; 
				 	end if;
				when ph0_1 => 
					next_state <= ph0_2; 
				when ph0_2 => 
					if bit_addr = "000" and dord = '0' then 
						next_state <= idle; 
					elsif bit_addr = "111" and dord = '1' then 
						next_state <= idle; 
					else
						next_state <= ph0_1; 
					end if; 
				when ph1_1 =>  
						next_state <= ph1_2; 
				when ph1_2 => 
					if bit_addr = "000" and dord = '0' then 
						next_state <= idle;	
					elsif bit_addr = "111" and dord = '1' then 
						next_state <= idle;
					else
						next_state <= ph1_1; 
					end if;
			end case; 
		end process;
		
		
	 --Process to determine the data o/p depending on current state and bit_addr index value 
	 
		output: process (present_state, data_in, bit_addr) 
		begin 		

		  case present_state is 
			when idle =>  
				spi_rxen <= '0';
				sck <= cpol; 
				ss_bar <= '1'; 
				txd <= data_in(to_integer(bit_addr)); 
			when ph0_1 => 
				sck <= cpol; 
				ss_bar <= '0'; 
				spi_rxen <= '1';
				txd <= data_in(to_integer(bit_addr)); 
			when ph0_2 => 
				sck <= not cpol; 
				ss_bar <= '0'; 
				txd <= data_in(to_integer(bit_addr));
				spi_rxen <= '0';			
			when ph1_1 => 								   
				sck <= not cpol; 
				ss_bar <= '0';
				spi_rxen <= '1';
				txd <= data_in(to_integer(bit_addr));
			when ph1_2 => 
				sck <= cpol; 
				ss_bar <= '0';
				spi_rxen <= '0';
				txd <= data_in(to_integer(bit_addr));
			end case; 

		end process;  
		
		
	 --Process to determine whether bit adder should be decremented, stay the same, or reset to '111'
	 --depending on the current state, value of rst_bar and the rising clock edge 
	 
	bit_counter: process (rst_bar, clk, present_state)		
	begin 	
		
		if dord = '0' then
				if rst_bar = '0' or present_state = idle then 
					bit_addr <= "111";
				elsif rising_edge(clk) then
					if present_state = ph0_2 then 
						if bit_addr /= "000" then 
							bit_addr <= bit_addr - 1; 
						end if;  
					elsif present_state = ph1_2 then 
						if bit_addr /= "000" then 
							bit_addr <= bit_addr - 1; 
						end if; 
					end if; 
				end if; 
		end if;
			
		if dord = '1' then 
				if rst_bar = '0' or present_state = idle then 
					bit_addr <= "000";
				elsif rising_edge(clk) then
					if present_state = ph0_2 then 
						if bit_addr /= "111" then 
							bit_addr <= bit_addr + 1; 
						end if;  
					elsif present_state = ph1_2 then 
						if bit_addr /= "111" then 
							bit_addr <= bit_addr + 1; 
						end if; 
					end if; 
				end if; 
		end if;
			
		end process;  
		
end fsm;  


		
		
		

	 

   
