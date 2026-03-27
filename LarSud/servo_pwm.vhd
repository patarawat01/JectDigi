library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity servo_pwm is
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        enable   : in  std_logic;
        position : in  unsigned(1 downto 0); -- 00=T0, 01=T1, 10=T2, 11=T3
        pwm_out  : out std_logic
    );
end servo_pwm;

architecture Behavioral of servo_pwm is
    -- 100 MHz, 20 ms period = 2,000,000 clocks
    constant PERIOD_COUNT : unsigned(20 downto 0) := to_unsigned(1_999_999, 21);

    -- safer pulse range for positional servo
    constant PULSE_T0 : unsigned(20 downto 0) := to_unsigned(110_000, 21); -- 1.10 ms
    constant PULSE_T1 : unsigned(20 downto 0) := to_unsigned(136_000, 21); -- 1.36 ms
    constant PULSE_T2 : unsigned(20 downto 0) := to_unsigned(164_000, 21); -- 1.64 ms
    constant PULSE_T3 : unsigned(20 downto 0) := to_unsigned(190_000, 21); -- 1.90 ms

    -- smooth movement step per 20 ms frame
    constant STEP_SIZE : unsigned(20 downto 0) := to_unsigned(2_500, 21);

    signal count_reg    : unsigned(20 downto 0) := (others => '0');
    signal target_pulse : unsigned(20 downto 0) := PULSE_T1;
    signal current_pulse: unsigned(20 downto 0) := PULSE_T1;
    signal pwm_reg      : std_logic := '0';
begin

    process(position)
    begin
        case position is
            when "00" =>
                target_pulse <= PULSE_T0;
            when "01" =>
                target_pulse <= PULSE_T1;
            when "10" =>
                target_pulse <= PULSE_T2;
            when others =>
                target_pulse <= PULSE_T3;
        end case;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            count_reg     <= (others => '0');
            current_pulse <= PULSE_T1;
            pwm_reg       <= '0';

        elsif rising_edge(clk) then
            if count_reg = PERIOD_COUNT then
                count_reg <= (others => '0');

                -- smooth move once every 20 ms frame
                if current_pulse < target_pulse then
                    if current_pulse + STEP_SIZE >= target_pulse then
                        current_pulse <= target_pulse;
                    else
                        current_pulse <= current_pulse + STEP_SIZE;
                    end if;
                elsif current_pulse > target_pulse then
                    if current_pulse <= target_pulse + STEP_SIZE then
                        current_pulse <= target_pulse;
                    else
                        current_pulse <= current_pulse - STEP_SIZE;
                    end if;
                end if;

            else
                count_reg <= count_reg + 1;
            end if;

            if enable = '1' and count_reg < current_pulse then
                pwm_reg <= '1';
            else
                pwm_reg <= '0';
            end if;
        end if;
    end process;

    pwm_out <= pwm_reg;

end Behavioral;