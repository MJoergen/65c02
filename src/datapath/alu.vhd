library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

-- This is the Arithmetic Logic Unit.
--
-- Inputs are:
-- a_i     : From the 'A' register
-- b_i     : Operand from memory
-- sr_i    : Current value of Status Register
-- func_i  : Current ALU function (determined from instruction).
--
-- Outputs are:
-- a_o     : New value of 'A' register
-- sr_o    : New value of Status Register

-- The Status Register contains: SV-BDIZC

entity alu is
   port (
      a_i    : in  std_logic_vector(7 downto 0);
      b_i    : in  std_logic_vector(7 downto 0);
      sr_i   : in  std_logic_vector(7 downto 0);
      func_i : in  std_logic_vector(5 downto 0);
      a_o    : out std_logic_vector(7 downto 0);
      sr_o   : out std_logic_vector(7 downto 0)
   );
end alu;

architecture structural of alu is

   signal c   : std_logic;                    -- Copy of the input carry signal
   signal a   : std_logic_vector(8 downto 0); -- New value of carry and accumulator
   signal sr  : std_logic_vector(7 downto 0); -- New value of the Status Register
   signal tmp : std_logic_vector(8 downto 0); -- Temporary value used by CMP

   -- The Status Register contains: SV-BDIZC
   constant SR_S : integer := 7;
   constant SR_V : integer := 6;
   constant SR_D : integer := 3;
   constant SR_Z : integer := 1;
   constant SR_C : integer := 0;

   constant ALU_ORA   : std_logic_vector(5 downto 0) := B"000000";
   constant ALU_AND   : std_logic_vector(5 downto 0) := B"000001";
   constant ALU_EOR   : std_logic_vector(5 downto 0) := B"000010";
   constant ALU_ADC   : std_logic_vector(5 downto 0) := B"000011";
   constant ALU_STA   : std_logic_vector(5 downto 0) := B"000100";
   constant ALU_LDA   : std_logic_vector(5 downto 0) := B"000101";
   constant ALU_CMP   : std_logic_vector(5 downto 0) := B"000110";
   constant ALU_SBC   : std_logic_vector(5 downto 0) := B"000111";

   constant ALU_ASL_A : std_logic_vector(5 downto 0) := B"001000";
   constant ALU_ROL_A : std_logic_vector(5 downto 0) := B"001001";
   constant ALU_LSR_A : std_logic_vector(5 downto 0) := B"001010";
   constant ALU_ROR_A : std_logic_vector(5 downto 0) := B"001011";
   constant ALU_BIT_A : std_logic_vector(5 downto 0) := B"001100";
   constant ALU_DEC_A : std_logic_vector(5 downto 0) := B"001110";
   constant ALU_INC_A : std_logic_vector(5 downto 0) := B"001111";
   constant ALU_LDA_A : std_logic_vector(5 downto 0) := B"001101";

   constant ALU_BIT_B : std_logic_vector(5 downto 0) := B"010100";
   constant ALU_TRB   : std_logic_vector(5 downto 0) := B"010101";
   constant ALU_TSB   : std_logic_vector(5 downto 0) := B"010110";

   constant ALU_RMB0  : std_logic_vector(5 downto 0) := B"110000";
   constant ALU_RMB1  : std_logic_vector(5 downto 0) := B"110001";
   constant ALU_RMB2  : std_logic_vector(5 downto 0) := B"110010";
   constant ALU_RMB3  : std_logic_vector(5 downto 0) := B"110011";
   constant ALU_RMB4  : std_logic_vector(5 downto 0) := B"110100";
   constant ALU_RMB5  : std_logic_vector(5 downto 0) := B"110101";
   constant ALU_RMB6  : std_logic_vector(5 downto 0) := B"110110";
   constant ALU_RMB7  : std_logic_vector(5 downto 0) := B"110111";
   constant ALU_SMB0  : std_logic_vector(5 downto 0) := B"111000";
   constant ALU_SMB1  : std_logic_vector(5 downto 0) := B"111001";
   constant ALU_SMB2  : std_logic_vector(5 downto 0) := B"111010";
   constant ALU_SMB3  : std_logic_vector(5 downto 0) := B"111011";
   constant ALU_SMB4  : std_logic_vector(5 downto 0) := B"111100";
   constant ALU_SMB5  : std_logic_vector(5 downto 0) := B"111101";
   constant ALU_SMB6  : std_logic_vector(5 downto 0) := B"111110";
   constant ALU_SMB7  : std_logic_vector(5 downto 0) := B"111111";

   -- An 8-input OR gate
   function or_all(arg : std_logic_vector(7 downto 0)) return std_logic is
      variable tmp_v : std_logic;
   begin
      tmp_v := arg(0);
      for i in 1 to 7 loop
         tmp_v := tmp_v or arg(i);
      end loop;
      return tmp_v;
   end function or_all;

begin

   c <= sr_i(0);  -- Old value of carry bit

   -- Calculate the result
   p_a : process (c, a_i, b_i, sr_i, func_i)
      variable lo_v : std_logic_vector(4 downto 0);
      variable hi_v : std_logic_vector(4 downto 0);
   begin
      tmp <= (others => '0');
      a <= c & a_i;  -- Default value
      case func_i is
         when ALU_ORA =>
            a(7 downto 0) <= a_i or b_i;

         when ALU_AND =>
            a(7 downto 0) <= a_i and b_i;

         when ALU_EOR =>
            a(7 downto 0) <= a_i xor b_i;

         when ALU_ADC =>
            a <= ('0' & a_i) + ('0' & b_i) + (X"00" & c);
            if sr_i(SR_D) = '1' then   -- Decimal mode
               lo_v := ('0' & a_i(3 downto 0)) + ('0' & b_i(3 downto 0)) + (X"0" & c);
               hi_v := ('0' & a_i(7 downto 4)) + ('0' & b_i(7 downto 4));
               if lo_v >= 10 then
                  lo_v := lo_v - 10;
                  hi_v := hi_v + 1;
               end if;
               if hi_v >= 10 then
                  hi_v := hi_v - 10 + 16;
               end if;
               a <= hi_v & lo_v(3 downto 0);
            end if;

         when ALU_STA =>
            null;

         when ALU_LDA =>
            a(7 downto 0) <= b_i;

         when ALU_CMP =>
            tmp <= ('0' & a_i) + ('0' & not b_i) + (X"00" & '1');

         when ALU_SBC =>
            a <= ('0' & a_i) + ('0' & not b_i) + (X"00" & c);
            if sr_i(SR_D) = '1' then   -- Decimal mode
               lo_v := ('0' & a_i(3 downto 0)) + "01001" - ('0' & b_i(3 downto 0)) + (X"0" & c);
               hi_v := ('0' & a_i(7 downto 4)) + "01001" - ('0' & b_i(7 downto 4));
               if lo_v >= 10 then
                  lo_v := lo_v - 10;
                  hi_v := hi_v + 1;
               end if;
               if hi_v >= 10 then
                  hi_v := hi_v - 10 + 16;
               end if;
               a <= hi_v & lo_v(3 downto 0);
            end if;

         when ALU_ASL_A =>
            a <= a_i(7 downto 0) & '0';

         when ALU_ROL_A =>
            a <= a_i(7 downto 0) & c;

         when ALU_LSR_A =>
            a <= a_i(0) & '0' & a_i(7 downto 1);

         when ALU_ROR_A =>
            a <= a_i(0) & c & a_i(7 downto 1);

         when ALU_BIT_A =>
            tmp(7 downto 0) <= a_i and b_i;

         when ALU_DEC_A =>
            a(7 downto 0) <= a_i - 1;

         when ALU_INC_A =>
            a(7 downto 0) <= a_i + 1;

         when ALU_LDA_A =>
            null;

         when ALU_BIT_B =>
            tmp(7 downto 0) <= a_i and b_i;

         when ALU_TRB =>
            tmp(7 downto 0) <= a_i and b_i;
            a(7 downto 0)   <= (not a_i) and b_i;

         when ALU_TSB =>
            tmp(7 downto 0) <= a_i and b_i;
            a(7 downto 0)   <= a_i or b_i;

         when ALU_RMB0 =>
            a <= c & b_i;  -- Default value
            a(0) <= '0';

         when ALU_RMB1 =>
            a <= c & b_i;  -- Default value
            a(1) <= '0';

         when ALU_RMB2 =>
            a <= c & b_i;  -- Default value
            a(2) <= '0';

         when ALU_RMB3 =>
            a <= c & b_i;  -- Default value
            a(3) <= '0';

         when ALU_RMB4 =>
            a <= c & b_i;  -- Default value
            a(4) <= '0';

         when ALU_RMB5 =>
            a <= c & b_i;  -- Default value
            a(5) <= '0';

         when ALU_RMB6 =>
            a <= c & b_i;  -- Default value
            a(6) <= '0';

         when ALU_RMB7 =>
            a <= c & b_i;  -- Default value
            a(7) <= '0';

         when ALU_SMB0 =>
            a <= c & b_i;  -- Default value
            a(0) <= '1';

         when ALU_SMB1 =>
            a <= c & b_i;  -- Default value
            a(1) <= '1';

         when ALU_SMB2 =>
            a <= c & b_i;  -- Default value
            a(2) <= '1';

         when ALU_SMB3 =>
            a <= c & b_i;  -- Default value
            a(3) <= '1';

         when ALU_SMB4 =>
            a <= c & b_i;  -- Default value
            a(4) <= '1';

         when ALU_SMB5 =>
            a <= c & b_i;  -- Default value
            a(5) <= '1';

         when ALU_SMB6 =>
            a <= c & b_i;  -- Default value
            a(6) <= '1';

         when ALU_SMB7 =>
            a <= c & b_i;  -- Default value
            a(7) <= '1';

         when others =>
            null;

      end case;
   end process p_a;

   -- Calculate the new Status Register
   p_sr : process (a, tmp, a_i, b_i, sr_i, func_i)
   begin
      sr <= sr_i;  -- Keep the old value as default

      case func_i is
         when ALU_ORA =>
            sr(SR_S) <= a(7);
            sr(SR_Z) <= not or_all(a(7 downto 0));

         when ALU_AND =>
            sr(SR_S) <= a(7);
            sr(SR_Z) <= not or_all(a(7 downto 0));

         when ALU_EOR =>
            sr(SR_S) <= a(7);
            sr(SR_Z) <= not or_all(a(7 downto 0));

         when ALU_ADC =>
            sr(SR_S) <= a(7);
            sr(SR_Z) <= not or_all(a(7 downto 0));
            sr(SR_V) <= not(a_i(7) xor b_i(7)) and (a_i(7) xor a(7));
            sr(SR_C) <= a(8);

         when ALU_STA =>
            null;

         when ALU_LDA =>
            sr(SR_S) <= a(7);
            sr(SR_Z) <= not or_all(a(7 downto 0));

         when ALU_CMP =>
            sr(SR_S) <= tmp(7);
            sr(SR_Z) <= not or_all(tmp(7 downto 0));
            sr(SR_C) <= tmp(8);

         when ALU_SBC =>
            sr(SR_S) <= a(7);
            sr(SR_Z) <= not or_all(a(7 downto 0));
            sr(SR_V) <= (a_i(7) xor b_i(7)) and (a_i(7) xor a(7));
            sr(SR_C) <= a(8);

         when ALU_ASL_A => -- ASL   SZC
            sr(SR_S) <= a(7);
            sr(SR_Z) <= not or_all(a(7 downto 0));
            sr(SR_C) <= a(8);

         when ALU_ROL_A => -- ROL   SZC
            sr(SR_S) <= a(7);
            sr(SR_Z) <= not or_all(a(7 downto 0));
            sr(SR_C) <= a(8);

         when ALU_LSR_A => -- LSR   SZC
            sr(SR_S) <= a(7);
            sr(SR_Z) <= not or_all(a(7 downto 0));
            sr(SR_C) <= a(8);

         when ALU_ROR_A => -- ROR   SZC
            sr(SR_S) <= a(7);
            sr(SR_Z) <= not or_all(a(7 downto 0));
            sr(SR_C) <= a(8);

         when ALU_BIT_A => -- BIT   Z
            sr(SR_Z) <= not or_all(tmp(7 downto 0));

         when ALU_BIT_B => -- BIT   SZV
            sr(SR_S) <= b_i(7);
            sr(SR_Z) <= not or_all(tmp(7 downto 0));
            sr(SR_V) <= b_i(6);

         when ALU_TRB =>   -- TRB   Z
            sr(SR_Z) <= not or_all(tmp(7 downto 0));

         when ALU_TSB =>   -- TSB   Z
            sr(SR_Z) <= not or_all(tmp(7 downto 0));

         when ALU_DEC_A => -- DEC   SZ
            sr(SR_S) <= a(7);
            sr(SR_Z) <= not or_all(a(7 downto 0));

         when ALU_INC_A => -- INC   SZ
            sr(SR_S) <= a(7);
            sr(SR_Z) <= not or_all(a(7 downto 0));

         when ALU_LDA_A =>
            sr(SR_S) <= a(7);
            sr(SR_Z) <= not or_all(a(7 downto 0));

         when ALU_RMB0 => null;
         when ALU_RMB1 => null;
         when ALU_RMB2 => null;
         when ALU_RMB3 => null;
         when ALU_RMB4 => null;
         when ALU_RMB5 => null;
         when ALU_RMB6 => null;
         when ALU_RMB7 => null;

         when ALU_SMB0 => null;
         when ALU_SMB1 => null;
         when ALU_SMB2 => null;
         when ALU_SMB3 => null;
         when ALU_SMB4 => null;
         when ALU_SMB5 => null;
         when ALU_SMB6 => null;
         when ALU_SMB7 => null;

         when others =>
            null;

      end case;
   end process p_sr;

   -- Drive output signals
   a_o  <= a(7 downto 0);
   sr_o <= sr;

end structural;

