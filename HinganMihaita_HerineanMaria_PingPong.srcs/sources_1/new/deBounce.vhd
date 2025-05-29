library IEEE;  -- include biblioteca standard IEEE
use IEEE.STD_LOGIC_1164.ALL;  -- pentru logica digitala (std_logic etc.)
use IEEE.NUMERIC_STD.ALL;  -- pentru operatii pe numere intregi (integer, unsigned etc.)

entity deBounce is  -- entitatea modulului debounce
    port ( clk : in std_logic;  -- semnal de ceas
           rst : in std_logic;  -- semnal de reset
           button_in : in std_logic;  -- semnal de intrare de la buton
           pulse_out : out std_logic);  -- iesire: puls generat dupa debounce
end DeBounce;

architecture behav of deBounce is  -- inceput arhitectura (comportament)

-- constante care controleaza cat timp asteapta pt debounce
-- cu cat e mai mare COUNT_MAX, cu atat mai mult trebuie apasat butonul
constant COUNT_MAX : integer := 10000000;

-- seteaza la '1' daca butonul da '1' cand e apasat, altfel pune '0'
constant BIN_ACTIVE : std_logic := '1';

-- semnalul de numarare pt debounce
signal count : integer := 0;

-- tipul starilor pt masina de stari
type state_type is (idle, wait_time);  -- doua stari: idle si wait_time
signal state : state_type := idle;  -- starea initiala e idle

begin

    process(clk, rst)  -- proces sensibil la clk si rst
    begin
        if (rst = '1') then  -- daca e reset activ
            state <= idle;  -- revine in idle
            pulse_out <= '0';  -- nu genereaza niciun puls
            count <= 0;  -- contorul e resetat

        elsif rising_edge(clk) then  -- pe frontul crescator al ceasului

            case state is  -- logica masinii de stari
                when idle =>  -- daca suntem in idle
                    if (button_in = BIN_ACTIVE) then  -- daca butonul e apasat
                        state <= wait_time;  -- trece in starea de asteptare
                    else 
                        state <= idle;  -- ramane in idle
                    end if;
                    pulse_out <= '0';  -- nu scoate nimic
                    count <= 0;  -- contorul se reseteaza

                when wait_time =>  -- in starea de asteptare
                    if (count = COUNT_MAX) then  -- daca timpul a trecut
                        count <= 0;  -- reseteaza contorul
                        if (button_in = BIN_ACTIVE) then  -- verifica din nou daca butonul e apasat
                            pulse_out <= '1';  -- genereaza puls
                        else
                            pulse_out <= '0';  -- nu genereaza nimic
                        end if;
                        state <= idle;  -- revine in idle
                    else
                        count <= count + 1;  -- creste contorul
                        pulse_out <= '0';  -- nu scoate nimic inca
                    end if;

            end case;
        end if;
    end process;

end behav;  -- sfarsitul arhitecturii
