library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity run_counter is
    Port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        tick_en    : in  std_logic;
        load_en    : in  std_logic;
        load_value : in  unsigned(3 downto 0);
        count_out  : out unsigned(3 downto 0);
        zero       : out std_logic
    );
end run_counter;

architecture Behavioral of run_counter is
    signal count_reg : unsigned(3 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            count_reg <= (others => '0');
        elsif rising_edge(clk) then
            if load_en = '1' then
                count_reg <= load_value;
            elsif tick_en = '1' then
                if count_reg > 0 then
                    count_reg <= count_reg - 1;
                end if;
            end if;
        end if;
    end process;

    count_out <= count_reg;
    zero <= '1' when count_reg = 0 else '0';
end Behavioral;