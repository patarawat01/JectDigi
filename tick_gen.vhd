library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tick_gen is
    Port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        tick : out std_logic
    );
end tick_gen;

architecture Behavioral of tick_gen is
    signal count_reg : unsigned(26 downto 0) := (others => '0');
    signal tick_reg  : std_logic := '0';

    -- 100,000,000 clocks @100MHz = 1 second
    constant MAX_COUNT : unsigned(26 downto 0) := to_unsigned(99_999_999, 27);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            count_reg <= (others => '0');
            tick_reg  <= '0';
        elsif rising_edge(clk) then
            if count_reg = MAX_COUNT then
                count_reg <= (others => '0');
                tick_reg  <= '1';
            else
                count_reg <= count_reg + 1;
                tick_reg  <= '0';
            end if;
        end if;
    end process;

    tick <= tick_reg;
end Behavioral;