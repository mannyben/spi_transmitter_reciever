 --Context Clauses for libraries needed 
library ieee;
use ieee.std_logic_1164.all; 
library work;	 
use work.all;	






entity SPI_test_system_II is port( 
rst_bar : in std_logic; -- asynchronous system reset 
clk : in std_logic; -- system clock 
send : in std_logic; -- positive pulse to start transmission 
cpol : in std_logic; -- clock polarity setting 
cpha : in std_logic; -- clock phase setting 
dord : in std_logic; -- transmission data order 0 => msb first 
miso : in std_logic; -- master in slave out 
data_in : in std_logic_vector(7 downto 0); -- parallel input data 
data_out : out std_logic_vector(7 downto 0); -- parallel output data 
mosi : out std_logic; -- master out slave in SPI serial data 
sck : out std_logic; -- SPI shift clock to slave 
ss_bar : out std_logic -- slave select signal
);
end SPI_test_system_II; 


architecture structure of SPI_test_system_II is

signal inter_send_en: std_logic; -- singal to connect internal signals 
--send_en of u1 and send_en of u2	

signal inter_spi_rxen:  std_logic;


begin --LHS instantiated entity ports (u1, u2), RHS encapsulating entity (SPI transmitter)
	
	u1: entity send_pos_edge_det port map (
		rst_bar => rst_bar,
		clk => clk,
		send => send,
		send_en => inter_send_en
		);
	
	u2: entity spi_tx_shifter port map ( 
		rst_bar => rst_bar,
		clk => clk,
		send_en => inter_send_en,
		cpha => cpha,
		cpol => cpol,
		dord => dord,
		data_in => data_in,
		txd => mosi,
		sck => sck,
		ss_bar => ss_bar,
		spi_rxen => inter_spi_rxen
		); 
		
	u3: entity spi_rx_shifter_fsm port map ( 
		rxd => miso,
		rst_bar => rst_bar,
		clk => clk,
		spi_rxen => inter_spi_rxen,
		dord => dord,
		data_out => data_out
		);
		
  		
end structure;