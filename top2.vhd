library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.scheduler_pkg.all;

entity task_scheduler_top_v2 is
    Port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        start     : in  std_logic;
        uart_rx_i : in  std_logic;
        leds      : out std_logic_vector(15 downto 0);
        seg       : out std_logic_vector(6 downto 0);
        an        : out std_logic_vector(3 downto 0)
    );
end task_scheduler_top_v2;

architecture Behavioral of task_scheduler_top_v2 is

    type main_state_t is (
        LOAD_TASKS,
        WAIT_START,
        SELECT_TASK,
        LOAD_TASK,
        RUN_TASK,
        MARK_DONE,
        FINISH
    );
    signal state_reg : main_state_t := LOAD_TASKS;

    signal task_priorities : prio_array_t := (others => (others => '0'));
    signal task_durations  : dur_array_t  := (others => (others => '0'));
    signal task_valid      : std_logic_vector(3 downto 0) := (others => '0');
    signal done_bits       : std_logic_vector(3 downto 0) := (others => '0');

    signal load_index    : integer range 0 to 3 := 0;
    signal byte_phase    : integer range 0 to 2 := 0;  -- 0=ID, 1=PRIO, 2=DUR

    signal rx_id_reg     : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_prio_reg   : prio_t := (others => '0');
    signal rx_dur_reg    : dur_t  := (others => '0');

    signal current_task   : task_id_t := (others => '0');
    signal selected_task  : task_id_t;
    signal selected_valid : std_logic;

    signal tick_sig        : std_logic;
    signal counter_tick_en : std_logic;
    signal load_en_sig     : std_logic := '0';
    signal load_value_sig  : unsigned(3 downto 0) := (others => '0');
    signal counter_val     : unsigned(3 downto 0);
    signal counter_zero    : std_logic;

    signal rx_dv_sig      : std_logic;
    signal rx_byte_sig    : std_logic_vector(7 downto 0);

    signal start_ff1      : std_logic := '0';
    signal start_ff2      : std_logic := '0';
    signal start_prev     : std_logic := '0';
    signal start_pulse    : std_logic := '0';

    signal run_leds       : std_logic_vector(3 downto 0);

    signal cnt_4bit       : std_logic_vector(3 downto 0);
    signal state_4bit     : std_logic_vector(3 downto 0);

begin

    counter_tick_en <= tick_sig when state_reg = RUN_TASK else '0';

    cnt_4bit <= std_logic_vector(counter_val);

    with state_reg select
        state_4bit <=
            "0000" when LOAD_TASKS,
            "0001" when WAIT_START,
            "0010" when SELECT_TASK,
            "0011" when LOAD_TASK,
            "0100" when RUN_TASK,
            "0101" when MARK_DONE,
            "0110" when FINISH,
            "1111" when others;

    U_UART_RX : entity work.uart_rx
        generic map (
            CLKS_PER_BIT => 10417
        )
        port map (
            clk       => clk,
            rst       => rst,
            rx_serial => uart_rx_i,
            rx_dv     => rx_dv_sig,
            rx_byte   => rx_byte_sig
        );

    U_SELECT : entity work.priority_selector_v2
        port map (
            priorities     => task_priorities,
            valid_bits     => task_valid,
            done_bits      => done_bits,
            selected_task  => selected_task,
            selected_valid => selected_valid
        );

    U_TICK : entity work.tick_gen
        port map (
            clk  => clk,
            rst  => rst,
            tick => tick_sig
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

    U_7SEG : entity work.seven_seg_driver
        port map (
            clk    => clk,
            rst    => rst,
            digit3 => "1111",     -- blank
            digit2 => state_4bit, -- state
            digit1 => cnt_4bit,   -- counter
            digit0 => "1111",     -- blank
            seg    => seg,
            an     => an
        );

    process(clk, rst)
    begin
        if rst = '1' then
            start_ff1   <= '0';
            start_ff2   <= '0';
            start_prev  <= '0';
            start_pulse <= '0';
        elsif rising_edge(clk) then
            start_ff1   <= start;
            start_ff2   <= start_ff1;
            start_pulse <= start_ff2 and (not start_prev);
            start_prev  <= start_ff2;
        end if;
    end process;

    process(clk, rst)
        variable idx : integer;
    begin
        if rst = '1' then
            state_reg       <= LOAD_TASKS;

            task_priorities <= (others => (others => '0'));
            task_durations  <= (others => (others => '0'));
            task_valid      <= (others => '0');
            done_bits       <= (others => '0');

            load_index      <= 0;
            byte_phase      <= 0;
            rx_id_reg       <= (others => '0');
            rx_prio_reg     <= (others => '0');
            rx_dur_reg      <= (others => '0');

            current_task    <= (others => '0');
            load_en_sig     <= '0';
            load_value_sig  <= (others => '0');

        elsif rising_edge(clk) then
            load_en_sig <= '0';

            case state_reg is

                when LOAD_TASKS =>
                    done_bits <= (others => '0');

                    if rx_dv_sig = '1' then
                        case byte_phase is
                            when 0 =>
                                rx_id_reg  <= rx_byte_sig;
                                byte_phase <= 1;

                            when 1 =>
                                rx_prio_reg <= unsigned(rx_byte_sig(2 downto 0));
                                byte_phase  <= 2;

                            when 2 =>
                                rx_dur_reg <= unsigned(rx_byte_sig(3 downto 0));

                                task_priorities(load_index) <= rx_prio_reg;
                                task_durations(load_index)  <= unsigned(rx_byte_sig(3 downto 0));
                                task_valid(load_index)      <= '1';

                                if load_index = 3 then
                                    load_index <= 0;
                                    byte_phase <= 0;
                                    state_reg  <= WAIT_START;
                                else
                                    load_index <= load_index + 1;
                                    byte_phase <= 0;
                                end if;

                            when others =>
                                byte_phase <= 0;
                        end case;
                    end if;

                when WAIT_START =>
                    if start_pulse = '1' then
                        done_bits <= (others => '0');
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
                    load_value_sig <= task_durations(idx);
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
                    state_reg <= LOAD_TASKS;
            end case;
        end if;
    end process;

    process(current_task, state_reg)
    begin
        run_leds <= "0000";

        if state_reg = LOAD_TASK or state_reg = RUN_TASK or state_reg = MARK_DONE then
            case to_integer(current_task) is
                when 0 => run_leds <= "0001";
                when 1 => run_leds <= "0010";
                when 2 => run_leds <= "0100";
                when 3 => run_leds <= "1000";
                when others => run_leds <= "0000";
            end case;
        end if;
    end process;

    leds(3 downto 0)   <= run_leds;
    leds(7 downto 4)   <= done_bits;
    leds(11 downto 8)  <= std_logic_vector(counter_val);

    with state_reg select
        leds(14 downto 12) <=
            "000" when LOAD_TASKS,
            "001" when WAIT_START,
            "010" when SELECT_TASK,
            "011" when LOAD_TASK,
            "100" when RUN_TASK,
            "101" when MARK_DONE,
            "110" when FINISH,
            "111" when others;

    leds(15) <= '1' when state_reg = FINISH else '0';

end Behavioral;