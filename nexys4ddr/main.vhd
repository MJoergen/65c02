library ieee;
use ieee.std_logic_1164.all;

-- This block instantiates everything else except the VERA.
-- I.e here you have the CPU, ROM, RAM, and VIA.
--
-- Notice that the ROM, RAM, and VIA have inverted clocks. This is to simulate
-- a conbinatiorial read.

entity main is
   generic (
      G_ROM_INIT_FILE : string
   );
   port (
      clk_i          : in  std_logic;
      rst_i          : in  std_logic;
      nmi_i          : in  std_logic;
      irq_i          : in  std_logic;
      --
      ps2_data_in_i  : in  std_logic;
      ps2_data_out_o : out std_logic;
      ps2_dataen_o   : out std_logic;
      ps2_clk_in_i   : in  std_logic;
      ps2_clk_out_o  : out std_logic;
      ps2_clken_o    : out std_logic;
      --
      aud_val_o      : out std_logic_vector(9 downto 0);
      --
      eth_clk_i      : in    std_logic;
      eth_txd_o      : out   std_logic_vector(1 downto 0);
      eth_txen_o     : out   std_logic;
      eth_rxd_i      : in    std_logic_vector(1 downto 0);
      eth_rxerr_i    : in    std_logic;
      eth_crsdv_i    : in    std_logic;
      eth_intn_i     : in    std_logic;
      eth_mdio_io    : inout std_logic;
      eth_mdc_o      : out   std_logic;
      eth_rstn_o     : out   std_logic;
      eth_refclk_o   : out   std_logic;
      --
      vera_addr_o    : out std_logic_vector(2 downto 0);
      vera_wr_en_o   : out std_logic;
      vera_wr_data_o : out std_logic_vector(7 downto 0);
      vera_rd_en_o   : out std_logic;
      vera_rd_data_i : in  std_logic_vector(7 downto 0);
      vera_debug_o   : out std_logic_vector(15 downto 0)
   );
end main;

architecture structural of main is

   signal clkn_s           : std_logic;

   signal cpu_addr_s       : std_logic_vector(15 downto 0);
   signal cpu_wr_en_s      : std_logic;
   signal cpu_wr_data_s    : std_logic_vector( 7 downto 0);
   signal cpu_rd_en_s      : std_logic;
   signal cpu_rd_data_s    : std_logic_vector( 7 downto 0);
   signal cpu_debug_s      : std_logic_vector(15 downto 0);
 
   -- Chip select
   signal loram_cs_s       : std_logic;   -- 0x0000 - 0x7FFF
   signal medram_cs_s      : std_logic;   -- 0x8000 - 0x9FFF
   signal vera_cs_s        : std_logic;   -- 0x9F20 - 0x9F2F
   signal via1_cs_s        : std_logic;   -- 0x9F60 - 0x9F6F
   signal via2_cs_s        : std_logic;   -- 0x9F70 - 0x9F7F
   signal eth_cs_s         : std_logic;   -- 0x9FC0 - 0x9FCF
   signal aud_cs_s         : std_logic;   -- 0x9FE0 - 0x9FEF
   signal hiram_cs_s       : std_logic;   -- 0xA000 - 0xBFFF
   signal rom_cs_s         : std_logic;   -- 0xC000 - 0xFFFF

   -- ROM and RAM banking
   signal hiram_addr_s     : std_logic_vector(16 downto 0);  -- 128 kB
   signal rom_addr_s       : std_logic_vector(16 downto 0);  -- 128 kB
   signal hiram_bank_s     : std_logic_vector( 3 downto 0);  -- 16 pages of  8 kB = 128 kB
   signal rom_bank_s       : std_logic_vector( 2 downto 0);  --  8 pages of 16 kB = 128 kB

   -- Write enable
   signal loram_wr_en_s    : std_logic;
   signal medram_wr_en_s   : std_logic;
   signal via1_wr_en_s     : std_logic;
   signal via2_wr_en_s     : std_logic;
   signal eth_wr_en_s      : std_logic;
   signal aud_wr_en_s      : std_logic;
   signal hiram_wr_en_s    : std_logic;

   -- Read enable
   signal loram_rd_en_s    : std_logic;
   signal medram_rd_en_s   : std_logic;
   signal via1_rd_en_s     : std_logic;
   signal via2_rd_en_s     : std_logic;
   signal eth_rd_en_s      : std_logic;
   signal hiram_rd_en_s    : std_logic;
   signal rom_rd_en_s      : std_logic;

   -- Read data
   signal loram_rd_data_s  : std_logic_vector(7 downto 0);
   signal medram_rd_data_s : std_logic_vector(7 downto 0);
   signal via1_rd_data_s   : std_logic_vector(7 downto 0);
   signal via2_rd_data_s   : std_logic_vector(7 downto 0);
   signal eth_rd_data_s    : std_logic_vector(7 downto 0);
   signal hiram_rd_data_s  : std_logic_vector(7 downto 0);
   signal rom_rd_data_s    : std_logic_vector(7 downto 0);

   -- VIA I/O chips
   signal via1_porta_s     : std_logic_vector(7 downto 0);
   signal via1_portb_s     : std_logic_vector(7 downto 0);

   signal via2_porta_in_s  : std_logic_vector(7 downto 0) := (others => '0');
   signal via2_porta_out_s : std_logic_vector(7 downto 0);
   signal via2_porta_en_s  : std_logic_vector(7 downto 0);

   signal via2_portb_s     : std_logic_vector(7 downto 0);

   signal ps2_clk_in_s     : std_logic;
   signal ps2_clk_out_s    : std_logic;
   signal ps2_clken_s      : std_logic;
   signal ps2_data_in_s    : std_logic;
   signal ps2_data_out_s   : std_logic;
   signal ps2_dataen_s     : std_logic;

   -- Debug
   constant DEBUG_MODE                   : boolean := false; -- TRUE OR FALSE

   attribute mark_debug                  : boolean;
   attribute mark_debug of via1_porta_s  : signal is DEBUG_MODE;
   attribute mark_debug of via1_portb_s  : signal is DEBUG_MODE;
   attribute mark_debug of cpu_debug_s   : signal is DEBUG_MODE;
   attribute mark_debug of cpu_addr_s    : signal is DEBUG_MODE;
   attribute mark_debug of cpu_wr_en_s   : signal is DEBUG_MODE;
   attribute mark_debug of cpu_wr_data_s : signal is DEBUG_MODE;
   attribute mark_debug of cpu_rd_en_s   : signal is DEBUG_MODE;
   attribute mark_debug of cpu_rd_data_s : signal is DEBUG_MODE;

begin

   clkn_s <= not clk_i;

   -- Debug
   ps2_clk_in_s   <= ps2_clk_in_i;
   ps2_clk_out_o  <= ps2_clk_out_s;
   ps2_clken_o    <= ps2_clken_s;
   ps2_data_in_s  <= ps2_data_in_i;
   ps2_data_out_o <= ps2_data_out_s;
   ps2_dataen_o   <= ps2_dataen_s;

   -----------------------
   -- Connect to keyboard
   -----------------------

   i_ps2_buffer : entity work.ps2_buffer
      port map (
         clk_i         => clk_i,
         rst_i         => rst_i,
         kbd_clk_i     => ps2_clk_in_s,
         kbd_clk_o     => ps2_clk_out_s,
         kbd_clken_o   => ps2_clken_s,
         kbd_data_i    => ps2_data_in_s,
         kbd_data_o    => ps2_data_out_s,
         kbd_dataen_o  => ps2_dataen_s,
         main_clk_o    => via2_porta_in_s(1),
         main_clk_i    => via2_porta_out_s(1),
         main_clken_i  => via2_porta_en_s(1),
         main_data_o   => via2_porta_in_s(0),
         main_data_i   => via2_porta_out_s(0),
         main_dataen_i => via2_porta_en_s(0)
      ); -- i_ps2_buffer


   -----------------------
   -- VIA1 port mapping
   -----------------------

   hiram_bank_s <= via1_porta_s(3 downto 0); -- TBD: Should be 7 downto 0.
   rom_bank_s   <= via1_portb_s(2 downto 0);


   -----------------------
   -- ROM and RAM banking
   -----------------------

   hiram_addr_s <= hiram_bank_s & cpu_addr_s(12 downto 0);  -- 64 *  8 kB = 512 kB
   rom_addr_s   <= rom_bank_s   & cpu_addr_s(13 downto 0);  --  8 * 16 kB = 128 kB


   --------------------
   -- Address decoding      
   --------------------

   loram_cs_s  <= '1' when cpu_addr_s(15 downto 15) = "0"    else '0';  -- 0x0000 - 0x7FFF
   medram_cs_s <= '1' when cpu_addr_s(15 downto 13) = "100"  else '0';  -- 0x8000 - 0x9FFF
   vera_cs_s   <= '1' when cpu_addr_s(15 downto  4) = X"9F2" else '0';  -- 0x9F20 - 0x9F2F
   via1_cs_s   <= '1' when cpu_addr_s(15 downto  4) = X"9F6" else '0';  -- 0x9F60 - 0x9F6F
   via2_cs_s   <= '1' when cpu_addr_s(15 downto  4) = X"9F7" else '0';  -- 0x9F70 - 0x9F7F
   eth_cs_s    <= '1' when cpu_addr_s(15 downto  4) = X"9FC" else '0';  -- 0x9FC0 - 0x9FCF
   aud_cs_s    <= '1' when cpu_addr_s(15 downto  4) = X"9FE" else '0';  -- 0x9FE0 - 0x9FEF
   hiram_cs_s  <= '1' when cpu_addr_s(15 downto 13) = "101"  else '0';  -- 0xA000 - 0xBFFF
   rom_cs_s    <= '1' when cpu_addr_s(15 downto 14) = "11"   else '0';  -- 0xC000 - 0xFFFF

   cpu_rd_data_s <= loram_rd_data_s  when loram_cs_s  = '1' else
                    vera_rd_data_i   when vera_cs_s   = '1' else
                    via1_rd_data_s   when via1_cs_s   = '1' else
                    via2_rd_data_s   when via2_cs_s   = '1' else
                    eth_rd_data_s    when eth_cs_s    = '1' else
                    medram_rd_data_s when medram_cs_s = '1' else  -- Lower priority than VERA and VIA.
                    hiram_rd_data_s  when hiram_cs_s  = '1' else
                    rom_rd_data_s    when rom_cs_s    = '1' else
                    (others => '0');

   loram_rd_en_s  <= cpu_rd_en_s and loram_cs_s;
   medram_rd_en_s <= cpu_rd_en_s and medram_cs_s;
   vera_rd_en_o   <= cpu_rd_en_s and vera_cs_s;
   via1_rd_en_s   <= cpu_rd_en_s and via1_cs_s;
   via2_rd_en_s   <= cpu_rd_en_s and via2_cs_s;
   eth_rd_en_s    <= cpu_rd_en_s and eth_cs_s;
   hiram_rd_en_s  <= cpu_rd_en_s and hiram_cs_s;
   rom_rd_en_s    <= cpu_rd_en_s and rom_cs_s;

   loram_wr_en_s  <= cpu_wr_en_s and loram_cs_s;
   medram_wr_en_s <= cpu_wr_en_s and medram_cs_s;
   vera_wr_en_o   <= cpu_wr_en_s and vera_cs_s;
   via1_wr_en_s   <= cpu_wr_en_s and via1_cs_s;
   via2_wr_en_s   <= cpu_wr_en_s and via2_cs_s;
   eth_wr_en_s    <= cpu_wr_en_s and eth_cs_s;
   aud_wr_en_s    <= cpu_wr_en_s and aud_cs_s;
   hiram_wr_en_s  <= cpu_wr_en_s and hiram_cs_s;


   -----------------------
   -- Instantiate low RAM
   -----------------------

   i_loram : entity work.ram
      generic map (
         G_ADDR_BITS => 15                   -- 2^15 = 32 kB
      )
      port map (
         clk_i     => clkn_s,
         addr_i    => cpu_addr_s(14 downto 0),
         wr_en_i   => loram_wr_en_s,
         wr_data_i => cpu_wr_data_s,
         rd_en_i   => loram_rd_en_s,
         rd_data_o => loram_rd_data_s
      ); -- i_loram


   -----------------------
   -- Instantiate med RAM
   -----------------------

   i_medram : entity work.ram
      generic map (
         G_ADDR_BITS => 13                   -- 2^13 = 8 kB
      )
      port map (
         clk_i     => clkn_s,
         addr_i    => cpu_addr_s(12 downto 0),
         wr_en_i   => medram_wr_en_s,
         wr_data_i => cpu_wr_data_s,
         rd_en_i   => medram_rd_en_s,
         rd_data_o => medram_rd_data_s
      ); -- i_medram


   ----------------
   -- Connect VERA
   ----------------

   vera_addr_o    <= cpu_addr_s(2 downto 0);
   vera_wr_data_o <= cpu_wr_data_s;
   vera_debug_o   <= cpu_debug_s(15 downto 0);  -- Program Counter


   --------------------------------------------------
   -- Instantiate VIA1
   --------------------------------------------------

   i_via1 : entity work.via
      port map (
         clk_i     => clkn_s,
         rst_i     => rst_i,
         addr_i    => cpu_addr_s(3 downto 0),
         wr_en_i   => via1_wr_en_s,
         wr_data_i => cpu_wr_data_s,
         rd_en_i   => via1_rd_en_s,
         rd_data_o => via1_rd_data_s,
         porta_i   => via1_porta_s,             -- RAM bank
         portb_i   => via1_portb_s,             -- ROM bank
         porta_o   => via1_porta_s,             -- RAM bank
         portb_o   => via1_portb_s,             -- ROM bank
         portaen_o => open,
         portben_o => open
      ); -- i_via1


   --------------------------------------------------
   -- Instantiate VIA2
   --------------------------------------------------

   i_via2 : entity work.via
      port map (
         clk_i     => clkn_s,
         rst_i     => rst_i,
         addr_i    => cpu_addr_s(3 downto 0),
         wr_en_i   => via2_wr_en_s,
         wr_data_i => cpu_wr_data_s,
         rd_en_i   => via2_rd_en_s,
         rd_data_o => via2_rd_data_s,

         porta_i   => via2_porta_in_s,          -- Keyboard
         portb_i   => via2_portb_s,             -- Mouse
         porta_o   => via2_porta_out_s,         -- Keyboard
         portb_o   => via2_portb_s,             -- Mouse
         portaen_o => via2_porta_en_s,          -- Keyboard
         portben_o => open                      -- Mouse
      ); -- i_via2


   --------------------------------------------------------
   -- Instantiate YM2151 module
   --------------------------------------------------------

   i_ym2151 : entity work.ym2151
      port map (
         clk_i     => clk_i,
         rst_i     => rst_i,
         addr_i    => cpu_addr_s(0 downto 0),
         wr_en_i   => aud_wr_en_s,
         wr_data_i => cpu_wr_data_s,
         val_o     => aud_val_o
      ); -- i_ym2151


   -------------------------------
   -- Instantiate Ethernet module
   -------------------------------

   i_ethernet : entity work.ethernet
      port map (
         cpu_clk_i     => clkn_s,
         cpu_rst_i     => rst_i,
         cpu_addr_i    => cpu_addr_s(3 downto 0),
         cpu_wr_en_i   => eth_wr_en_s,
         cpu_wr_data_i => cpu_wr_data_s,
         cpu_rd_en_i   => eth_rd_en_s,
         cpu_rd_data_o => eth_rd_data_s,
         --
         eth_clk_i     => eth_clk_i,
         eth_txd_o     => eth_txd_o,
         eth_txen_o    => eth_txen_o,
         eth_rxd_i     => eth_rxd_i,
         eth_rxerr_i   => eth_rxerr_i,
         eth_crsdv_i   => eth_crsdv_i,
         eth_intn_i    => eth_intn_i,
         eth_mdio_io   => eth_mdio_io,
         eth_mdc_o     => eth_mdc_o,
         eth_rstn_o    => eth_rstn_o,
         eth_refclk_o  => eth_refclk_o
      ); -- i_ethernet


   --------------------------
   -- Instantiate banked RAM
   --------------------------

   i_hiram : entity work.ram
      generic map (
         G_ADDR_BITS => 17                   -- 2^17 = 128 kB
      )
      port map (
         clk_i     => clkn_s,
         addr_i    => hiram_addr_s,
         wr_en_i   => hiram_wr_en_s,
         wr_data_i => cpu_wr_data_s,
         rd_en_i   => hiram_rd_en_s,
         rd_data_o => hiram_rd_data_s
      ); -- i_hiram
      

   -------------------
   -- Instantiate ROM
   -------------------

   i_rom : entity work.rom
      generic map (
         G_INIT_FILE => G_ROM_INIT_FILE,
         G_ADDR_BITS => 17                   -- 2^17 = 128 kB
      )
      port map (
         clk_i     => clkn_s,
         addr_i    => rom_addr_s,
         rd_en_i   => rom_rd_en_s,
         rd_data_o => rom_rd_data_s
      ); -- i_rom
      
      
   --------------------------------------------------
   -- Instantiate 65C02 CPU module
   --------------------------------------------------

   i_cpu_65c02 : entity work.cpu_65c02
      port map (
         clk_i     => clk_i,
         rst_i     => rst_i,
         nmi_i     => nmi_i,
         irq_i     => irq_i,
         addr_o    => cpu_addr_s,
         wr_en_o   => cpu_wr_en_s,
         wr_data_o => cpu_wr_data_s,
         rd_en_o   => cpu_rd_en_s,
         debug_o   => cpu_debug_s,
         rd_data_i => cpu_rd_data_s
      ); -- i_cpu_65c02
      
end architecture structural;

