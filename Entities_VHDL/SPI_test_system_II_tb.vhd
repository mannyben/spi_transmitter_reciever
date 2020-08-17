 --Context Clauses for libraries needed 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;	 
use work.all;	






entity SPI_test_system_II_tb is 
end SPI_test_system_II_tb;

architecture tb_architecture of SPI_test_system_II_tb is 

--Stimulus signals 
		signal rst_bar_tb :  std_logic; 	   					-- asynchronous system reset 
		signal clk_tb :  std_logic; 							-- system clock
		signal send_tb :  std_logic; 	    					-- positive pulse to start transmission
		signal cpol_tb :  std_logic; 							-- clock polarity setting 
		signal cpha_tb :  std_logic; 						    -- clock phase setting 
		signal dord_tb :  std_logic;							-- data direction setting 
		signal miso_tb :  std_logic;							-- master in slave out 
		signal data_in_tb :  std_logic_vector(7 downto 0); 		-- parallel input data
		signal data_out_tb : std_logic_vector(7 downto 0);		--parallel output data 
		signal mosi_tb :  std_logic; 							-- master out slave in SPI serial data 
		signal sck_tb :   std_logic; 						    -- SPI shift clock to slave
		signal ss_bar_tb :  std_logic;   						-- slave select signal 		  	 
		
		constant period : time := ns; 
		signal end_sim : boolean := false;
 		constant data_in : std_logic_vector(7 downto 0) := x"ca"; 
		signal loopback : std_logic; 			
			
begin				   
    -- Unit Under Test port map
    UUT: entity SPI_test_system_II
    port map (
        clk => clk_tb,
        rst_bar => rst_bar_tb,
		send => send_tb,
		cpha => cpha_tb,
		cpol => cpol_tb,
		dord => dord_tb,
		miso => miso_tb,
		data_in => data_in_tb,
		data_out => data_out_tb,
		mosi => mosi_tb,
		ss_bar => ss_bar_tb,
		sck => sck_tb  
        );
		
		loopback <= mosi_tb;
		miso_tb <= loopback;	
		
		--data_in_tb <= "10101010";
  
   clock: process                -- system clock
    begin	  
        clk_tb <= '0';                -- clock starts at 0 for 0.5 clock periods
       loop
            wait for period/2;
            clk_tb <= not clk_tb;        -- 25*4 rising edges
			exit when end_sim = true;
        end loop;
        wait;                        -- stop clock
    end process;	
	
	-- generate a reset, low for two clock cycles
 reset: process
 	begin 
		rst_bar_tb <= '0'; 
	for i in 1 to 2 loop 
			wait until clk_tb = '1'; 
		end loop; 
		rst_bar_tb <= '1'; 
		wait; 
	 end process; 	   	
	 
pushbutton: process 
	begin
 		send_tb <= '0'; 
		cpol_tb <= '0'; 
		cpha_tb <= '0'; 
		dord_tb <= '0'; 
	wait for 4 * period; 
	for i in 0 to 7 loop
 		(dord_tb, cpol_tb, cpha_tb) <= to_unsigned(i, 3); 
		wait for 2 * period; 
		send_tb <= '1'; 
		wait for 20 * period; 
		send_tb <= '0'; 
		wait for 2 * period; 
	end loop; 
	end_sim <= true; 
	wait; 
end process;  

		
end tb_architecture;