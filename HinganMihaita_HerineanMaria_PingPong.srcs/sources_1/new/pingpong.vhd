library IEEE;  -- biblioteca standard
use IEEE.STD_LOGIC_1164.ALL;  -- pentru std_logic
use IEEE.NUMERIC_STD.ALL;  -- pentru operatii cu integer si vectori unsigned

entity pingpong is  -- definitia entitatii jocului de pingpong
    Port (
        clk  : in  STD_LOGIC;  -- ceas
        rst  : in  STD_LOGIC;  -- reset global
        b1   : in  STD_LOGIC;  -- buton jucator 1
        b2   : in  STD_LOGIC;  -- buton jucator 2
        led  : out STD_LOGIC_VECTOR (15 downto 0);  -- iesiri catre leduri
        an   : out STD_LOGIC_VECTOR (3 downto 0);  -- iesiri anoduri pt afisaj 7seg
        seg  : out STD_LOGIC_VECTOR (0 to 6);  -- iesiri segmente afisaj 7seg
        dp   : out STD_LOGIC  -- punctul zecimal
    );
end pingpong;

architecture Behavioral of pingpong is  -- inceput arhitectura

-- componente externe folosite
component deBounce is  -- debounce pt butoane
    port(
        clk       : in  std_logic;
        rst       : in  std_logic;
        button_in : in  std_logic;
        pulse_out : out std_logic );
end component DeBounce;

component driver7seg is  -- driver pt afisajul cu 7 segmente
    Port (
        clk : in STD_LOGIC;
        Din : in STD_LOGIC_VECTOR (15 downto 0);
        an : out STD_LOGIC_VECTOR (3 downto 0);
        seg: out STD_LOGIC_VECTOR(0 to 6);
        dp_in : in STD_LOGIC_VECTOR (3 downto 0);
        dp_out : out STD_LOGIC;
        rst : in STD_LOGIC
    );
end component driver7seg;

-- semnale interne
signal led_curent : INTEGER range 0 to 15 := 15;  -- pozitia curenta a mingii
signal directia: STD_LOGIC :='0';  -- directia mingii (0 = dreapta, 1 = stanga)
signal joc_activ: STD_LOGIC :='0';  -- jocul e activ sau nu
signal scor_ut11 : INTEGER := 0;  -- scor jucator 1
signal scor_ut12 : INTEGER := 0;  -- scor jucator 2
signal counter : INTEGER := 0;  -- contor pt viteza
signal display_data : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');  -- date afisaj
signal dp_in : STD_LOGIC_VECTOR (3 downto 0) := "0000";  -- puncte zecimale dezactivate
constant viteza : INTEGER := 50000000;  -- viteza jocului
signal ut11, ut12 : STD_LOGIC;  -- pulsuri de debounce pt b1 si b2
signal timp : std_logic;  -- semnal temporar de divizare clock

-- debounce pentru butoane
u1 : deBounce port map (clk => clk, rst => rst, button_in => b1, pulse_out => ut11);
u2 : deBounce port map (clk => clk, rst => rst, button_in => b2, pulse_out => ut12);

-- divizor de frecventa
clock_divider :process(rst, clk)
    variable q: integer:=0;  -- contor intern
    constant fdiv: integer:=10;
    constant ndiv: integer :=50000000/ fdiv;  -- valoarea limita pt divizare
begin 
    if rst='1' then 
        q :=0;
        timp <= '0';
    elsif rising_edge(timp) then 
        if q = ndiv -1 then 
            q:=0;
            timp <='1';  -- genereaza puls
        else 
            q:= q + 1;
            timp <='0';  -- inca nu
        end if;
    end if;
end process;

-- logica principala a jocului
process(clk, rst)
begin
    if rst = '1' then
        led_curent <= 15;  -- mingea porneste din dreapta
        directia <= '0';  -- spre stanga
        joc_activ <= '0';
        scor_ut11 <= 0;
        scor_ut12 <= 0;
        counter <= 0;
        led <= (others => '0');
    elsif rising_edge(clk) then
        if ut11 = '1' then
            joc_activ <= '1';  -- porneste jocul
        end if;
        
        if joc_activ='1' then 
            if counter = viteza then 
                counter <= 0;

                if directia = '0' then  -- spre dreapta
                    if led_curent = 0 then  -- mingea a ajuns la jucator 2
                        if timp = '1' then 
                            scor_ut11 <= scor_ut11 +1;  -- j2 a ratat
                            joc_activ <= '0';
                            led_curent <= 15;
                        elsif b2 = '1' then  -- j2 a lovit
                            directia <= '1';  -- intoarce mingea
                        end if;
                    else
                        led_curent <= led_curent - 1;  -- misca mingea spre dreapta
                    end if;
                else  -- directia = 1, spre stanga
                    if led_curent = 15 then
                        if ut11 = '1' then  -- j1 a lovit
                            directia <= '0';  -- inapoi spre dreapta
                        else
                            scor_ut12 <= scor_ut12 + 1;  -- j1 a ratat
                            joc_activ <= '0';
                            led_curent <= 15;
                        end if;
                    else
                        led_curent <= led_curent + 1;  -- misca mingea spre stanga
                    end if;
                end if;
            else
                counter <= counter+1;  -- asteapta viteza
            end if;
        end if;
        
        -- actualizeaza LED-urile
        led<= (others => '0');
        led (led_curent)<= '1';  -- aprinde doar LED-ul curent
    end if;
end process;

-- converteste scorul in format BCD pt afisaj
generate_score: process(rst,clk)
    variable thousand : integer range 0 to 9 :=0;
    variable hundred : integer range 0 to 9 :=0;
    variable ten : integer range 0 to 9 :=0;
    variable unit : integer range 0 to 9 :=0;
begin 
    if rst = '1' then 
        thousand:=0;
        hundred:=0; 
        ten:=0;
        unit:=0;
    elsif rising_edge(clk) then 
        if led_curent = counter then  -- doar o conditie de incrementare fictiva
            if unit = 9 then 
                unit := 0;
                if ten = 9 then 
                    ten :=0;
                    if hundred = 9 then 
                        hundred :=0;
                        if thousand = 9 then
                            thousand :=0;
                        else 
                            thousand:= thousand + 1;
                        end if;
                    else 
                        hundred:= hundred + 1;
                    end if;
                else 
                    ten:= ten + 1;
                end if;
            else
                unit:= unit + 1;
            end if;
        end if;
    end if;

    -- concateneaza valorile in format 16 biti
    display_data <= std_logic_vector(to_unsigned(thousand,4)) &
                    std_logic_vector(to_unsigned(hundred,4)) &
                    std_logic_vector(to_unsigned(ten,4)) &
                    std_logic_vector(to_unsigned(unit,4));
end process;

-- conecteaza afisajul 7 segmente
u7seg: driver7seg port map (
    clk => clk,
    Din => display_data,
    an => an,
    seg => seg,
    dp_in => (others => '0'),
    dp_out => dp,
    rst => rst
);

end Behavioral;  -- sfarsit arhitectura
