library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

-- This is the top level module of the Nexys4DDR. The ports on this entity are mapped
-- directly to pins on the FPGA.

entity nexys4ddr is
   port (
      clk_i : in  std_logic;                       -- 100 MHz
      led_o : out std_logic_vector(15 downto 0)
   );
end nexys4ddr;

architecture synth of nexys4ddr is

   -- Clock and Reset
   signal clk_cnt_r     : std_logic_vector(1 downto 0) := "00";
   signal clk_s         : std_logic;   -- CPU clock running at 25 MHz.
   signal clkn_s        : std_logic;   -- Inverted clock used for the memory.
   signal rst_cnt_r     : std_logic_vector(1 downto 0) := "00";
   signal rst_s         : std_logic := '1';

   -- CPU signals
   signal addr_s        : std_logic_vector(15 downto 0);
   signal wr_en_s       : std_logic;
   signal wr_data_s     : std_logic_vector( 7 downto 0);
   signal rd_en_s       : std_logic;
   signal rd_data_s     : std_logic_vector( 7 downto 0);

   -- Address decoding
   signal wr_en_ram_s   : std_logic;
   signal rd_data_ram_s : std_logic_vector( 7 downto 0);
   signal rd_data_rom_s : std_logic_vector( 7 downto 0);

   constant C_ROM_FILE  : string := "build/rom.txt";

begin

   --------------------------------------------------
   -- Clock and reset
   --------------------------------------------------

   p_clk : process (clk_i)
   begin
      if rising_edge(clk_i) then
         clk_cnt_r <= clk_cnt_r + 1;
      end if;
   end process p_clk;

   clk_s <= clk_cnt_r(1);
   clkn_s <= not clk_s;

   p_rst : process (clk_s)
   begin
      if rising_edge(clk_s) then
         if rst_cnt_r /= 3 then
            rst_cnt_r <= rst_cnt_r + 1;
         end if;
      end if;
   end process p_rst;

   rst_s <= '0' when rst_cnt_r = 3 else '1';


   --------------------------------------------------
   -- Instantiate 65C02 CPU module
   --------------------------------------------------

   i_cpu_65c02 : entity work.cpu_65c02
      port map (
         clk_i     => clk_s,
         rst_i     => rst_s,
         nmi_i     => '0',
         irq_i     => '0',
         addr_o    => addr_s,
         wr_en_o   => wr_en_s,
         wr_data_o => wr_data_s,
         rd_en_o   => rd_en_s,
         debug_o   => open,
         rd_data_i => rd_data_s
      ); -- i_cpu_65c02
      

   --------------------------------------------------
   -- Instantiate ROM
   --------------------------------------------------

   i_rom : entity work.memory
      generic map (
         G_INIT_FILE => C_ROM_FILE,
         G_ADDR_BITS => 14
      )
      port map (
         clk_i     => clkn_s,
         addr_i    => addr_s(13 downto 0),
         wr_en_i   => '0',
         wr_data_i => (others => '0'),
         rd_data_o => rd_data_rom_s
      ); -- i_rom


   --------------------------------------------------
   -- Instantiate RAM
   --------------------------------------------------

   i_ram : entity work.memory
      generic map (
         G_ADDR_BITS => 14
      )
      port map (
         clk_i     => clkn_s,
         addr_i    => addr_s(13 downto 0),
         wr_en_i   => wr_en_ram_s,
         wr_data_i => wr_data_s,
         rd_data_o => rd_data_ram_s
      ); -- i_ram


   --------------------------------------------------
   -- Address decoding
   --------------------------------------------------

   wr_en_ram_s <= wr_en_s       when addr_s(15 downto 14) = "00" else '0';
   rd_data_s   <= rd_data_ram_s when addr_s(15 downto 14) = "00" else
                  rd_data_rom_s when addr_s(15 downto 14) = "11" else
                  (others => '0');


   --------------------------------------------------
   -- Show progress of LEDs
   --------------------------------------------------

   led_o <= addr_s;


end architecture synth;

