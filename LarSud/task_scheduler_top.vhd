library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.scheduler_pkg.all;

entity task_scheduler_top is
    Port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        start : in  std_logic;
        leds  : out std_logic_vector(15 downto 0)
    );
end task_scheduler_top;

architecture Behavioral of task_scheduler_top is

    ----------------------------------------------------------------
    -- Task Data (Version 1: hardcode)
    ----------------------------------------------------------------
    constant TASK_PRIORITIES : prio_array_t := (
        0 => to_unsigned(2, 3), -- T0
        1 => to_unsigned(3, 3), -- T1
        2 => to_unsigned(1, 3), -- T2
        3 => to_unsigned(4, 3)  -- T3
    );

    constant TASK_DURATIONS : dur_array_t := (
        0 => to_unsigned(5, 4), -- T0
        1 => to_unsigned(3, 4), -- T1
        2 => to_unsigned(4, 4), -- T2
        3 => to_unsigned(2, 4)  -- T3
    );

    ----------------------------------------------------------------
    -- FSM State
    ----------------------------------------------------------------
    type state_t is (IDLE, SELECT_TASK, LOAD_TASK, RUN_TASK, MARK_DONE, FINISH);
    signal state_reg : state_t := IDLE;

    ----------------------------------------------------------------
    -- Internal Signals
    ----------------------------------------------------------------
    signal done_bits       : std_logic_vector(3 downto 0) := (others => '0');
    signal current_task    : task_id_t := (others => '0');

    signal selected_task   : task_id_t;
    signal selected_valid  : std_logic;

    signal tick_sig        : std_logic;
    signal counter_tick_en : std_logic;
    signal load_en_sig     : std_logic := '0';
    signal load_value_sig  : unsigned(3 downto 0) := (others => '0');
    signal counter_val     : unsigned(3 downto 0);
    signal counter_zero    : std_logic;

    signal run_leds        : std_logic_vector(3 downto 0);

begin

    ----------------------------------------------------------------
    -- Fix: create separate signal for tick enable
    ----------------------------------------------------------------
    counter_tick_en <= tick_sig when state_reg = RUN_TASK else '0';

    ----------------------------------------------------------------
    -- Submodules
    ----------------------------------------------------------------
    U_TICK : entity work.tick_gen
        port map (
            clk  => clk,
            rst  => rst,
            tick => tick_sig
        );

    U_SELECT : entity work.priority_selector
        port map (
            priorities     => TASK_PRIORITIES,
            done_bits      => done_bits,
            selected_task  => selected_task,
            selected_valid => selected_valid
        );

    U_COUNTER : entity work.run_counter
        port map (
            clk        => clk,
            rst        => rst,
            tick_en    => counter_tick_en,
            load_en    => load_en_sig,
            load_value => load_value_sig,
            count_out  => counter_val,
            zero       => counter_zero
        );

    ----------------------------------------------------------------
    -- FSM
    ----------------------------------------------------------------
    process(clk, rst)
        variable idx : integer;
    begin
        if rst = '1' then
            state_reg      <= IDLE;
            done_bits      <= (others => '0');
            current_task   <= (others => '0');
            load_en_sig    <= '0';
            load_value_sig <= (others => '0');

        elsif rising_edge(clk) then
            load_en_sig <= '0';

            case state_reg is
                when IDLE =>
                    done_bits    <= (others => '0');
                    current_task <= (others => '0');
                    if start = '1' then
                        state_reg <= SELECT_TASK;
                    end if;

                when SELECT_TASK =>
                    if selected_valid = '1' then
                        current_task <= selected_task;
                        state_reg    <= LOAD_TASK;
                    else
                        state_reg    <= FINISH;
                    end if;

                when LOAD_TASK =>
                    idx := to_integer(current_task);
                    load_value_sig <= TASK_DURATIONS(idx);
                    load_en_sig    <= '1';
                    state_reg      <= RUN_TASK;

                when RUN_TASK =>
                    if counter_zero = '1' then
                        state_reg <= MARK_DONE;
                    end if;

                when MARK_DONE =>
                    idx := to_integer(current_task);
                    done_bits(idx) <= '1';
                    state_reg <= SELECT_TASK;

                when FINISH =>
                    state_reg <= FINISH;

                when others =>
                    state_reg <= IDLE;
            end case;
        end if;
    end process;

    ----------------------------------------------------------------
    -- One-hot current running task LEDs
    ----------------------------------------------------------------
    process(current_task, state_reg)
    begin
        run_leds <= "0000";

        if state_reg = RUN_TASK or state_reg = LOAD_TASK or state_reg = MARK_DONE then
            case to_integer(current_task) is
                when 0 => run_leds <= "0001";
                when 1 => run_leds <= "0010";
                when 2 => run_leds <= "0100";
                when 3 => run_leds <= "1000";
                when others => run_leds <= "0000";
            end case;
        end if;
    end process;

    ----------------------------------------------------------------
    -- LED Output
    ----------------------------------------------------------------
    leds(3 downto 0)   <= run_leds;
    leds(7 downto 4)   <= done_bits;
    leds(11 downto 8)  <= std_logic_vector(counter_val);

    with state_reg select
        leds(14 downto 12) <=
            "000" when IDLE,
            "001" when SELECT_TASK,
            "010" when LOAD_TASK,
            "011" when RUN_TASK,
            "100" when MARK_DONE,
            "101" when FINISH,
            "111" when others;

    leds(15) <= '1' when state_reg = FINISH else '0';

end Behavioral;