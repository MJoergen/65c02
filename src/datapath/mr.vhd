library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity mr is
   port (
      clk_i    : in  std_logic;
      wait_i   : in  std_logic;
      mr_sel_i : in  std_logic_vector(1 downto 0);
      data_i   : in  std_logic_vector(7 downto 0);
      alu_ar_i : in  std_logic_vector(7 downto 0);

      mr_o     : out std_logic_vector(7 downto 0)
   );
end entity mr;

architecture structural of mr is

   constant MR_NOP  : std_logic_vector(1 downto 0) := B"00";
   constant MR_DATA : std_logic_vector(1 downto 0) := B"01";
   constant MR_ALU  : std_logic_vector(1 downto 0) := B"10";

   -- 'A' register
   signal mr : std_logic_vector(7 downto 0);

begin

   -- 'A' register
   mr_proc : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if wait_i = '0' then
            case mr_sel_i is
               when MR_NOP  => null;
               when MR_DATA => mr <= data_i;
               when MR_ALU  => mr <= alu_ar_i;
               when others  => null;
            end case;
         end if;
      end if;
   end process mr_proc;

   -- Drive output signal
   mr_o <= mr;

end architecture structural;

