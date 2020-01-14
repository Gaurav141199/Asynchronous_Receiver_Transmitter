LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_signed.all;
USE ieee.numeric_std.all;

entity TimingCkt is
  Port (    clk:IN std_logic;
            tx_empty:IN std_logic;
            rx_full : IN std_logic;
            tx_start : IN std_logic;
            ld_tx : OUT std_logic;
            eab : OUT std_logic;
            wea : OUT std_logic;
            rd_addr : OUT std_logic_vector(7 downto 0);
            wr_addr : OUT std_logic_vector(7 downto 0);
            reset : IN std_logic
        );
end TimingCkt;

architecture Behavioral of TimingCkt is

signal prevrx_full : std_logic :='0';
signal prevtx_empty : std_logic := '0';
signal r_count : integer :=0;
signal t_count : integer :=0;
type states is (rx, tx);
signal state : states :=rx;
signal updated: std_logic:='0';

begin
rd_addr <= std_logic_vector(to_unsigned(r_count-1, rd_addr'length));
wr_addr <= std_logic_vector(to_unsigned(t_count, wr_addr'length));
process(clk)
begin
        if(clk='0' and clk'event) then 
            if(reset = '1')then 
                prevrx_full<='0';
                prevtx_empty<='0';
                r_count<=0;
                t_count<=0;
                state<=rx;
                updated<='0';
            else
                if(prevrx_full = not(rx_full)) then
                    eab<= '1';
                    prevrx_full<=rx_full;         
                    r_count<=r_count+1;    
                else 
                    eab<='0';
            end if;
                    
            case state is
                when rx => 
                    if(tx_start ='1') then 
                       state <= tx; 
                        wea <= '1'; 
                        t_count<=0 ;       
                        ld_tx<='1';
                        updated <='0';
                        prevtx_empty<=tx_empty;
                    else 
                        state <=rx;
                        wea<='0';
                        t_count<=0;
                        ld_tx<='0';
                        t_count<=0;
                    end if;
                        
                when tx =>
                    if(prevtx_empty = tx_empty) then
                        ld_tx <= '0';
                    elsif(prevtx_empty = not(tx_empty)) then
                        if(r_count = t_count or t_count > r_count) then 
                            state <= rx;  
                            ld_tx<='0'; 
                            wea<='1';
                            updated <='0'; 
                            t_count<=0;
                        elsif(updated = '0') then
                            updated <='1';
                            wea <='1';
                            t_count<= t_count+1;
                            ld_tx<='0';
                        else
                           prevtx_empty<=tx_empty;
                           ld_tx<='1';
                           updated<='0';
                           wea<='0';
                        end if; 
                    end if;
                end case;
            end if;
        end if;
end process;

end Behavioral;
