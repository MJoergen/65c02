library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

-- This module implements the 6502 CPU and/or one of its variants.
-- G_VARIANT is one of:
-- "65C02" : The Rockwell 65C02
-- "6502"  : Vanilla 6502

entity cpu_65c02 is
   generic (
      G_SIM           : boolean;
      G_ENABLE_IOPORT : boolean := false;
      G_VARIANT       : string := "65C02";
      G_VERBOSE       : natural := 2
   );
   port (
      clk_i        : in  std_logic;
      rst_i        : in  std_logic;
      ce_i         : in  std_logic := '1';
      nmi_i        : in  std_logic;
      nmi_ack_o    : out std_logic;
      irq_i        : in  std_logic;
      addr_o       : out std_logic_vector(15 downto 0);
      wr_en_o      : out std_logic;
      wr_data_o    : out std_logic_vector( 7 downto 0);
      rd_en_o      : out std_logic;
      rd_data_i    : in  std_logic_vector( 7 downto 0);
      ioport_in_i  : in  std_logic_vector( 7 downto 0);
      ioport_out_o : out std_logic_vector( 7 downto 0);
      ioport_dir_o : out std_logic_vector( 7 downto 0);
      debug_o      : out std_logic_vector(15 downto 0)
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
   signal rd_data   : std_logic_vector(7 downto 0);
   signal ioport_in : std_logic_vector(7 downto 0);
   signal branch    : std_logic_vector(1 downto 0); -- Bit 0: Branch taken, Bit 1: Wrap

   -- Debug
   signal invalid        : std_logic_vector(7 downto 0);
   signal ctl_debug      : std_logic_vector(63 downto 0);
   signal datapath_debug : std_logic_vector(111 downto 0);
   signal last_pc        : std_logic_vector(15 downto 0);
   signal ar             : std_logic_vector(7 downto 0);
   signal xr             : std_logic_vector(7 downto 0);
   signal yr             : std_logic_vector(7 downto 0);
   signal sr             : std_logic_vector(7 downto 0);
   signal sp             : std_logic_vector(7 downto 0);

   pure function to_sl(arg : boolean) return std_logic is
   begin
     if arg then
       return '1';
     else
       return '0';
     end if;
   end function to_sl;

begin

   ------------------------
   -- Instantiate datapath
   ------------------------

   i_datapath : entity work.datapath
      port map (
         clk_i      => clk_i,
         ce_i       => ce_i,
         wait_i     => '0',
         addr_o     => addr_o,
         data_i     => rd_data,
         rden_o     => rd_en_o,
         data_o     => wr_data_o,
         wren_o     => wr_en_o,
         sri_o      => sri,
         branch_o   => branch,
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
         debug_o    => datapath_debug
      ); -- i_datapath


   -----------------------------
   -- Instantiate control logic
   -----------------------------

   i_control : entity work.control
      generic map (
         G_VARIANT => G_VARIANT
      )
      port map (
         clk_i      => clk_i,
         rst_i      => rst_i,
         ce_i       => ce_i,
         nmi_i      => nmi_i,
         nmi_ack_o  => nmi_ack_o,
         irq_i      => irq_i,
         wait_i     => '0',
         sri_i      => sri,
         addr_i     => addr_o,
         data_i     => rd_data,
         branch_i   => branch,
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
         invalid_o  => invalid,
         debug_o    => ctl_debug
      ); -- i_ctl

   p_ioport : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if ce_i = '1' then
            if addr_o = X"0000" and wr_en_o = '1' then
               ioport_dir_o <= wr_data_o;
            end if;
            if addr_o = X"0001" and wr_en_o = '1' then
               ioport_out_o <= wr_data_o;
            end if;
         end if;
         if rst_i = '1' then
            ioport_dir_o <= X"FF";
            ioport_out_o <= X"FF";
         end if;
      end if;
   end process p_ioport;

   ioport_in <= (ioport_out_o and ioport_dir_o) or (ioport_in_i and not ioport_dir_o);

   rd_data <= ioport_dir_o when G_ENABLE_IOPORT and addr_o = X"0000" else
              ioport_in    when G_ENABLE_IOPORT and addr_o = X"0001" else
              rd_data_i;



   ar <= datapath_debug( 23 downto  16);
   xr <= datapath_debug(111 downto 104);
   yr <= datapath_debug(103 downto  96);
   sr <= datapath_debug( 87 downto  80);
   sp <= datapath_debug( 95 downto  88);

   debug_gen : if G_SIM generate
      debug_inst : entity work.debug
         generic map (
            G_ENABLE_IOPORT => G_ENABLE_IOPORT,
            G_VARIANT       => G_VARIANT,
            G_VERBOSE       => G_VERBOSE
         )
         port map (
            clk_i       => clk_i,
            rst_i       => rst_i,
            ce_i        => ce_i,
            sync_i      => to_sl(ctl_debug(2 downto 0) = 0),
            invalid_i   => invalid,
            addr_i      => addr_o,
            rd_data_i   => rd_data,
            wr_data_i   => wr_data_o,
            regs_i      => ar & xr & yr & sp,
            ioport_i    => ioport_out_o & ioport_in_i & ioport_dir_o,
            mem_read_i  => to_sl(pc_sel /= "0000001" and addr_sel /= "0001" and addr_sel /= "0000" and wr_en_o = '0'),
            mem_write_i => wr_en_o,
            debug_o     => debug_o
         ); -- debug_inst : entity work.debug
   end generate debug_gen;

end architecture synth;

