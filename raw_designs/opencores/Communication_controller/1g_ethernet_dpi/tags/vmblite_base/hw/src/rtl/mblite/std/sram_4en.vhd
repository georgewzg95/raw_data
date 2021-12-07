----------------------------------------------------------------------------------------------
--
--      Input file         : sram_4en.vhd
--      Design name        : sram_4en
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description          : Single Port Synchronous Random Access Memory with 4 write enable
--                             ports.
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all; -- string

library mblite;
use mblite.std_Pkg.all;

entity sram_4en is generic
(
    WIDTH : positive := 32;
    SIZE  : positive := 16
);
port
(
    dat_o : out std_logic_vector(WIDTH - 1 downto 0);
    dat_i : in std_logic_vector(WIDTH - 1 downto 0);
    adr_i : in std_logic_vector(SIZE - 1 downto 0);
    wre_i : in std_logic_vector(WIDTH/8 - 1 downto 0);
    ena_i : in std_logic;
    clk_i : in std_logic
);
end sram_4en;

architecture arch of sram_4en is
--
type type_name is array (0 to 3) of string(1 to 8);
constant ram_fname : type_name := ("rom0.mem", "rom1.mem", "rom2.mem", "rom3.mem");
--
begin
   mem: for i in 0 to WIDTH/8 - 1 generate
       mem : sram 
       generic map
       (
           FNAME   => ram_fname(i),
           WIDTH   => 8,
           SIZE    => SIZE
       )
       port map
       (
           dat_o   => dat_o((i+1)*8 - 1 downto i*8),
           dat_i   => dat_i((i+1)*8 - 1 downto i*8),
           adr_i   => adr_i,
           wre_i   => wre_i(i),
           ena_i   => ena_i,
           clk_i   => clk_i
       );
   end generate;
end arch;
