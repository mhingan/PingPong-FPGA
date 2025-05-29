library IEEE;  -- include biblioteca standard IEEE
use IEEE.STD_LOGIC_1164.ALL;  -- include tipuri logice standard (std_logic etc.)
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- permite operatii aritmetice pe std_logic_vector

entity driver7seg is  -- definitia modulului driver pt afisaj 7 segmente
    Port ( clk : in STD_LOGIC;  -- semnal de ceas de intrare
           Din : in STD_LOGIC_VECTOR (15 downto 0);  -- date de intrare (4 cifre hex)
           an : out STD_LOGIC_VECTOR (3 downto 0);  -- iesire pt anoduri (active low)
           seg : out STD_LOGIC_VECTOR (0 to 6);  -- iesiri pt cele 7 segmente (a-g)
           dp_in : in STD_LOGIC_VECTOR (3 downto 0);  -- intrare pt puncte zecimale
           dp_out : out STD_LOGIC;  -- iesire pt punctul zecimal al cifrei active
           rst : in STD_LOGIC);  -- semnal de reset
end driver7seg;

architecture Behavioral of driver7seg is  -- inceputul arhitecturii (comportamentului)

signal clk1kHz : std_logic;  -- semnal pt frecventa de 1kHz (pt multiplexare)
signal state : std_logic_vector(16 downto 0);  -- contor de 17 biti (pana la 99999)
signal addr : std_logic_vector(1 downto 0);  -- contor de 2 biti (pt 4 cifre)
signal cseg : std_logic_vector(3 downto 0);  -- cifra curenta extrasa din Din

begin

-- divizor de frecventa pt a genera 1kHz din clk
-- contorul merge pana la 99999
-- iesirea e MSB din contor

div1kHz : process (clk, rst)
begin
	if rst = '1' then  -- daca se apasa reset
		state <= '0' & X"0000";  -- reseteaza contorul
	else
	if rising_edge (clk) then  -- pe frontul crescator al ceasului
		if state = '1' & X"869F" then  -- daca ajunge la 99999
			state <= '0' & X"0000";  -- reseteaza contorul
		else 
			state <= state + 1;  -- incrementeaza contorul
		end if;
	end if;
end if;
end process;

clk1kHz <= state(16);  -- semnalul de 1kHz e bitul cel mai semnificativ din contor

-- contor de 2 biti pt a genera 4 adrese (una pt fiecare cifra)
counter_2bits : process (clk1kHz)
begin
	if rising_edge (clk1kHz) then  -- pe fiecare puls de 1kHz
		addr <= addr + 1;  -- incrementeaza adresa (0..3)
	end if;
end process;

-- decodor 2 catre 4 pt a activa pe rand cate o cifra
-- anodurile sunt active low, deci iesirea trebuie sa fie 0 pt cifra activa
dcd3_8 : process (addr)
begin
	case addr is
		when"00" => an <= "0111";  -- activeaza cifra 3
		when"01" => an <= "1011";  -- activeaza cifra 2
		when"10" => an <= "1101";  -- activeaza cifra 1
		when"11" => an <= "1110";  -- activeaza cifra 0
		when others => an <= "1111";  -- default (toate dezactivate)
	end case;
end process;

-- multiplexor pt a selecta 4 biti din Din corespunzatori cifrei active
-- se sincronizeaza cu addr si an
data_mux4 : process (addr, Din, dp_in)
begin
	case addr is 
		when "00" => cseg <= Din(15 downto 12);  -- cifra 3
				dp_out <= not dp_in(3);  -- punctul zecimal pt cifra 3
		when "01" => cseg <= Din (11 downto 8);  -- cifra 2
				dp_out <= not dp_in(2);  -- punctul zecimal pt cifra 2
		when "10" => cseg <= Din (7 downto 4);  -- cifra 1
				dp_out <= not dp_in(1);  -- punctul zecimal pt cifra 1
		when "11" => cseg <= Din (3 downto 0);  -- cifra 0
				dp_out <= not dp_in(0);  -- punctul zecimal pt cifra 0
		when others => cseg <= "XXXX";  -- default invalid
				dp_out <= 'X';  -- iesire incerta
	end case;
end process;

-- decodor binar catre 7 segmente
-- segmentele sunt active low (0 aprinde segmentul)
dcd7seg : process(cseg)
begin
	case cseg is
		when "0000" => seg <= "0000001";  -- afiseaza 0
		when "0001" => seg <= "1001111";  -- afiseaza 1
		when "0010" => seg <= "0010010";  -- afiseaza 2
		when "0011" => seg <= "0000110";  -- afiseaza 3
		when "0100" => seg <= "1001100";  -- afiseaza 4
		when "0101" => seg <= "0100100";  -- afiseaza 5
		when "0110" => seg <= "0100000";  -- afiseaza 6
		when "0111" => seg <= "0001111";  -- afiseaza 7
		when "1000" => seg <= "0000000";  -- afiseaza 8
		when "1001" => seg <= "0000100";  -- afiseaza 9
		when "1010" => seg <= "0000010";  -- afiseaza A
		when "1011" => seg <= "1100000";  -- afiseaza b
		when "1100" => seg <= "0110001";  -- afiseaza C
		when "1101" => seg <= "1000010";  -- afiseaza d
		when "1110" => seg <= "0110000";  -- afiseaza E
		when "1111" => seg <= "0111000";  -- afiseaza F
		when others => seg <= "XXXXXXX";  -- default invalid
	end case;
end process;

end Behavioral;  -- sfarsit arhitectura
