LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_signed.all;
USE ieee.numeric_std.all;

entity Transmitter is
 Port ( tx_data : IN std_logic_vector(7 downto 0);
        tx_out : OUT std_logic;
        txclk : IN std_logic;
        ld_tx : IN std_logic;
        tx_empty : buffer std_logic;
        reset : IN std_logic
 );
end Transmitter;

architecture Behavioral of Transmitter is
type t_states is (idle, tr);
signal t_state : t_states := idle;
signal count10 : integer:=0;
signal t_reg : std_logic_vector(9 downto 0);
begin

process(txclk,t_state)
begin
    if(txclk='1' and txclk'event) then    
        if(reset = '1')then 
            t_state<=idle;
            count10<=0;
            t_reg<="1111111111";
            tx_empty<='0';
            tx_out<='1';
        else
        case t_state is
            
            when idle => if(ld_tx='1') then 
                            count10<=0; 
                            tx_out<='1'; 
                            t_state <= tr; 
                            t_reg<='0' & tx_data(7 downto 0 )&'1'; 
                         end if;
            
            when tr => if(count10 = 10) then 
                            t_state<=idle ; 
                            count10<= 0; 
                            tx_empty<=not(tx_empty);
                        else tx_out <= t_reg(9-count10);
                             count10<= count10+1;
                        end if;       
        end case;
        
       end if;
    end if;
end process;
end Behavioral;