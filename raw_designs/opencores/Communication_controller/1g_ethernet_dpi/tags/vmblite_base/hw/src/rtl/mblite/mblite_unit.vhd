----------------------------------------------------------------------------------------------
--
--      Input file         : 
--      Design name        : 
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : 
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library mblite;
use mblite.config_Pkg.all;
use mblite.core_Pkg.all;
use mblite.std_Pkg.all;

entity mblite_unit is port
(   -- SYS_CON
    sys_clk_i        : in std_logic;
    sys_rst_i        : in std_logic;
    -- IRQ
    sys_int_i        : in std_logic;
    -- WB-master inputs from the wb-slaves
    wbm_dat_i : in  std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0); -- databus input
    wbm_ack_i : in  std_logic;                                     -- buscycle acknowledge input
    -- WB-master outputs to the wb-slaves
    wbm_adr_o : out std_logic_vector(CFG_DMEM_SIZE - 1 downto 0);  -- address bits
    wbm_dat_o : out std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0); -- databus output
    wbm_we_o  : out std_logic;                                     -- write enable output
    wbm_stb_o : out std_logic;                                     -- strobe signals
    wbm_sel_o : out std_logic_vector(CFG_DMEM_WIDTH/8 - 1 downto 0); -- select output array
    wbm_cyc_o : out std_logic                                      -- valid BUS cycle output
);
end mblite_unit;

architecture arch of mblite_unit is

    signal dmem_o : dmem_out_type;
    signal dmem_i : dmem_in_type;
    signal imem_o : imem_out_type;
    signal imem_i : imem_in_type;
    signal s_dmem_o : dmem_out_array_type(CFG_NUM_SLAVES - 1 downto 0);
    signal s_dmem_i : dmem_in_array_type(CFG_NUM_SLAVES - 1 downto 0);
    signal s_dmem_sel_o : std_logic_vector(3 downto 0);
    signal s_dmem_ena_o : std_logic;

    signal m_wb_i : wb_mst_in_type;
    signal m_wb_o : wb_mst_out_type;

    constant rom_size : integer := 16;
    constant ram_size : integer := 16;
    
begin

--
-- WB route
--
wbm_adr_o   <= m_wb_o.adr_o;
wbm_dat_o   <= m_wb_o.dat_o;
wbm_we_o    <= m_wb_o.we_o;
wbm_stb_o   <= m_wb_o.stb_o;
wbm_sel_o   <= m_wb_o.sel_o;
wbm_cyc_o   <= m_wb_o.cyc_o;
m_wb_i.dat_i    <= wbm_dat_i;
m_wb_i.ack_i    <= wbm_ack_i;
m_wb_i.int_i    <= sys_int_i;
m_wb_i.clk_i <= sys_clk_i;
m_wb_i.rst_i <= sys_rst_i;

--
-- ??
--
    wb_adapter : core_wb_adapter 
    port map
    (
        dmem_i => s_dmem_i(1),
        wb_o   => m_wb_o,
        dmem_o => s_dmem_o(1),
        wb_i   => m_wb_i
    );

    s_dmem_i(0).ena_i <= '1';
    s_dmem_sel_o <= s_dmem_o(0).sel_o when s_dmem_o(0).we_o = '1' else (others => '0');
    s_dmem_ena_o <= not sys_rst_i and s_dmem_o(0).ena_o;

    dmem : sram_4en 
    generic map
    (
        WIDTH => CFG_DMEM_WIDTH,
        SIZE  => ram_size - 2
    )
    port map
    (
        dat_o => s_dmem_i(0).dat_i,
        dat_i => s_dmem_o(0).dat_o,
        adr_i => s_dmem_o(0).adr_o(ram_size - 1 downto 2),
        wre_i => s_dmem_sel_o,
        ena_i => s_dmem_ena_o,
        clk_i => sys_clk_i
    );

    decoder : core_address_decoder 
    generic map
    (
        G_NUM_SLAVES => CFG_NUM_SLAVES
    )
    port map
    (
        m_dmem_i => dmem_i,
        s_dmem_o => s_dmem_o,
        m_dmem_o => dmem_o,
        s_dmem_i => s_dmem_i,
        clk_i    => sys_clk_i
    );

    imem : sram 
    generic map
    (
        FNAME => "rom.mem",
        WIDTH => CFG_IMEM_WIDTH,
        SIZE  => rom_size - 2
    )
    port map
    (
        dat_o => imem_i.dat_i,
        dat_i => (others => '0'),
        adr_i => imem_o.adr_o(rom_size - 1 downto 2),
        wre_i => '0',
        ena_i => imem_o.ena_o,
        clk_i => sys_clk_i
    );

    core0 : core 
    port map
    (
        imem_o => imem_o,
        dmem_o => dmem_o,
        imem_i => imem_i,
        dmem_i => dmem_i,
        int_i  => sys_int_i,
        rst_i  => sys_rst_i,
        clk_i  => sys_clk_i
    );
end arch;