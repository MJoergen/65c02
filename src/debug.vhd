library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std_unsigned.all;

library std;
  use std.textio.all;

library work;
  use work.fmt.fmt;
  use work.fmt.f;

entity debug is
  generic (
    G_LOG_NAME      : string := "";
    G_ENABLE_IOPORT : boolean;
    G_VARIANT       : string;
    G_VERBOSE       : natural
  );
  port (
    clk_i       : in    std_logic;
    rst_i       : in    std_logic;
    ce_i        : in    std_logic;
    sync_i      : in    std_logic;
    invalid_i   : in    std_logic_vector( 7 downto 0);
    addr_i      : in    std_logic_vector(15 downto 0);
    rd_data_i   : in    std_logic_vector( 7 downto 0);
    wr_data_i   : in    std_logic_vector( 7 downto 0);
    regs_i      : in    std_logic_vector(31 downto 0);
    ioport_i    : in    std_logic_vector(23 downto 0);
    mem_read_i  : in    std_logic;
    mem_write_i : in    std_logic;
    debug_o     : out   std_logic_vector(15 downto 0)
  );
end entity debug;

architecture simulation of debug is

  -- Assembly nmemonics
  type     strings_type is array (natural range <>) of string(1 to 3);
  constant C_DISAS_6502 : strings_type(0 to 255)            := (
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
    ); -- constant C_DISAS_6502 : strings_type(0 to 255)            := (

  constant C_DISAS_65C02 : strings_type(0 to 255)              := (
      "BRK", "ORA", "NOP", "NOP", "TSB", "ORA", "ASL", "RMB", "PHP", "ORA", "ASL", "NOP", "TSB", "ORA", "ASL", "BBR",
      "BPL", "ORA", "ORA", "NOP", "TRB", "ORA", "ASL", "RMB", "CLC", "ORA", "INC", "NOP", "TRB", "ORA", "ASL", "BBR",
      "JSR", "AND", "NOP", "NOP", "BIT", "AND", "ROL", "RMB", "PLP", "AND", "ROL", "NOP", "BIT", "AND", "ROL", "BBR",
      "BMI", "AND", "AND", "NOP", "BIT", "AND", "ROL", "RMB", "SEC", "AND", "DEC", "NOP", "BIT", "AND", "ROL", "BBR",
      "RTI", "EOR", "NOP", "NOP", "NOP", "EOR", "LSR", "RMB", "PHA", "EOR", "LSR", "NOP", "JMP", "EOR", "LSR", "BBR",
      "BVC", "EOR", "EOR", "NOP", "NOP", "EOR", "LSR", "RMB", "CLI", "EOR", "PHY", "NOP", "NOP", "EOR", "LSR", "BBR",
      "RTS", "ADC", "NOP", "NOP", "STZ", "ADC", "ROR", "RMB", "PLA", "ADC", "ROR", "NOP", "JMP", "ADC", "ROR", "BBR",
      "BVS", "ADC", "ADC", "NOP", "STZ", "ADC", "ROR", "RMB", "SEI", "ADC", "PLY", "NOP", "JMP", "ADC", "ROR", "BBR",
      "BRA", "STA", "NOP", "NOP", "STY", "STA", "STX", "SMB", "DEY", "BIT", "TXA", "NOP", "STY", "STA", "STX", "BBS",
      "BCC", "STA", "STA", "NOP", "STY", "STA", "STX", "SMB", "TYA", "STA", "TXS", "NOP", "STZ", "STA", "STZ", "BBS",
      "LDY", "LDA", "LDX", "NOP", "LDY", "LDA", "LDX", "SMB", "TAY", "LDA", "TAX", "NOP", "LDY", "LDA", "LDX", "BBS",
      "BCS", "LDA", "LDA", "NOP", "LDY", "LDA", "LDX", "SMB", "CLV", "LDA", "TSX", "NOP", "LDY", "LDA", "LDX", "BBS",
      "CPY", "CMP", "NOP", "NOP", "CPY", "CMP", "DEC", "SMB", "INY", "CMP", "DEX", "WAI", "CPY", "CMP", "DEC", "BBS",
      "BNE", "CMP", "CMP", "NOP", "NOP", "CMP", "DEC", "SMB", "CLD", "CMP", "PHX", "STP", "NOP", "CMP", "DEC", "BBS",
      "CPX", "SBC", "NOP", "NOP", "CPX", "SBC", "INC", "SMB", "INX", "SBC", "NOP", "NOP", "CPX", "SBC", "INC", "BBS",
      "BEQ", "SBC", "SBC", "NOP", "NOP", "SBC", "INC", "SMB", "SED", "SBC", "PLX", "NOP", "NOP", "SBC", "INC", "BBS"
    ); -- constant C_DISAS_65C02 : strings_t(0 to 255)              := (

  signal   C_DISAS : strings_type(0 to 255);

  type     nat_vector_type is array (natural range <>) of natural;

  -- Addressing modes
  constant C_ADDR_MODE_6502 : nat_vector_type(0 to 255)     := (
       1, 5, 0, 0, 0, 7,  7, 0, 1,  4, 11, 0,  0, 3,  3, 0,
       2, 6, 0, 0, 0, 8,  8, 0, 1, 10,  0, 0,  0, 9,  9, 0,
      17, 5, 0, 0, 7, 7,  7, 0, 1,  4, 11, 0,  3, 3,  3, 0,
       2, 6, 0, 0, 0, 8,  8, 0, 1, 10,  0, 0,  0, 9,  9, 0,
       1, 5, 0, 0, 0, 7,  7, 0, 1,  4, 11, 0,  3, 3,  3, 0,
       2, 6, 0, 0, 0, 8,  8, 0, 1, 10,  0, 0,  0, 9,  9, 0,
       1, 5, 0, 0, 0, 7,  7, 0, 1,  4, 11, 0, 13, 3,  3, 0,
       2, 6, 0, 0, 0, 8,  8, 0, 1, 10,  0, 0,  0, 9,  9, 0,
       0, 5, 0, 0, 7, 7,  7, 0, 1,  0,  1, 0,  3, 3,  3, 0,
       2, 6, 0, 0, 8, 8,  8, 0, 1, 10,  1, 0,  0, 9,  0, 0,
       4, 5, 4, 0, 7, 7,  7, 0, 1,  4,  1, 0,  3, 3,  3, 0,
       2, 6, 0, 0, 8, 8, 16, 0, 1, 10,  1, 0,  9, 9, 10, 0,
       4, 5, 0, 0, 7, 7,  7, 0, 1,  4,  1, 0,  3, 3,  3, 0,
       2, 6, 0, 0, 0, 8,  8, 0, 1, 10,  0, 0,  0, 9,  9, 0,
       4, 5, 0, 0, 7, 7,  7, 0, 1,  4,  1, 0,  3, 3,  3, 0,
       2, 6, 0, 0, 0, 8,  8, 0, 1, 10,  0, 0,  0, 9,  9, 0
    ); -- constant C_ADDR_MODE_6502 : nat_vector_type(0 to 255)     := (

  constant C_ADDR_MODE_65C02 : nat_vector_type(0 to 255)    := (
       1, 5,  4, 1, 7, 7,  7, 7, 1,  4, 11, 1,  3, 3,  3, 15,
       2, 6, 12, 1, 7, 8,  8, 7, 1, 10, 11, 1,  3, 9,  9, 15,
      17, 5,  4, 1, 7, 7,  7, 7, 1,  4, 11, 1,  3, 3,  3, 15,
       2, 6, 12, 1, 8, 8,  8, 7, 1, 10, 11, 1,  9, 9,  9, 15,
       1, 5,  4, 1, 7, 7,  7, 7, 1,  4, 11, 1,  3, 3,  3, 15,
       2, 6, 12, 1, 8, 8,  8, 7, 1, 10,  1, 1,  3, 9,  9, 15,
       1, 5,  4, 1, 7, 7,  7, 7, 1,  4, 11, 1, 13, 3,  3, 15,
       2, 6, 12, 1, 8, 8,  8, 7, 1, 10,  1, 1, 14, 9,  9, 15,
       2, 5,  4, 1, 7, 7,  7, 7, 1,  4,  1, 1,  3, 3,  3, 15,
       2, 6, 12, 1, 8, 8,  8, 7, 1, 10,  1, 1,  3, 9,  3, 15,
       4, 5,  4, 1, 7, 7,  7, 7, 1,  4,  1, 1,  3, 3,  3, 15,
       2, 6, 12, 1, 8, 8, 16, 7, 1, 10,  1, 1,  9, 9, 10, 15,
       4, 5,  4, 1, 7, 7,  7, 7, 1,  4,  1, 1,  3, 3,  3, 15,
       2, 6, 12, 1, 8, 8,  8, 7, 1, 10,  1, 1,  3, 9,  9, 15,
       4, 5,  4, 1, 7, 7,  7, 7, 1,  4,  1, 1,  3, 3,  3, 15,
       2, 6, 12, 1, 8, 8,  8, 7, 1, 10,  1, 1,  3, 9,  9, 15
    ); -- constant C_ADDR_MODE_65C02 : nat_vector_type(0 to 255)    := (

  signal   C_ADDR_MODE : nat_vector_type(0 to 255);

  -- Instruction length
  constant C_ADDR_MODE_TO_LENGTH : nat_vector_type(0 to 17) := (
      0, -- INVALID
      1, -- impl
      2, -- rel
      3, -- abs
      2, -- #
      2, -- X,ind
      2, -- ind,Y
      2, -- zpg
      2, -- zpg,X
      3, -- abs,X
      3, -- abs,Y
      1, -- A
      2, -- izp
      3, -- ind
      3, -- iax
      2, -- zpr
      2, -- zpg,Y
      6  -- jsr
    ); -- constant C_ADDR_MODE_TO_LENGTH : nat_vector_type(0 to 15) := (

  -- Used to check for loop (jump to same instruction)
  signal last_pc : std_logic_vector(15 downto 0);

  signal clk_cnt : natural;

begin

  variant_gen : if G_VARIANT = "6502" generate
    C_DISAS     <= C_DISAS_6502;
    C_ADDR_MODE <= C_ADDR_MODE_6502;
  elsif G_VARIANT = "65C02" generate
    C_DISAS     <= C_DISAS_65C02;
    C_ADDR_MODE <= C_ADDR_MODE_65C02;
  else generate
    assert false
      report "Unknown G_VARIANT"
        severity failure;
  end generate variant_gen;


  debug_proc : process
    variable l_v                  : line;
    variable clk_cnt_v            : natural := 1;
    variable inst_clk_cnt_first_v : natural := 0;
    variable inst_clk_cnt_last_v  : natural := 0;
    variable inst_bytes_v         : std_logic_vector(47 downto 0);
    variable inst_addr_v          : std_logic_vector(15 downto 0);
    variable inst_length_v        : natural := 0;
    variable opcode_v             : natural;
    variable addr_mode_v          : natural;
    file     tf_v                 : text;

    -- Convert instruction bytes to string
    pure function get_inst_bytes (
      arg : std_logic_vector;
      cnt : natural
    ) return string is
    begin
      if cnt = 1 then
        return to_hstring(arg(7 downto 0)) & "      ";
      elsif cnt = 2 then
        return to_hstring(arg(15 downto 8)) & " " & to_hstring(arg(7 downto 0)) & "   ";
      else
        if arg(47 downto 40) = X"20" then
          return to_hstring(arg(47 downto 40)) & " " & to_hstring(arg(39 downto 32)) & " " & to_hstring(arg(7 downto 0));
        end if;
        return to_hstring(arg(23 downto 16)) & " " & to_hstring(arg(15 downto 8)) & " " & to_hstring(arg(7 downto 0));
      end if;
    end function get_inst_bytes;

    -- Disassemble a complete instruction
    impure function get_inst_str (
      arg : std_logic_vector;
      cnt : natural;            -- Instruction length (in bytes)
      offset : std_logic_vector -- Address of next byte
    ) return string is
      variable opcode_v    : natural;
      variable oplo_v      : std_logic_vector(7 downto 0);
      variable ophi_v      : std_logic_vector(7 downto 0);
      variable addr_mode_v : natural;
      variable diff_v      : std_logic_vector(15 downto 0);
    begin
      opcode_v := to_integer(arg((cnt - 1) * 8 + 7 downto (cnt - 1) * 8));
      if cnt >= 2 then
        oplo_v := arg((cnt - 2) * 8 + 7 downto (cnt - 2) * 8);
        if cnt >= 3 then
          ophi_v := arg((cnt - 3) * 8 + 7 downto (cnt - 3) * 8);
          if opcode_v = X"20" then
            ophi_v := arg((cnt - 6) * 8 + 7 downto (cnt - 6) * 8);
          end if;
        end if;
      end if;
      addr_mode_v := C_ADDR_MODE(opcode_v);

      case addr_mode_v is

        when 0 =>
          assert false; return "???";

        when 1 =>  -- impl
          return C_DISAS(opcode_v) & "          ";

        when 2 =>  -- rel
          diff_v(15 downto 8) := (others => oplo_v(7));
          diff_v(7 downto 0)  := oplo_v;
          return C_DISAS(opcode_v) & " $" & to_hstring(offset + diff_v) & "    ";

        when 3 =>  -- abs
          return C_DISAS(opcode_v) & " $" & to_hstring(ophi_v & oplo_v) & "    ";

        when 4 =>  -- #
          return C_DISAS(opcode_v) & " #$" & to_hstring(oplo_v) & "     ";

        when 5 =>  -- X, ind
          return C_DISAS(opcode_v) & " ($" & to_hstring(oplo_v) & ",X)" & "  ";

        when 6 =>  -- ind, Y
          return C_DISAS(opcode_v) & " ($" & to_hstring(oplo_v) & "),Y" & "  ";

        when 7 =>  -- zpg
          return C_DISAS(opcode_v) & " $" & to_hstring(oplo_v) & "      ";

        when 8 =>  -- zpg, X
          return C_DISAS(opcode_v) & " $" & to_hstring(oplo_v) & ",X" & "    ";

        when 9 =>  -- abs, X
          return C_DISAS(opcode_v) & " $" & to_hstring(ophi_v & oplo_v) & ",X" & "  ";

        when 10 => -- abs, Y
          return C_DISAS(opcode_v) & " $" & to_hstring(ophi_v & oplo_v) & ",Y" & "  ";

        when 11 => -- A
          return C_DISAS(opcode_v) & " A" & "        ";

        when 12 => -- izp
          return C_DISAS(opcode_v) & " ($" & to_hstring(oplo_v) & ")" & "    ";

        when 13 => -- ind
          return C_DISAS(opcode_v) & " ($" & to_hstring(ophi_v & oplo_v) & ")" & "  ";

        when 14 => -- iax
          return C_DISAS(opcode_v) & " ($" & to_hstring(ophi_v & oplo_v) & ",X)";

        when 15 => -- zpr
          diff_v(15 downto 8) := (others => oplo_v(7));
          diff_v(7 downto 0)  := oplo_v;
          return C_DISAS(opcode_v) & " $" & to_hstring(offset + diff_v) & "    ";

        when 16 => -- zpg, Y
          return C_DISAS(opcode_v) & " $" & to_hstring(oplo_v) & ",Y" & "    ";

        when 17 => -- jsr
          return C_DISAS(opcode_v) & " $" & to_hstring(ophi_v & oplo_v) & "    ";

        when others =>
          assert false; return "???";

      end case;

    --
    end function get_inst_str;

  begin
    if G_LOG_NAME = "" then
      wait;
    end if;
    file_open(tf_v, G_LOG_NAME, write_mode);
    main_loop : loop
      wait until rising_edge(clk_i);

      if ce_i = '1' and rst_i = '0' then
        if G_VERBOSE >= 1 then
          clk_cnt_v := clk_cnt_v + 1;
          clk_cnt <= clk_cnt_v;

          if sync_i = '1' then
            opcode_v             := to_integer(rd_data_i);
            addr_mode_v          := C_ADDR_MODE(opcode_v);
            inst_length_v        := C_ADDR_MODE_TO_LENGTH(addr_mode_v);
            assert inst_length_v > 0;
            inst_clk_cnt_first_v := clk_cnt_v;
            inst_clk_cnt_last_v  := clk_cnt_v + inst_length_v - 1;
            inst_addr_v          := addr_i;

            assert invalid_i = X"00"
              report "Invalid instruction " & to_hstring(invalid_i)
              severity failure;

            assert last_pc /= addr_i
              report "Infinite loop detected"
              severity failure;
            last_pc              <= addr_i;
          end if;

          inst_bytes_v := inst_bytes_v(39 downto 0) & rd_data_i;

          if clk_cnt_v = inst_clk_cnt_last_v then
            std.textio.write(l_v, fmt(".{}  {}  {}    {}  {}",
                             to_hstring(inst_addr_v),
                             f(inst_clk_cnt_last_v - inst_length_v + 1, ">8d"),
                             get_inst_bytes(inst_bytes_v, inst_length_v),
                             get_inst_str(inst_bytes_v, inst_length_v, inst_addr_v + 2),
                             to_hstring(regs_i)
                             ));
            writeline(tf_v, l_v);

            inst_length_v := 0;
          end if;

          if G_VERBOSE >= 2 then
            if mem_read_i = '1' then
              std.textio.write(l_v, fmt("       {}  Read from 0x{}",
                               f(clk_cnt_v, ">8d"),
                               to_hstring(addr_i)
                               ));
              writeline(tf_v, l_v);
            end if;

            if mem_write_i = '1' then
              std.textio.write(l_v, fmt("       {}  Write 0x{} to 0x{}",
                               f(clk_cnt_v, ">8d"),
                               to_hstring(wr_data_i),
                               to_hstring(addr_i)
                               ));
              writeline(tf_v, l_v);
            end if;
          end if;
        end if;
      end if;
    end loop main_loop;
  end process debug_proc;

  debug_o <= last_pc;

end architecture simulation;

