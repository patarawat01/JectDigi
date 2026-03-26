library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_driver is
    Port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        digit3 : in  std_logic_vector(3 downto 0);
        digit2 : in  std_logic_vector(3 downto 0);
        digit1 : in  std_logic_vector(3 downto 0);
        digit0 : in  std_logic_vector(3 downto 0);
        seg    : out std_logic_vector(6 downto 0);
        an     : out std_logic_vector(3 downto 0)
    );
end seven_seg_driver;

architecture Behavioral of seven_seg_driver is
    signal refresh_counter : unsigned(15 downto 0) := (others => '0');
    signal scan_sel        : unsigned(1 downto 0)  := (others => '0');
    signal current_digit   : std_logic_vector(3 downto 0) := (others => '1');
    signal seg_int         : std_logic_vector(6 downto 0);
begin

    U_DEC : entity work.seven_seg_decoder
        port map (
            bin_in => current_digit,
            seg    => seg_int
        );

    process(clk, rst)
    begin
        if rst = '1' then
            refresh_counter <= (others => '0');
        elsif rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;

    scan_sel <= refresh_counter(15 downto 14);

    process(scan_sel, digit3, digit2, digit1, digit0)
    begin
        case scan_sel is
            when "00" =>
                current_digit <= digit0;
                an <= "1111"; -- ปิด digit0
    
            when "01" =>
                current_digit <= digit1;
                an <= "1101"; -- เปิด digit1
    
            when "10" =>
                current_digit <= digit2;
                an <= "1011"; -- เปิด digit2
    
            when others =>
                current_digit <= digit3;
                an <= "1111"; -- ปิด digit3
        end case;
    end process;

    seg <= seg_int;

end Behavioral;