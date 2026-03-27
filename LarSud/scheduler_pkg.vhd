library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package scheduler_pkg is
    subtype task_id_t is unsigned(1 downto 0);     -- 0..3
    subtype prio_t    is unsigned(2 downto 0);     -- 0..7
    subtype dur_t     is unsigned(3 downto 0);     -- 0..15

    type prio_array_t is array (0 to 3) of prio_t;
    type dur_array_t  is array (0 to 3) of dur_t;
end package;

package body scheduler_pkg is
end package body;