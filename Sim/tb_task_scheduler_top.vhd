library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_task_scheduler_top is
end tb_task_scheduler_top;

architecture Behavioral of tb_task_scheduler_top is

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    signal start : std_logic := '0';
    signal leds  : std_logic_vector(15 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    ----------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------
    DUT: entity work.task_scheduler_top
        port map (
            clk   => clk,
            rst   => rst,
            start => start,
            leds  => leds
        );

    ----------------------------------------------------------------
    -- Clock generation (100 MHz)
    ----------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    ----------------------------------------------------------------
    -- Stimulus
    ----------------------------------------------------------------
    stim_proc : process
    begin
        start <= '1';
        wait for 200 ns;   -- ยาวขึ้น 10 เท่า
        start <= '0';
    
        rst <= '0';
        wait for 100 ns;
    
        start <= '1';
        wait for 20 ns;
        start <= '0';
    
        wait for 5 ms;
    
        wait;
    end process;

end Behavioral;