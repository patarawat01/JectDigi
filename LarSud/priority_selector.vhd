library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.scheduler_pkg.all;

entity priority_selector_v2 is
    Port (
        priorities     : in  prio_array_t;
        valid_bits     : in  std_logic_vector(3 downto 0);
        done_bits      : in  std_logic_vector(3 downto 0);
        selected_task  : out task_id_t;
        selected_valid : out std_logic
    );
end priority_selector_v2;

architecture Behavioral of priority_selector_v2 is
begin
    process(priorities, valid_bits, done_bits)
        variable best_idx   : integer := 0;
        variable best_prio  : prio_t   := (others => '0');
        variable found_task : std_logic := '0';
    begin
        best_idx   := 0;
        best_prio  := (others => '0');
        found_task := '0';

        for i in 0 to 3 loop
            if valid_bits(i) = '1' and done_bits(i) = '0' then
                if found_task = '0' then
                    best_idx   := i;
                    best_prio  := priorities(i);
                    found_task := '1';
                else
                    if priorities(i) > best_prio then
                        best_idx  := i;
                        best_prio := priorities(i);
                    end if;
                end if;
            end if;
        end loop;

        selected_task  <= to_unsigned(best_idx, 2);
        selected_valid <= found_task;
    end process;
end Behavioral;