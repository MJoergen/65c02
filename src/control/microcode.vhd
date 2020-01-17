library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity microcode is
   port (
      clk_i  : in  std_logic;
      addr_i : in  std_logic_vector(10 downto 0);
      data_o : out std_logic_vector(43 downto 0)
   );
end entity microcode;

architecture structural of microcode is

   subtype t_ctl is std_logic_vector(43 downto 0);

   constant NOP         : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000000_000_000_0";
   --
   constant AR_ALU      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000000_000_000_1";
   --
   constant HI_DATA     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000000_000_001_0";
   constant HI_ADDX     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000000_000_010_0";
   constant HI_ADDY     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000000_000_011_0";
   constant HI_INC      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000000_000_100_0";
   --
   constant LO_DATA     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000000_001_000_0";
   constant LO_ADDX     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000000_010_000_0";
   constant LO_ADDY     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000000_011_000_0";
   constant LO_INC      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000000_100_000_0";
   --
   constant PC_INC      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000001_000_000_0";
   constant PC_HL       : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000010_000_000_0";
   constant PC_HL1      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000011_000_000_0";
   constant PC_BPL      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000100_000_000_0";
   constant PC_BMI      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0010100_000_000_0";
   constant PC_BVC      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0100100_000_000_0";
   constant PC_BVS      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0110100_000_000_0";
   constant PC_BCC      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_1000100_000_000_0";
   constant PC_BCS      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_1010100_000_000_0";
   constant PC_BNE      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_1100100_000_000_0";
   constant PC_BEQ      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_1110100_000_000_0";
   constant PC_D_HI     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000101_000_000_0";
   constant PC_D_LO     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000110_000_000_0";
   constant PC_BRA      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000111_000_000_0";
   constant PC_BBR0     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0001000_000_000_0";
   constant PC_BBR1     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0011000_000_000_0";
   constant PC_BBR2     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0101000_000_000_0";
   constant PC_BBR3     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0111000_000_000_0";
   constant PC_BBR4     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_1001000_000_000_0";
   constant PC_BBR5     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_1011000_000_000_0";
   constant PC_BBR6     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_1101000_000_000_0";
   constant PC_BBR7     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_1111000_000_000_0";
   constant PC_BBS0     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0001001_000_000_0";
   constant PC_BBS1     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0011001_000_000_0";
   constant PC_BBS2     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0101001_000_000_0";
   constant PC_BBS3     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0111001_000_000_0";
   constant PC_BBS4     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_1001001_000_000_0";
   constant PC_BBS5     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_1011001_000_000_0";
   constant PC_BBS6     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_1101001_000_000_0";
   constant PC_BBS7     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_1111001_000_000_0";
   --
   constant ADDR_PC     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0001_0000000_000_000_0";
   constant ADDR_HL     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0010_0000000_000_000_0";
   constant ADDR_LO     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0011_0000000_000_000_0";
   constant ADDR_SP     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0100_0000000_000_000_0";
   constant ADDR_ZP     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0101_0000000_000_000_0";
   constant ADDR_NMI    : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_1010_0000000_000_000_0";
   constant ADDR_NMI1   : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_1011_0000000_000_000_0";
   constant ADDR_RESET  : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_1100_0000000_000_000_0";
   constant ADDR_RESET1 : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_1101_0000000_000_000_0";
   constant ADDR_IRQ    : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_1110_0000000_000_000_0";
   constant ADDR_IRQ1   : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_1111_0000000_000_000_0";
   --
   constant DATA_AR     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_001_0000_0000000_000_000_0";
   constant DATA_SR     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_010_0000_0000000_000_000_0";
   constant DATA_ALU    : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_011_0000_0000000_000_000_0";
   constant DATA_PCLO   : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_100_0000_0000000_000_000_0";
   constant DATA_PCHI   : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_101_0000_0000000_000_000_0";
   constant DATA_SRI    : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_110_0000_0000000_000_000_0";
   constant DATA_Z      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_111_0000_0000000_000_000_0";
   --
   constant LAST        : t_ctl := B"0_00_00_000_0_0_00_0000_000000_1_000_0000_0000000_000_000_0";
   --
   constant ALU_ORA     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000000_000_000_0";
   constant ALU_AND     : t_ctl := B"0_00_00_000_0_0_00_0000_000001_0_000_0000_0000000_000_000_0";
   constant ALU_EOR     : t_ctl := B"0_00_00_000_0_0_00_0000_000010_0_000_0000_0000000_000_000_0";
   constant ALU_ADC     : t_ctl := B"0_00_00_000_0_0_00_0000_000011_0_000_0000_0000000_000_000_0";
   constant ALU_STA     : t_ctl := B"0_00_00_000_0_0_00_0000_000100_0_000_0000_0000000_000_000_0";
   constant ALU_LDA     : t_ctl := B"0_00_00_000_0_0_00_0000_000101_0_000_0000_0000000_000_000_0";
   constant ALU_CMP     : t_ctl := B"0_00_00_000_0_0_00_0000_000110_0_000_0000_0000000_000_000_0";
   constant ALU_SBC     : t_ctl := B"0_00_00_000_0_0_00_0000_000111_0_000_0000_0000000_000_000_0";
   constant ALU_ASL_A   : t_ctl := B"0_00_00_000_0_0_00_0000_001000_0_000_0000_0000000_000_000_0";
   constant ALU_ROL_A   : t_ctl := B"0_00_00_000_0_0_00_0000_001001_0_000_0000_0000000_000_000_0";
   constant ALU_LSR_A   : t_ctl := B"0_00_00_000_0_0_00_0000_001010_0_000_0000_0000000_000_000_0";
   constant ALU_ROR_A   : t_ctl := B"0_00_00_000_0_0_00_0000_001011_0_000_0000_0000000_000_000_0";
   constant ALU_BIT_A   : t_ctl := B"0_00_00_000_0_0_00_0000_001100_0_000_0000_0000000_000_000_0";
   constant ALU_LDA_A   : t_ctl := B"0_00_00_000_0_0_00_0000_001101_0_000_0000_0000000_000_000_0";
   constant ALU_DEC_A   : t_ctl := B"0_00_00_000_0_0_00_0000_001110_0_000_0000_0000000_000_000_0";
   constant ALU_INC_A   : t_ctl := B"0_00_00_000_0_0_00_0000_001111_0_000_0000_0000000_000_000_0";
   constant ALU_BIT_B   : t_ctl := B"0_00_00_000_0_0_00_0000_010100_0_000_0000_0000000_000_000_0";
   constant ALU_TRB     : t_ctl := B"0_00_00_000_0_0_00_0000_010101_0_000_0000_0000000_000_000_0";
   constant ALU_TSB     : t_ctl := B"0_00_00_000_0_0_00_0000_010110_0_000_0000_0000000_000_000_0";
   constant ALU_RMB0    : t_ctl := B"0_00_00_000_0_0_00_0000_110000_0_000_0000_0000000_000_000_0";
   constant ALU_RMB1    : t_ctl := B"0_00_00_000_0_0_00_0000_110001_0_000_0000_0000000_000_000_0";
   constant ALU_RMB2    : t_ctl := B"0_00_00_000_0_0_00_0000_110010_0_000_0000_0000000_000_000_0";
   constant ALU_RMB3    : t_ctl := B"0_00_00_000_0_0_00_0000_110011_0_000_0000_0000000_000_000_0";
   constant ALU_RMB4    : t_ctl := B"0_00_00_000_0_0_00_0000_110100_0_000_0000_0000000_000_000_0";
   constant ALU_RMB5    : t_ctl := B"0_00_00_000_0_0_00_0000_110101_0_000_0000_0000000_000_000_0";
   constant ALU_RMB6    : t_ctl := B"0_00_00_000_0_0_00_0000_110110_0_000_0000_0000000_000_000_0";
   constant ALU_RMB7    : t_ctl := B"0_00_00_000_0_0_00_0000_110111_0_000_0000_0000000_000_000_0";
   constant ALU_SMB0    : t_ctl := B"0_00_00_000_0_0_00_0000_111000_0_000_0000_0000000_000_000_0";
   constant ALU_SMB1    : t_ctl := B"0_00_00_000_0_0_00_0000_111001_0_000_0000_0000000_000_000_0";
   constant ALU_SMB2    : t_ctl := B"0_00_00_000_0_0_00_0000_111010_0_000_0000_0000000_000_000_0";
   constant ALU_SMB3    : t_ctl := B"0_00_00_000_0_0_00_0000_111011_0_000_0000_0000000_000_000_0";
   constant ALU_SMB4    : t_ctl := B"0_00_00_000_0_0_00_0000_111100_0_000_0000_0000000_000_000_0";
   constant ALU_SMB5    : t_ctl := B"0_00_00_000_0_0_00_0000_111101_0_000_0000_0000000_000_000_0";
   constant ALU_SMB6    : t_ctl := B"0_00_00_000_0_0_00_0000_111110_0_000_0000_0000000_000_000_0";
   constant ALU_SMB7    : t_ctl := B"0_00_00_000_0_0_00_0000_111111_0_000_0000_0000000_000_000_0";
   --
   constant SR_ALU      : t_ctl := B"0_00_00_000_0_0_00_0001_000000_0_000_0000_0000000_000_000_0";
   constant SR_DATA     : t_ctl := B"0_00_00_000_0_0_00_0010_000000_0_000_0000_0000000_000_000_0";
   constant SR_CLC      : t_ctl := B"0_00_00_000_0_0_00_1000_000000_0_000_0000_0000000_000_000_0";
   constant SR_SEC      : t_ctl := B"0_00_00_000_0_0_00_1001_000000_0_000_0000_0000000_000_000_0";
   constant SR_CLI      : t_ctl := B"0_00_00_000_0_0_00_1010_000000_0_000_0000_0000000_000_000_0";
   constant SR_SEI      : t_ctl := B"0_00_00_000_0_0_00_1011_000000_0_000_0000_0000000_000_000_0";
   constant SR_CLV      : t_ctl := B"0_00_00_000_0_0_00_1100_000000_0_000_0000_0000000_000_000_0";
   constant SR_CLD      : t_ctl := B"0_00_00_000_0_0_00_1110_000000_0_000_0000_0000000_000_000_0";
   constant SR_SED      : t_ctl := B"0_00_00_000_0_0_00_1111_000000_0_000_0000_0000000_000_000_0";
   --
   constant SP_INC      : t_ctl := B"0_00_00_000_0_0_01_0000_000000_0_000_0000_0000000_000_000_0";
   constant SP_DEC      : t_ctl := B"0_00_00_000_0_0_10_0000_000000_0_000_0000_0000000_000_000_0";
   constant SP_XR       : t_ctl := B"0_00_00_000_0_0_11_0000_000000_0_000_0000_0000000_000_000_0";
   --
   constant XR_ALU      : t_ctl := B"0_00_00_000_0_1_00_0000_000000_0_000_0000_0000000_000_000_0";
   --
   constant YR_ALU      : t_ctl := B"0_00_00_000_1_0_00_0000_000000_0_000_0000_0000000_000_000_0";
   --
   constant REG_AR      : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000000_000_000_0";
   constant REG_XR      : t_ctl := B"0_00_00_001_0_0_00_0000_000000_0_000_0000_0000000_000_000_0";
   constant REG_YR      : t_ctl := B"0_00_00_010_0_0_00_0000_000000_0_000_0000_0000000_000_000_0";
   constant REG_SP      : t_ctl := B"0_00_00_011_0_0_00_0000_000000_0_000_0000_0000000_000_000_0";
   constant REG_MR      : t_ctl := B"0_00_00_100_0_0_00_0000_000000_0_000_0000_0000000_000_000_0";
   --
   constant ZP_DATA     : t_ctl := B"0_00_01_000_0_0_00_0000_000000_0_000_0000_0000000_000_000_0";
   constant ZP_ADDX     : t_ctl := B"0_00_10_000_0_0_00_0000_000000_0_000_0000_0000000_000_000_0";
   constant ZP_INC      : t_ctl := B"0_00_11_000_0_0_00_0000_000000_0_000_0000_0000000_000_000_0";
   --
   constant MR_DATA     : t_ctl := B"0_01_00_000_0_0_00_0000_000000_0_000_0000_0000000_000_000_0";
   constant MR_ALU      : t_ctl := B"0_10_00_000_0_0_00_0000_000000_0_000_0000_0000000_000_000_0";
   --
   constant INVALID     : t_ctl := B"1_00_00_000_0_0_00_0000_000000_0_000_0000_0000000_000_000_0";

   -- Decode control signals
   type t_rom is array(0 to 8*256-1) of t_ctl;

   signal rom : t_rom := (

-- 00 BRK b (also RESET, NMI, and IRQ).
      ADDR_PC + PC_INC,
      PC_INC,
      ADDR_SP + DATA_PCHI + SP_DEC,
      ADDR_SP + DATA_PCLO + SP_DEC,
      ADDR_SP + DATA_SR + SP_DEC,
      ADDR_IRQ + LO_DATA + SR_SEI,
      ADDR_IRQ1 + HI_DATA + SR_CLD,
      PC_HL + LAST,

-- 01 ORA (d,X)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ZP_ADDX,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + ALU_ORA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- 02 NOP
      ADDR_PC + PC_INC,
      PC_INC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 03 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 04 TSB d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + REG_AR + ALU_TSB + MR_ALU + SR_ALU,
      ADDR_LO + REG_MR + ALU_STA + DATA_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 05 ORA d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + ALU_ORA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 06 ASL d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_ASL_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 07 RMB0 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_RMB0 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 08 PHP
      ADDR_PC + PC_INC,
      ADDR_SP + DATA_SR + SP_DEC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 09 ORA #
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ALU_ORA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 0A ASL A
      ADDR_PC + PC_INC,
      ALU_ASL_A + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 0B NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 0C TSB a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + REG_AR + ALU_TSB + MR_ALU + SR_ALU,
      ADDR_HL + REG_MR + ALU_STA + DATA_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 0D ORA a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + ALU_ORA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 0E ASL a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + MR_DATA,
      ADDR_HL + REG_MR + ALU_ASL_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 0F BBR0 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBR0 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 10 BPL r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_BPL + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 11 ORA (d),Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + ALU_ORA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- 12 ORA (d)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + ALU_ORA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 13 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 14 TRB d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + REG_AR + ALU_TRB + MR_ALU + SR_ALU,
      ADDR_LO + REG_MR + ALU_STA + DATA_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 15 ORA d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + ALU_ORA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 16 ASL d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_ASL_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 17 RMB1 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_RMB1 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 18 CLC
      ADDR_PC + PC_INC,
      SR_CLC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 19 ORA a,Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + ALU_ORA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 1A INC
      ADDR_PC + PC_INC,
      REG_AR + ALU_INC_A + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 1B NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 1C TRB a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + REG_AR + ALU_TRB + MR_ALU + SR_ALU,
      ADDR_HL + REG_MR + ALU_STA + DATA_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 1D ORA a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + ALU_ORA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 1E ASL a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + MR_DATA,
      ADDR_HL + REG_MR + ALU_ASL_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- 1F BBR1 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBR1 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 20 JSR a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + HI_DATA,
      ADDR_SP + DATA_PCHI + SP_DEC,
      ADDR_SP + DATA_PCLO + SP_DEC,
      PC_HL + LAST,
      INVALID,
      INVALID,

-- 21 AND (d,X)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ZP_ADDX,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + ALU_AND + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- 22 NOP
      ADDR_PC + PC_INC,
      PC_INC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 23 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 24 BIT d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + ALU_BIT_B + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 25 AND d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + ALU_AND + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 26 ROL d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_ROL_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 27 RMB2 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_RMB2 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 28 PLP
      ADDR_PC + PC_INC,
      SP_INC,
      ADDR_SP + SR_DATA + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 29 AND #
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ALU_AND + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 2A ROL A
      ADDR_PC + PC_INC,
      ALU_ROL_A + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 2B NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 2C BIT a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + ALU_BIT_B + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 2D AND a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + ALU_AND + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 2E ROL a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + MR_DATA,
      ADDR_HL + REG_MR + ALU_ROL_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 2F BBR2 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBR2 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 30 BMI r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_BMI + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 31 AND (d),Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + ALU_AND + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- 32 AND (d)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + ALU_AND + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 33 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 34 BIT d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + ALU_BIT_B + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 35 AND d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + ALU_AND + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 36 ROL d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_ROL_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 37 RMB3 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_RMB3 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 38 SEC
      ADDR_PC + PC_INC,
      SR_SEC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 39 AND a,Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + ALU_AND + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 3A DEC
      ADDR_PC + PC_INC,
      REG_AR + ALU_DEC_A + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 3B NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 3C BIT a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + ALU_BIT_B + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 3D AND a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + ALU_AND + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 3E ROL a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + MR_DATA,
      ADDR_HL + REG_MR + ALU_ROL_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- 3F BBR3 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBR3 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 40 RTI
      ADDR_PC + PC_INC,
      SP_INC,
      ADDR_SP + SP_INC + SR_DATA,
      ADDR_SP + SP_INC + LO_DATA,
      ADDR_SP + HI_DATA,
      PC_HL + LAST,
      INVALID,
      INVALID,

-- 41 EOR (d,X)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ZP_ADDX,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + ALU_EOR + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- 42 NOP
      ADDR_PC + PC_INC,
      PC_INC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 43 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 44 NOP
      ADDR_PC + PC_INC,
      PC_INC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 45 EOR d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + ALU_EOR + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 46 LSR d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_LSR_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 47 RMB4 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_RMB4 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 48 PHA
      ADDR_PC + PC_INC,
      ADDR_SP + DATA_AR + SP_DEC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 49 EOR #
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ALU_EOR + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 4A LSR A
      ADDR_PC + PC_INC,
      ALU_LSR_A + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 4B NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 4C JMP a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      PC_HL + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 4D EOR a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + ALU_EOR + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 4E LSR a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + MR_DATA,
      ADDR_HL + REG_MR + ALU_LSR_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 4F BBR4 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBR4 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 50 BVC r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_BVC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 51 EOR (d),Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + ALU_EOR + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- 52 EOR (d)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + ALU_EOR + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 53 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 54 NOP
      ADDR_PC + PC_INC,
      PC_INC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 55 EOR d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + ALU_EOR + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 56 LSR d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_LSR_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 57 RMB5 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_RMB5 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 58 CLI
      ADDR_PC + PC_INC,
      SR_CLI + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 59 EOR a,Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + ALU_EOR + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 5A PHY
      ADDR_PC + PC_INC,
      ADDR_SP + REG_YR + ALU_STA + DATA_ALU + SP_DEC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 5B NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 5C NOP
      ADDR_PC + PC_INC,
      PC_INC,
      PC_INC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 5D EOR a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + ALU_EOR + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 5E LSR a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + MR_DATA,
      ADDR_HL + REG_MR + ALU_LSR_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- 5F BBR5 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBR5 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 60 RTS
      ADDR_PC + PC_INC,
      SP_INC,
      ADDR_SP + SP_INC + LO_DATA,
      ADDR_SP + HI_DATA,
      PC_HL1 + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 61 ADC (d,X)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ZP_ADDX,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + ALU_ADC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- 62 NOP
      ADDR_PC + PC_INC,
      PC_INC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 63 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 64 STZ d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + DATA_Z + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 65 ADC d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + ALU_ADC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 66 ROR d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_ROR_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 67 RMB6 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_RMB6 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 68 PLA
      ADDR_PC + PC_INC,
      SP_INC,
      ADDR_SP + ALU_LDA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 69 ADC #
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ALU_ADC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 6A ROR A
      ADDR_PC + PC_INC,
      ALU_ROR_A + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 6B NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 6C JMP (a)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + PC_D_LO + HI_INC + LO_INC,
      ADDR_HL + PC_D_HI + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 6D ADC a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + ALU_ADC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 6E ROR a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + MR_DATA,
      ADDR_HL + REG_MR + ALU_ROR_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 6F BBR6 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBR6 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 70 BVS r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_BVS + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 71 ADC (d),Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + ALU_ADC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- 72 ADC (d)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + ALU_ADC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 73 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 74 STX d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + DATA_Z + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 75 ADC d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + ALU_ADC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 76 ROR d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_ROR_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 77 RMB7 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_RMB7 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 78 SEI
      ADDR_PC + PC_INC,
      SR_SEI + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 79 ADC a,Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + ALU_ADC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 7A PLY
      ADDR_PC + PC_INC,
      SP_INC,
      ADDR_SP + ALU_LDA + YR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 7B NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 7C JMP (a,X)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + PC_D_LO + HI_INC + LO_INC,
      ADDR_HL + PC_D_HI + LAST,
      INVALID,
      INVALID,

-- 7D ADC a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + ALU_ADC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 7E ROR a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + MR_DATA,
      ADDR_HL + REG_MR + ALU_ROR_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- 7F BBR7 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBR7 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 80 BRA
      ADDR_PC + PC_INC,
      ADDR_PC + PC_BRA + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 81 STA (d,X)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ZP_ADDX,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + DATA_AR + LAST,
      INVALID,
      INVALID,

-- 82 NOP
      ADDR_PC + PC_INC,
      PC_INC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 83 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 84 STY d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + REG_YR + ALU_STA + DATA_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 85 STA d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + DATA_AR + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 86 STX d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + REG_XR + ALU_STA + DATA_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 87 SMB0 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_SMB0 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 88 DEY
      ADDR_PC + PC_INC,
      REG_YR + ALU_DEC_A + YR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 89 BIT #
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ALU_BIT_A + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 8A TXA
      ADDR_PC + PC_INC,
      REG_XR + ALU_LDA_A + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 8B NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 8C STY a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + REG_YR + ALU_STA + DATA_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 8D STA a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + DATA_AR + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 8E STX a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + REG_XR + ALU_STA + DATA_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 8F BBS0 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBS0 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 90 BCC r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_BCC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 91 STA (d),Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + DATA_AR + LAST,
      INVALID,
      INVALID,

-- 92 STA (d)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + DATA_AR + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 93 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 94 STY d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + REG_YR + ALU_STA + DATA_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 95 STA d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + DATA_AR + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 96 STX d,Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_LO + REG_XR + ALU_STA + DATA_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 97 SMB1 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_SMB1 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 98 TYA
      ADDR_PC + PC_INC,
      REG_YR + ALU_LDA_A + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 99 STA a,Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + DATA_AR + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 9A TXS
      ADDR_PC + PC_INC,
      SP_XR + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 9B NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 9C STZ a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + DATA_Z + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- 9D STA a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + DATA_AR + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 9E STZ a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + DATA_Z + LAST,
      INVALID,
      INVALID,
      INVALID,

-- 9F BBS1 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBS1 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- A0 LDY #
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ALU_LDA + YR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- A1 LDA (d,X)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ZP_ADDX,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + ALU_LDA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- A2 LDX #
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ALU_LDA + XR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- A3 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- A4 LDY d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + ALU_LDA + YR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- A5 LDA d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + ALU_LDA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- A6 LDX d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + ALU_LDA + XR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- A7 SMB2 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_SMB2 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- A8 TAY
      ADDR_PC + PC_INC,
      ALU_LDA_A + YR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- A9 LDA #
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ALU_LDA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- AA TAX
      ADDR_PC + PC_INC,
      ALU_LDA_A + XR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- AB NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- AC LDY a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + ALU_LDA + YR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- AD LDA a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + ALU_LDA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- AE LDX a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + ALU_LDA + XR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- AF BBS2 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBS2 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- B0 BCS r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_BCS + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- B1 LDA (d),Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + ALU_LDA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- B2 LDA (d)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + ALU_LDA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- B3 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- B4 LDY d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + ALU_LDA + YR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- B5 LDA d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + ALU_LDA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- B6 LDX d,Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_LO + ALU_LDA + XR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- B7 SMB3 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_SMB3 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- B8 CLV
      ADDR_PC + PC_INC,
      SR_CLV + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- B9 LDA a,Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + ALU_LDA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- BA TSX
      ADDR_PC + PC_INC,
      REG_SP + ALU_LDA_A + XR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- BB NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- BC LDY a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + ALU_LDA + YR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- BD LDA a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + ALU_LDA + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- BE LDX a,Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + ALU_LDA + XR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- BF BBS3 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBS3 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- C0 CPY #
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + REG_YR + ALU_CMP + YR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- C1 CMP (d,X)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ZP_ADDX,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + ALU_CMP + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- C2 NOP
      ADDR_PC + PC_INC,
      PC_INC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- C3 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- C4 CPY d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + REG_YR + ALU_CMP + YR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- C5 CMP d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + ALU_CMP + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- C6 DEC d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_DEC_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- C7 SMB4 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_SMB4 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- C8 INY
      ADDR_PC + PC_INC,
      REG_YR + ALU_INC_A + YR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- C9 CMP #
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ALU_CMP + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- CA DEX
      ADDR_PC + PC_INC,
      REG_XR + ALU_DEC_A + XR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- CB NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- CC CPY a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + REG_YR + ALU_CMP + YR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- CD CMP a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + ALU_CMP + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- CE DEC a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + MR_DATA,
      ADDR_HL + REG_MR + ALU_DEC_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- CF BBS4 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBS4 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- D0 BNE r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_BNE + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- D1 CMP (d),Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + ALU_CMP + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- D2 CMP (d)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + ALU_CMP + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- D3 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- D4 NOP
      ADDR_PC + PC_INC,
      PC_INC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- D5 CMP d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + ALU_CMP + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- D6 DEC d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_DEC_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- D7 SMB5 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_SMB5 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- D8 CLD
      ADDR_PC + PC_INC,
      SR_CLD + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- D9 CMP a,Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + ALU_CMP + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- DA PHX
      ADDR_PC + PC_INC,
      ADDR_SP + REG_XR + ALU_STA + DATA_ALU + SP_DEC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- DB NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- DC NOP
      ADDR_PC + PC_INC,
      PC_INC,
      PC_INC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- DD CMP a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + ALU_CMP + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- DE DEC a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + MR_DATA,
      ADDR_HL + REG_MR + ALU_DEC_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- DF BBS5 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBS5 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- E0 CPX #
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + REG_XR + ALU_CMP + XR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- E1 SBC (d,X)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ZP_ADDX,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + ALU_SBC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- E2 NOP
      ADDR_PC + PC_INC,
      PC_INC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- E3 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- E4 CPX d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + REG_XR + ALU_CMP + XR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- E5 SBC d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + ALU_SBC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- E6 INC d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_INC_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- E7 SMB6 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_SMB6 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- E8 INX
      ADDR_PC + PC_INC,
      REG_XR + ALU_INC_A + XR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- E9 SBC #
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ALU_SBC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- EA NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- EB NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- EC CPX a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + REG_XR + ALU_CMP + XR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- ED SBC a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + ALU_SBC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- EE INC a
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      ADDR_HL + MR_DATA,
      ADDR_HL + REG_MR + ALU_INC_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- EF BBS6 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBS6 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- F0 BEQ r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_BEQ + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- F1 SBC (d),Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + ALU_SBC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- F2 SBC (d)
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + ZP_DATA,
      ADDR_ZP + LO_DATA + ZP_INC,
      ADDR_ZP + HI_DATA,
      ADDR_HL + ALU_SBC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- F3 NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- F4 NOP
      ADDR_PC + PC_INC,
      PC_INC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- F5 SBC d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + ALU_SBC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- F6 INC d,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_INC_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- F7 SMB7 d
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_LO + REG_MR + ALU_SMB7 + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- F8 SED
      ADDR_PC + PC_INC,
      SR_SED + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- F9 SBC a,Y
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDY + LO_ADDY,
      ADDR_HL + ALU_SBC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- FA PLX
      ADDR_PC + PC_INC,
      SP_INC,
      ADDR_SP + ALU_LDA + XR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- FB NOP
      ADDR_PC + PC_INC,
      LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- FC NOP
      ADDR_PC + PC_INC,
      PC_INC,
      PC_INC + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID,
      INVALID,

-- FD SBC a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + ALU_SBC + AR_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,
      INVALID,

-- FE INC a,X
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_PC + PC_INC + HI_DATA,
      HI_ADDX + LO_ADDX,
      ADDR_HL + MR_DATA,
      ADDR_HL + REG_MR + ALU_INC_A + DATA_ALU + SR_ALU + LAST,
      INVALID,
      INVALID,

-- FF BBS7 d,r
      ADDR_PC + PC_INC,
      ADDR_PC + PC_INC + LO_DATA,
      ADDR_LO + MR_DATA,
      ADDR_PC + PC_BBS7 + LAST,
      INVALID,
      INVALID,
      INVALID,
      INVALID
   ); -- signal rom : t_rom := (

begin

   p_rom : process (clk_i)
   begin
      if rising_edge(clk_i) then
         data_o <= rom(to_integer(addr_i));
      end if;
   end process p_rom;

end architecture structural;

