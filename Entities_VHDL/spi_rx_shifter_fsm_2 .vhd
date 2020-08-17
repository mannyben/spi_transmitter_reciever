



--Context Clasues for libraries needed
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all ;
library work;
use work.all; 
 
 
entity spi_rx_shifter_fsm_2 is port( 
rxd : in std_logic;       -- data received from slave
rst_bar : in std_logic;   -- asynchronous reset
clk : in std_logic;       -- system clock 
spi_rxen : in std_logic;  -- signal to enable shift 
dord : in std_logic;        -- data order bit _vector(7 downto 0)
data_out : out std_logic_vector(7 downto 0) -- received data
); 
end spi_rx_shifter_fsm_2; 

architecture fsm of spi_rx_shifter_fsm_2 is 	 

type state is (idle, ph1, ph2); --2 groups of ph1+ph2, one for CPHA = 0 and another for CPOL = 1 
signal present_state, next_state : state; 
signal bit_addr : unsigned(2 downto 0);			  --variable that will represent the current index of data vector to read from 
--and when to return to idle state
signal bit_sub: unsigned(2 downto 0);


begin
  --Process that preforms fxn of a state register 

	state_reg: process (clk,  rst_bar) 
		begin 
			if rst_bar = '0' then 
				present_state <= idle; 
			elsif rising_edge(clk) then 
				present_state <= next_state; 
			end if; 
		end process; 	
		
		 
	 nxt_state: process (present_state, spi_rxen, bit_addr, bit_sub) 
	 	begin 
	 		case present_state is 
			 	when idle => 
					if spi_rxen = '1' then 
				 		next_state <= ph1; 
					else 
				 		next_state <= idle; 
				 	end if;
				when ph1 =>
					if dord = '0' and bit_sub = "000" then
						next_state <= idle;
					elsif dord = '1' and bit_addr = "111" then  
						next_state <= idle;
					else
						next_state <= ph2;
					end if;
				when others =>
					next_state <= ph1;
				
			end case; 
		end process;
		
		output: process (present_state, rxd, clk, bit_addr, bit_sub) 
		begin 		

		  case present_state is 
			when idle =>
			bit_sub <= "111";
			bit_addr <= "000";
			data_out <= "00000000";	  
			when ph1 =>
				if dord = '1' then 
					data_out(to_integer(bit_addr)) <= rxd; 
				elsif dord = '0' then 
					data_out(to_integer(bit_sub)) <= rxd;
				end if;
			when ph2 => 
			  if rising_edge(clk) then
				if dord = '0' then
					bit_sub <= bit_sub - 1;
				elsif dord = '1' then 
					bit_addr <= bit_addr + 1;
				end if;
			  end if;
		   	end case; 
		end process; 
		

end fsm; 
		
