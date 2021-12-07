----------------------------------------------------------------------------------------------
--
--      Input file         : sram.vhd
--      Design name        : sram
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : Single Port Synchronous Random Access Memory
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all; -- InitRamFromFile

library std;
use std.textio.all; -- InitRamFromFile

library mblite;
use mblite.std_Pkg.all;

entity sram is generic
(
    FNAME : string;
    WIDTH : positive := 32;
    SIZE  : positive := 16
);
port
(
    dat_o : out std_logic_vector(WIDTH - 1 downto 0);
    dat_i : in std_logic_vector(WIDTH - 1 downto 0);
    adr_i : in std_logic_vector(SIZE - 1 downto 0);
    wre_i : in std_logic;
    ena_i : in std_logic;
    clk_i : in std_logic
);
end sram;

architecture arch of sram is
    type ram_type is array(2 ** SIZE - 1 downto 0) of std_logic_vector(WIDTH - 1 downto 0);
    --
    impure function InitRamFromFile (RamFileName : in string) return ram_type is
        FILE ramfile : text is in RamFileName;
        variable RamFileLine : line;
        variable ram : ram_type;
        variable i : natural := 0;
    begin
            while not endfile(ramfile) loop
                readline(ramfile, RamFileLine);
                hread(RamFileLine, ram(i));
                i := i + 1;
            end loop;
            return ram;
    end function;
    --
    signal ram :  ram_type := InitRamFromFile(FNAME);
begin
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if ena_i = '1' then
                if wre_i = '1' then
                   ram(my_conv_integer(adr_i)) <= dat_i;
                end if;
                dat_o <= ram(my_conv_integer(adr_i));
            end if;
        end if;
    end process;
end arch;
