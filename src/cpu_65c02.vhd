library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

-- This module implements the 65C02 CPU.

entity cpu_65c02 is
   port (
      clk_i     : in  std_logic;
      rst_i     : in  std_logic;
      nmi_i     : in  std_logic;
      irq_i     : in  std_logic;
      addr_o    : out std_logic_vector(15 downto 0);
      wr_en_o   : out std_logic;
      wr_data_o : out std_logic_vector( 7 downto 0);
      rd_en_o   : out std_logic;
      rd_data_i : in  std_logic_vector( 7 downto 0);
      debug_o   : out std_logic_vector(15 downto 0)
   );
end entity cpu_65c02;

architecture synth of cpu_65c02 is

   signal ar_sel    : std_logic;
   signal hi_sel    : std_logic_vector(2 downto 0);
   signal lo_sel    : std_logic_vector(2 downto 0);
   signal pc_sel    : std_logic_vector(6 downto 0);
   signal addr_sel  : std_logic_vector(3 downto 0);
   signal data_sel  : std_logic_vector(2 downto 0);
   signal alu_sel   : std_logic_vector(5 downto 0);
   signal sr_sel    : std_logic_vector(3 downto 0);
   signal sp_sel    : std_logic_vector(1 downto 0);
   signal xr_sel    : std_logic;
   signal yr_sel    : std_logic;
   signal mr_sel    : std_logic_vector(1 downto 0);
   signal reg_sel   : std_logic_vector(2 downto 0);
   signal zp_sel    : std_logic_vector(1 downto 0);
   signal sri       : std_logic;

   -- Debug
   signal ctl_debug : std_logic_vector(63 downto 0);
   signal last_pc   : std_logic_vector(15 downto 0);

begin

   ------------------------
   -- Instantiate datapath
   ------------------------

   i_datapath : entity work.datapath
      port map (
         clk_i      => clk_i,
         wait_i     => '0',
         addr_o     => addr_o,
         data_i     => rd_data_i,
         rden_o     => rd_en_o,
         data_o     => wr_data_o,
         wren_o     => wr_en_o,
         sri_o      => sri,
         ar_sel_i   => ar_sel,
         hi_sel_i   => hi_sel,
         lo_sel_i   => lo_sel,
         pc_sel_i   => pc_sel,
         addr_sel_i => addr_sel,
         data_sel_i => data_sel,
         alu_sel_i  => alu_sel,
         sr_sel_i   => sr_sel,
         sp_sel_i   => sp_sel,
         xr_sel_i   => xr_sel,
         yr_sel_i   => yr_sel,
         mr_sel_i   => mr_sel,
         reg_sel_i  => reg_sel,
         zp_sel_i   => zp_sel,
         debug_o    => open
      ); -- i_datapath


   -----------------------------
   -- Instantiate control logic
   -----------------------------

   i_control : entity work.control
      port map (
         clk_i      => clk_i,
         rst_i      => rst_i,
         nmi_i      => nmi_i,
         irq_i      => irq_i,
         wait_i     => '0',
         sri_i      => sri,
         data_i     => rd_data_i,
         ar_sel_o   => ar_sel,
         hi_sel_o   => hi_sel,
         lo_sel_o   => lo_sel,
         pc_sel_o   => pc_sel,
         addr_sel_o => addr_sel,
         data_sel_o => data_sel,
         alu_sel_o  => alu_sel,
         sr_sel_o   => sr_sel,
         sp_sel_o   => sp_sel,
         xr_sel_o   => xr_sel,
         yr_sel_o   => yr_sel,
         mr_sel_o   => mr_sel,
         reg_sel_o  => reg_sel,
         zp_sel_o   => zp_sel,
         invalid_o  => open,
         debug_o    => ctl_debug
      ); -- i_ctl

   p_debug : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if ctl_debug(2 downto 0) = 0 then
            -- Start of new instruction.
            assert last_pc /= addr_o
               report "Infinite loop detected"
                  severity error;
            last_pc <= addr_o;
         end if;
      end if;
   end process p_debug;

   debug_o <= last_pc;

end architecture synth;

