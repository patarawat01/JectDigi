library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity buzzer_driver is
    Port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        beep_short : in  std_logic;
        beep_long  : in  std_logic;
        buzzer_out : out std_logic
    );
end buzzer_driver;

architecture Behavioral of buzzer_driver is
    -- 100 MHz
    constant TONE_HALF_PERIOD : unsigned(15 downto 0) := to_unsigned(50000, 16);     
    -- ~1 kHz square wave: toggle every 50,000 clocks

    constant SHORT_BEEP_COUNT : unsigned(25 downto 0) := to_unsigned(20_000_000, 26); 
    -- 0.2 s

    constant LONG_BEEP_COUNT  : unsigned(26 downto 0) := to_unsigned(80_000_000, 27); 
    -- 0.8 s

    signal tone_counter    : unsigned(15 downto 0) := (others => '0');
    signal duration_counter: unsigned(26 downto 0) := (others => '0');
    signal active_beep     : std_logic := '0';
    signal buzzer_reg      : std_logic := '0';
    signal target_duration : unsigned(26 downto 0) := (others => '0');
begin

    process(clk, rst)
    begin
        if rst = '1' then
            tone_counter     <= (others => '0');
            duration_counter <= (others => '0');
            active_beep      <= '0';
            buzzer_reg       <= '0';
            target_duration  <= (others => '0');

        elsif rising_edge(clk) then
            -- trigger beep
            if active_beep = '0' then
                if beep_long = '1' then
                    active_beep      <= '1';
                    duration_counter <= (others => '0');
                    tone_counter     <= (others => '0');
                    buzzer_reg       <= '0';
                    target_duration  <= LONG_BEEP_COUNT;
                elsif beep_short = '1' then
                    active_beep      <= '1';
                    duration_counter <= (others => '0');
                    tone_counter     <= (others => '0');
                    buzzer_reg       <= '0';
                    target_duration  <= resize(SHORT_BEEP_COUNT, 27);
                end if;
            else
                -- tone generation
                if tone_counter = TONE_HALF_PERIOD then
                    tone_counter <= (others => '0');
                    buzzer_reg   <= not buzzer_reg;
                else
                    tone_counter <= tone_counter + 1;
                end if;

                -- duration control
                if duration_counter >= target_duration then
                    active_beep      <= '0';
                    duration_counter <= (others => '0');
                    buzzer_reg       <= '0';
                else
                    duration_counter <= duration_counter + 1;
                end if;
            end if;
        end if;
    end process;

    buzzer_out <= buzzer_reg;

end Behavioral;