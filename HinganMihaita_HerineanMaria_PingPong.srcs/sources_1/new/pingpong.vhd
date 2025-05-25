library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pingpong is
    Port (
        clk  : in  STD_LOGIC;
        rst  : in  STD_LOGIC;
        b1   : in  STD_LOGIC;
        b2   : in  STD_LOGIC;
        -- scor1 : out STD_LOGIC_VECTOR (6 downto 0);
        -- scor2 : out STD_LOGIC_VECTOR (6 downto 0);
        led  : out STD_LOGIC_VECTOR (15 downto 0);
        an   : out STD_LOGIC_VECTOR (3 downto 0);
        seg  : out STD_LOGIC_VECTOR (0 to 6);
        dp   : out STD_LOGIC
    );
end pingpong;

architecture Behavioral of pingpong is

    component deBounce is
        port(
            clk       : in  std_logic;
            rst       : in  std_logic;
            button_in : in  std_logic;
            pulse_out : out std_logic );
            
            end component DeBounce;

component driver7seg is
    Port (
        clk : in STD_LOGIC; -- 100MHz board clock input
        Din : in STD_LOGIC_VECTOR (15 downto 0); -- 16 bit binary data for 4 display
        an : out STD_LOGIC_VECTOR (3 downto 0); -- anode output selected individual displays [3:0]
        seg: out STD_LOGIC_VECTOR(0 to 6);
        dp_in : in STD_LOGIC_VECTOR (3 downto 0); -- decimal point input value
        dp_out : out STD_LOGIC; -- selected decimal point sent to cathode
        rst : in STD_LOGIC -- global reset
    );
end component driver7seg;

signal led_curent : INTEGER range 0 to 15 := 15;
signal directia: STD_LOGIC :='0';
signal joc_activ: STD_LOGIC :='0';
signal scor_ut11 : INTEGER := 0;
signal scor_ut12 : INTEGER := 0;
signal counter : INTEGER := 0;
signal display_data : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal dp_in : STD_LOGIC_VECTOR (3 downto 0) := "0000";
constant viteza : INTEGER := 50000000; -- Viteza constanta
signal ut11, ut12 : STD_LOGIC;
signal timp : std_logic;
begin
u1 : deBounce port map (clk => clk,
                           rst => rst,
                           button_in => b1,
                           pulse_out => ut11);

    u2 : deBounce port map (clk => clk,
                           rst => rst,
                           button_in => b2,
                           pulse_out => ut12);

    -- Proces pentru logica jocului si actualizarea LED-urilor
clock_divider :process(rst, clk)
variable q: integer:=0;
constant fdiv: integer:=10;
constant ndiv: integer :=50000000/ fdiv;
begin 
if rst='1' then 
q :=0;
timp <= '0';
elsif rising_edge(timp) then 
if q = ndiv -1 then 
q:=0;
timp <='1';
else 
q:= q + 1;
timp <='0';
end if;
end if;
end process;

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
            if ut11 = '1' then -- Incepe jocul
                joc_activ <= '1';
            end if;
            
       if joc_activ='1' then 
       if counter = viteza then 
       counter <= 0;
       
      if directia = '0' then  -- SPRE DREAPTA: 15 ? 0
    if led_curent = 0 then
        if timp = '1' then 
          scor_ut11 <= scor_ut11 +1;  -- juc?tor 2 a ratat
            joc_activ <= '0';
            led_curent <= 15;
        elsif b2 = '1' then  -- juc?tor 2 love?te
            directia <= '1';  -- întoarcem mingea înapoi (spre stânga)
--        else
            
        end if;
    else
        led_curent <= led_curent - 1;  -- mergem spre dreapta
    end if;
else  -- directia = '1' ? SPRE STÂNGA: 0 ? 15
   if led_curent = 15 then
    if ut11 = '1' then  -- juc?tor 1 love?te (cu debounce)
        directia <= '0';  -- mingea merge iar spre dreapta
    else
        scor_ut12 <= scor_ut12 + 1;  -- juc?tor 1 a ratat
        joc_activ <= '0';
        led_curent <= 15;
    end if;


    else
        led_curent <= led_curent + 1;  -- mergem spre stânga
    end if;
end if;

         else
          counter <= counter+1;
          end if;
          end if;
          
       -- Actualizarea ledurilor
       led<= (others => '0');
       led (led_curent)<= '1';
       end if;
       end process;
       
      --Proces pt convertirea scorurilor pt afisarea pe display-ul cu 7 seg  
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
    if led_curent = counter then 
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
    
    display_data <= std_logic_vector(to_unsigned(thousand,4))&
            std_logic_vector(to_unsigned(hundred,4))&
            std_logic_vector(to_unsigned(ten,4))&
            std_logic_vector(to_unsigned(unit,4));
         
         end process;
         
      u7seg: driver7seg port map (clk=> clk,
                                  Din =>display_data,
                                  an =>an,
                                  seg=>seg,
                                  dp_in=>(others => '0'),
                                  dp_out=> dp,
                                  rst=>rst);
                               
    end Behavioral;                              
                                  