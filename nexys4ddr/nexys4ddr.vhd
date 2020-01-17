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
   signal clk_cnt_r : std_logic_vector(1 downto 0) := "00";
   signal clk_s     : std_logic;
   signal rst_cnt_r : std_logic_vector(1 downto 0) := "00";
   signal rst_s     : std_logic := '1';

   -- ROM
   type rom_t is array (0 to 15) of std_logic_vector(7 downto 0);
   constant C_ROM_INIT : rom_t := (
      X"88",            -- FFF0  DEY
      X"D0", X"FD",     -- FFF1  BNE $FFF0
      X"CA",            -- FFF3  DEX
      X"D0", X"FA",     -- FFF4  BNE $FFF0
      X"69", X"01",     -- FFF6  ADC #1
      X"85", X"00",     -- FFF8  STA $0
      X"80", X"F4",     -- FFFA  BRA $FFF0
      X"F0", X"FF",     -- FFFC  RESET VECTOR
      X"F0", X"FF"      -- FFFE  IRQ VECTOR
   ); -- C_ROM_INIT

   -- CPU signals
   signal addr_s    : std_logic_vector(15 downto 0);
   signal wr_en_s   : std_logic;
   signal wr_data_s : std_logic_vector( 7 downto 0);
   signal rd_en_s   : std_logic;
   signal rd_data_s : std_logic_vector( 7 downto 0);

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
   -- Read from ROM
   --------------------------------------------------

   rd_data_s <= C_ROM_INIT(to_integer(addr_s(3 downto 0)));



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
      

   p_led : process (clk_s)
   begin
      if rising_edge(clk_s) then
         if addr_s = 0 and wr_en_s = '1' then
            led_o(7 downto 0)  <= wr_data_s;
            led_o(15 downto 8) <= (others => '0');
         end if;
      end if;
   end process p_led;

end architecture synth;

