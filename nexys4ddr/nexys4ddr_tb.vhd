library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

-- This is the top level module of the Nexys4DDR. The ports on this entity are mapped
-- directly to pins on the FPGA.

entity nexys4ddr_tb is
   generic (
      G_VARIANT : string
   );
end nexys4ddr_tb;

architecture sim of nexys4ddr_tb is

   signal clk_s : std_logic;
   signal led_s : std_logic_vector(15 downto 0);

begin

   p_clk : process
   begin
      clk_s <= '1', '0' after 5 ns;
      wait for 10 ns;  -- 100 MHz
   end process p_clk;


   -- Instantiate DUT
   i_nexys4ddr : entity work.nexys4ddr
      generic map (
         G_VARIANT => G_VARIANT
      )
      port map (
         clk_i => clk_s,
         led_o => led_s
      );

end architecture sim;

