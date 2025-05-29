library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pingpong is
    Port (
        clk  : in  STD_LOGIC;
        rst  : in  STD_LOGIC;
        b1   : in  STD_LOGIC;
        b2   : in  STD_LOGIC;
        led  : out STD_LOGIC_VECTOR (15 downto 0);
        an   : out STD_LOGIC_VECTOR (3 downto 0);
        seg  : out STD_LOGIC_VECTOR (0 to 6);
        dp   : out STD_LOGIC
    );
end pingpong;

architecture Behavioral of pingpong is

    component deBounce
        Port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            button_in : in  std_logic;
            pulse_out : out std_logic
        );
    end component;

    component driver7seg
        Port (
            clk     : in  STD_LOGIC;
            Din     : in  STD_LOGIC_VECTOR (15 downto 0);
            an      : out STD_LOGIC_VECTOR (3 downto 0);
            seg     : out STD_LOGIC_VECTOR (0 to 6);
            dp_in   : in  STD_LOGIC_VECTOR (3 downto 0);
            dp_out  : out STD_LOGIC;
            rst     : in  STD_LOGIC
        );
    end component;

    signal led_curent : INTEGER range 0 to 15 := 15;
    signal directia   : STD_LOGIC := '0';
    signal joc_activ  : STD_LOGIC := '0';
    signal scor_ut11  : INTEGER := 0;
    signal scor_ut12  : INTEGER := 0;
    signal counter    : INTEGER := 0;
    signal display_data : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    constant viteza : INTEGER := 50000000;

    signal ut11, ut12 : STD_LOGIC;

begin

    -- debounce pentru butoane
    u1 : deBounce port map (clk => clk, rst => rst, button_in => b1, pulse_out => ut11);
    u2 : deBounce port map (clk => clk, rst => rst, button_in => b2, pulse_out => ut12);

    -- logica jocului
    process(clk, rst)
    begin
        if rst = '1' then
            led_curent <= 15;
            directia <= '0';
            joc_activ <= '0';
            scor_ut11 <= 0;
            scor_ut12 <= 0;
            counter <= 0;
            led <= (others => '0');

        elsif rising_edge(clk) then
            if ut11 = '1' then
                joc_activ <= '1';
            end if;

            if joc_activ = '1' then
                if counter = viteza then
                    counter <= 0;

                    if directia = '0' then  -- mingea merge la stanga
                        if led_curent = 0 then
                            if ut12 = '0' then
                                scor_ut11 <= scor_ut11 + 1;
                                joc_activ <= '0';
                                led_curent <= 15;
                            else
                                directia <= '1';
                            end if;
                        else
                            led_curent <= led_curent - 1;
                        end if;

                    else  -- directia = 1, mingea merge la dreapta
                        if led_curent = 15 then
                            if ut11 = '0' then
                                scor_ut12 <= scor_ut12 + 1;
                                joc_activ <= '0';
                                led_curent <= 15;
                            else
                                directia <= '0';
                            end if;
                        else
                            led_curent <= led_curent + 1;
                        end if;
                    end if;

                else
                    counter <= counter + 1;
                end if;
            end if;

            led <= (others => '0');
            led(led_curent) <= '1';
        end if;
    end process;

    -- proces pentru afisarea scorului ambilor jucatori
    generate_score: process(clk, rst)
        variable s1, s2 : integer;
        variable t1, u1, t2, u2 : integer range 0 to 9 := 0;
    begin
        if rst = '1' then
            display_data <= (others => '0');

        elsif rising_edge(clk) then
            -- scor jucator 1 (cifrele 3 si 2 din stanga)
            s1 := scor_ut11;
            t1 := (s1 / 10) mod 10;
            u1 := s1 mod 10;

            -- scor jucator 2 (cifrele 1 si 0 din dreapta)
            s2 := scor_ut12;
            t2 := (s2 / 10) mod 10;
            u2 := s2 mod 10;

            display_data <= std_logic_vector(to_unsigned(t1, 4)) &  -- cifra 3
                            std_logic_vector(to_unsigned(u1, 4)) &  -- cifra 2
                            std_logic_vector(to_unsigned(t2, 4)) &  -- cifra 1
                            std_logic_vector(to_unsigned(u2, 4));   -- cifra 0
        end if;
    end process;

    -- conectare la afisaj 7 segmente
    u7seg : driver7seg port map (
        clk     => clk,
        Din     => display_data,
        an      => an,
        seg     => seg,
        dp_in   => (others => '0'),
        dp_out  => dp,
        rst     => rst
    );

end Behavioral;
