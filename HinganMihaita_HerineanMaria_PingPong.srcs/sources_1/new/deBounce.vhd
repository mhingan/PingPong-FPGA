library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity deBounce is
    port ( clk : in std_logic;
           rst : in std_logic;
           button_in : in std_logic;
           pulse_out : out std_logic);
end DeBounce;


architecture behav of deBounce is

--the belov constants decide the working parameters.
--the higher this is, the more longer time the user has to press the button.
constant COUNT_MAX : integer := 10000000;
--set it '1' if the button creates a high pulse when its pressed, otherwise '0'.
constant BIN_ACTIVE : std_logic := '1';

signal count : integer := 0;
type state_type is (idle, wait_time);  --state machine
signal state : state_type := idle;

begin

    process(clk, rst)
    begin
        if (rst = '1') then
            state <= idle;
            pulse_out <= '0';
            count <= 0;
        elsif rising_edge(clk) then
            case state is
                when idle =>
                    if (button_in = BIN_ACTIVE) then
                        state <= wait_time;
                    else 
                        state <= idle;
                    end if;
                    pulse_out <= '0';
                    count <= 0;

                when wait_time =>
                    if (count = COUNT_MAX) then
                        count <= 0;
                        if (button_in = BIN_ACTIVE) then
                            pulse_out <= '1';
                        else
                            pulse_out <= '0';
                        end if;
                        state <= idle;
                    else
                        count <= count + 1;
                        pulse_out <= '0';
                    end if;

            end case;
        end if;
    end process;

end behav;