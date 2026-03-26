library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    generic (
        CLKS_PER_BIT : integer := 10417
    );
    Port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        rx_serial    : in  std_logic;
        rx_dv        : out std_logic;
        rx_byte      : out std_logic_vector(7 downto 0)
    );
end uart_rx;

architecture Behavioral of uart_rx is

    type state_t is (IDLE, START_BIT, DATA_BITS, STOP_BIT, CLEANUP);
    signal state_reg : state_t := IDLE;

    signal clk_count : integer range 0 to CLKS_PER_BIT-1 := 0;
    signal bit_index : integer range 0 to 7 := 0;
    signal rx_shift  : std_logic_vector(7 downto 0) := (others => '0');

    signal rx_dv_reg   : std_logic := '0';
    signal rx_byte_reg : std_logic_vector(7 downto 0) := (others => '0');

begin

    process(clk, rst)
    begin
        if rst = '1' then
            state_reg    <= IDLE;
            clk_count    <= 0;
            bit_index    <= 0;
            rx_shift     <= (others => '0');
            rx_dv_reg    <= '0';
            rx_byte_reg  <= (others => '0');

        elsif rising_edge(clk) then
            rx_dv_reg <= '0';

            case state_reg is
                when IDLE =>
                    clk_count <= 0;
                    bit_index <= 0;

                    if rx_serial = '0' then
                        state_reg <= START_BIT;
                    end if;

                when START_BIT =>
                    if clk_count = (CLKS_PER_BIT-1)/2 then
                        if rx_serial = '0' then
                            clk_count <= 0;
                            state_reg <= DATA_BITS;
                        else
                            state_reg <= IDLE;
                        end if;
                    else
                        clk_count <= clk_count + 1;
                    end if;

                when DATA_BITS =>
                    if clk_count = CLKS_PER_BIT-1 then
                        clk_count <= 0;
                        rx_shift(bit_index) <= rx_serial;

                        if bit_index = 7 then
                            bit_index <= 0;
                            state_reg <= STOP_BIT;
                        else
                            bit_index <= bit_index + 1;
                        end if;
                    else
                        clk_count <= clk_count + 1;
                    end if;

                when STOP_BIT =>
                    if clk_count = CLKS_PER_BIT-1 then
                        clk_count   <= 0;
                        rx_byte_reg <= rx_shift;
                        rx_dv_reg   <= '1';
                        state_reg   <= CLEANUP;
                    else
                        clk_count <= clk_count + 1;
                    end if;

                when CLEANUP =>
                    state_reg <= IDLE;

                when others =>
                    state_reg <= IDLE;
            end case;
        end if;
    end process;

    rx_dv   <= rx_dv_reg;
    rx_byte <= rx_byte_reg;

end Behavioral;