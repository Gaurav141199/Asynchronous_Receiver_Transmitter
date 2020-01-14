
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_signed.all;
USE ieee.numeric_std.all;


entity Control is
  Port (clk : IN std_logic;
        tx_start : IN std_logic;
        rx_in : IN std_logic;
        tx_out : OUT std_logic ;
        led: OUT std_logic_vector(15 downto 0);
        reset : IN std_logic
   );
end Control;

architecture Behavioral of Control is
signal clk9600 : std_logic;
signal clk9600_16 : std_logic;
signal eab : std_logic;
signal wea : std_logic;
signal rx_full : std_logic;
signal tx_empty : std_logic;
signal ld_tx : std_logic;
signal rx_data : std_logic_vector(7 downto 0);
signal tx_data : std_logic_vector(7 downto 0);
signal rd_addr : std_logic_vector(7 downto 0);
signal wr_addr : std_logic_vector(7 downto 0);
signal resetD : std_logic:='0';
signal tx_startD : std_logic;

begin
led(15 downto 0)<=rx_data&tx_data;

DebounceR:ENTITY WORK.Debounce(Behavioral)
          PORT MAP(clk, reset, resetD);

DebounceT:ENTITY WORK.Debounce(Behavioral)
          PORT MAP(clk, tx_start, tx_startD);

Clock:ENTITY WORK.Clock (Behavioral)
      PORT MAP (clk, clk9600_16, clk9600);

Timer:ENTITY WORK.TimingCkt (Behavioral)
        PORT MAP (clk9600,tx_empty,rx_full,tx_startD,ld_tx,eab,wea,rd_addr,wr_addr,resetD);

Receiver:ENTITY WORK.Receiver (Behavioral)
       PORT MAP (clk9600_16, resetD, rx_data, rx_full, rx_in);
       
Memory:ENTITY WORK.memory(Behavioral)
       PORT MAP (clk9600,eab,rd_addr,rx_data,clk9600,wea,wr_addr,tx_data,resetD);

Transmitter:ENTITY WORK.Transmitter(Behavioral)
        PORT MAP (tx_data,tx_out,clk9600,ld_tx,tx_empty,resetD);        

end Behavioral;
