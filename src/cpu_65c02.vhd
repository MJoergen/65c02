library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

-- This module implements the 65C02 CPU.

entity cpu_65c02 is
   port (
      clk_i     : in  std_logic;
      rst_i     : in  std_logic;
      ce_i      : in  std_logic := '1';
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
   signal ctl_debug      : std_logic_vector(63 downto 0);
   signal datapath_debug : std_logic_vector(111 downto 0);
   signal last_pc        : std_logic_vector(15 downto 0);

   type strings_t is array (natural range <>) of string;
   constant C_DISAS : strings_t(0 to 255) := (
      "BRK", "ORA", "???", "???", "???", "ORA", "ASL", "???", "PHP", "ORA", "ASL", "???", "???", "ORA", "ASL", "???",
      "BPL", "ORA", "???", "???", "???", "ORA", "ASL", "???", "CLC", "ORA", "???", "???", "???", "ORA", "ASL", "???",
      "JSR", "AND", "???", "???", "BIT", "AND", "ROL", "???", "PLP", "AND", "ROL", "???", "BIT", "AND", "ROL", "???",
      "BMI", "AND", "???", "???", "???", "AND", "ROL", "???", "SEC", "AND", "???", "???", "???", "AND", "ROL", "???",
      "RTI", "EOR", "???", "???", "???", "EOR", "LSR", "???", "PHA", "EOR", "LSR", "???", "JMP", "EOR", "LSR", "???",
      "BVC", "EOR", "???", "???", "???", "EOR", "LSR", "???", "CLI", "EOR", "???", "???", "???", "EOR", "LSR", "???",
      "RTS", "ADC", "???", "???", "???", "ADC", "ROR", "???", "PLA", "ADC", "ROR", "???", "JMP", "ADC", "ROR", "???",
      "BVS", "ADC", "???", "???", "???", "ADC", "ROR", "???", "SEI", "ADC", "???", "???", "???", "ADC", "ROR", "???",
      "???", "STA", "???", "???", "STY", "STA", "STX", "???", "DEY", "???", "TXA", "???", "STY", "STA", "STX", "???",
      "BCC", "STA", "???", "???", "STY", "STA", "STX", "???", "TYA", "STA", "TXS", "???", "???", "STA", "???", "???",
      "LDY", "LDA", "LDX", "???", "LDY", "LDA", "LDX", "???", "TAY", "LDA", "TAX", "???", "LDY", "LDA", "LDX", "???",
      "BCS", "LDA", "???", "???", "LDY", "LDA", "LDX", "???", "CLV", "LDA", "TSX", "???", "LDY", "LDA", "LDX", "???",
      "CPY", "CMP", "???", "???", "CPY", "CMP", "DEC", "???", "INY", "CMP", "DEX", "???", "CPY", "CMP", "DEC", "???",
      "BNE", "CMP", "???", "???", "???", "CMP", "DEC", "???", "CLD", "CMP", "???", "???", "???", "CMP", "DEC", "???",
      "CPX", "SBC", "???", "???", "CPX", "SBC", "INC", "???", "INX", "SBC", "NOP", "???", "CPX", "SBC", "INC", "???",
      "BEQ", "SBC", "???", "???", "???", "SBC", "INC", "???", "SED", "SBC", "???", "???", "???", "SBC", "INC", "???" 
   );

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
         debug_o    => datapath_debug
      ); -- i_datapath


   -----------------------------
   -- Instantiate control logic
   -----------------------------

   i_control : entity work.control
      port map (
         clk_i      => clk_i,
         rst_i      => rst_i,
         ce_i       => ce_i,
         nmi_i      => nmi_i,
         irq_i      => irq_i,
         wait_i     => '0',
         sri_i      => sri,
         addr_i     => addr_o,
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
         if ce_i = '1' then
            if ctl_debug(2 downto 0) = 0 then
               -- Start of new instruction.
               report "CPU: " & to_hstring(addr_o) & " : " & to_hstring(rd_data_i) & " " &
                  C_DISAS(to_integer(rd_data_i)) & " : "
                  & to_hstring(datapath_debug( 23 downto  16))
                  & to_hstring(datapath_debug(111 downto 104))
                  & to_hstring(datapath_debug(103 downto  96))
                  & to_hstring(datapath_debug( 95 downto  88));

               assert last_pc /= addr_o
                  report "Infinite loop detected"
                     severity error;
               last_pc <= addr_o;
            end if;
         end if;
      end if;
   end process p_debug;

   debug_o <= last_pc;

end architecture synth;

