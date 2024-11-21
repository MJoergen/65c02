library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity control is
   port (
      clk_i      : in  std_logic;
      ce_i       : in  std_logic;
      wait_i     : in  std_logic;
      irq_i      : in  std_logic;
      nmi_i      : in  std_logic;
      nmi_ack_o  : out std_logic;
      rst_i      : in  std_logic;
      sri_i      : in  std_logic;

      addr_i     : in  std_logic_vector(15 downto 0);
      data_i     : in  std_logic_vector(7 downto 0);

      ar_sel_o   : out std_logic;
      hi_sel_o   : out std_logic_vector(2 downto 0);
      lo_sel_o   : out std_logic_vector(2 downto 0);
      pc_sel_o   : out std_logic_vector(6 downto 0);
      addr_sel_o : out std_logic_vector(3 downto 0);
      data_sel_o : out std_logic_vector(2 downto 0);
      alu_sel_o  : out std_logic_vector(5 downto 0);
      sr_sel_o   : out std_logic_vector(3 downto 0);
      sp_sel_o   : out std_logic_vector(1 downto 0);
      xr_sel_o   : out std_logic;
      yr_sel_o   : out std_logic;
      mr_sel_o   : out std_logic_vector(1 downto 0);
      reg_sel_o  : out std_logic_vector(2 downto 0);
      zp_sel_o   : out std_logic_vector(1 downto 0);

      invalid_o  : out std_logic_vector(7 downto 0);
      debug_o    : out std_logic_vector(63 downto 0)
   );
end entity control;

architecture structural of control is

   subtype t_ctl is std_logic_vector(43 downto 0);

   constant NOP     : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000000_000_000_0";
   constant PC_INC  : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0000_0000001_000_000_0";
   constant ADDR_PC : t_ctl := B"0_00_00_000_0_0_00_0000_000000_0_000_0001_0000000_000_000_0";

   signal ir  : std_logic_vector(7 downto 0);   -- Instruction register
   signal cnt : std_logic_vector(2 downto 0);   -- Cycle counter

   signal microcode_addr_s : std_logic_vector(10 downto 0);
   signal microcode_data_s : t_ctl;

   -- Decode control signals
   signal ctl      : t_ctl;
   alias ar_sel    : std_logic                    is ctl(0);
   alias hi_sel    : std_logic_vector(2 downto 0) is ctl(3 downto 1);
   alias lo_sel    : std_logic_vector(2 downto 0) is ctl(6 downto 4);
   alias pc_sel    : std_logic_vector(6 downto 0) is ctl(13 downto 7);
   alias addr_sel  : std_logic_vector(3 downto 0) is ctl(17 downto 14);
   alias data_sel  : std_logic_vector(2 downto 0) is ctl(20 downto 18);
   alias last_s    : std_logic                    is ctl(21);
   alias alu_sel   : std_logic_vector(5 downto 0) is ctl(27 downto 22);
   alias sr_sel    : std_logic_vector(3 downto 0) is ctl(31 downto 28);
   alias sp_sel    : std_logic_vector(1 downto 0) is ctl(33 downto 32);
   alias xr_sel    : std_logic                    is ctl(34);
   alias yr_sel    : std_logic                    is ctl(35);
   alias reg_sel   : std_logic_vector(2 downto 0) is ctl(38 downto 36);
   alias zp_sel    : std_logic_vector(1 downto 0) is ctl(40 downto 39);
   alias mr_sel    : std_logic_vector(1 downto 0) is ctl(42 downto 41);
   alias invalid_s : std_logic                    is ctl(43);


   -- Interrupt Source
   -- 00 : BRK
   -- 01 : NMI
   -- 10 : Reset
   -- 11 :_IRQ
   -- This controls which interrupt vector to fetch the Program Counter
   -- from, and also which value of the Break bit in the Status Register
   -- to write to the stack.
   signal cic : std_logic_vector(1 downto 0) := (others => '0');

   -- Delayed NMI signal
   -- Used to perform edge detection on the NMI input.
   signal nmi_d : std_logic;

   signal invalid_inst : std_logic_vector(7 downto 0) := (others => '0');

begin

   ---------------------------
   -- Read from microcode ROM
   ---------------------------

   microcode_addr_s <= X"00"  & (cnt+1)   when (cnt = 0 and cic /= "00") or rst_i = '1' else
                       data_i & "001"     when cnt = 0 else
                       ir     & (cnt+1);

   i_microcode : entity work.microcode
   port map (
      clk_i  => clk_i,
      ce_i   => ce_i,
      addr_i => microcode_addr_s,
      data_o => microcode_data_s
   );

   ctl <= NOP              when invalid_inst /= 0 else
          ADDR_PC + PC_INC when cnt = 0           else
          microcode_data_s;


   p_cnt : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if ce_i = '1' then
            if wait_i = '0' then
               cnt <= cnt + 1;
               if last_s = '1' then
                  cnt <= (others => '0');
               end if;
            end if;

            -- Upon reset, start by loading Program Counter from Reset vector.
            if rst_i = '1' then
               cnt <= "100";
            end if;
         end if;
      end if;
   end process p_cnt;

   p_ir : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if ce_i = '1' then
            if wait_i = '0' then
               if cnt = 0 then
                  ir <= data_i;     -- Only load instruction register at beginning of instruction.

                  -- Inject a BRK in case of hardware interrupt.
                  if cic /= "00" then
                     ir <= X"00";
                  end if;
               end if;
            end if;

            -- Upon reset, force the first instruction to be BRK
            if rst_i = '1' then
               ir <= X"00";
            end if;
         end if;
      end if;
   end process p_ir;

   p_invalid : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if ce_i = '1' then
            if wait_i = '0' then
               if invalid_s = '1' then
                  if invalid_inst = X"00" then
                     invalid_inst <= ir;
                  end if;
               end if;
            end if;

            -- Upon reset, clear the invalid instruction register.
            if rst_i = '1' then
               invalid_inst <= X"00";
            end if;
         end if;
      end if;
   end process p_invalid;

   p_cic : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if ce_i = '1' then
            nmi_ack_o <= '0';
            -- Sample and prioritize hardware interrupts at end of instruction.
            if wait_i = '0' then
               if last_s = '1' then
                  if rst_i = '1' then  -- Reset is non-maskable and level sensitive.
                     cic <= "10";
                  elsif nmi_d = '0' and nmi_i = '1' then -- NMI is non-maskable, but edge sensitive.
                     nmi_ack_o <= '1';
                     report "NMI";
                     cic <= "01";
                  elsif irq_i = '1' and sri_i = '0' then -- IRQ is level sensitive, but maskable.
                     cic <= "11";
                  else
                     cic <= "00";   -- BRK
                  end if;
               end if;
            end if;

            -- Upon reset, force a hardware interrupt from the Reset vector.
            if rst_i = '1' then
               cic <= "10";
            end if;
         end if;
      end if;
   end process p_cic;

   p_nmi_d : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if ce_i = '1' then
            if wait_i = '0' then
               if last_s = '1' then
                  nmi_d <= nmi_i;
               end if;
            end if;
         end if;
      end if;
   end process p_nmi_d;


   -- Drive output signals
   ar_sel_o   <= ar_sel;
   hi_sel_o   <= hi_sel;
   lo_sel_o   <= lo_sel;
   pc_sel_o   <= "0000000"               when pc_sel(3 downto 0) = "0001" and (cic = "11" or cic = "01") else pc_sel;
   addr_sel_o <= '1' & cic & addr_sel(0) when addr_sel(3) = '1'                                          else addr_sel;
   data_sel_o <= "110"                   when data_sel = "010" and (cic = "11" or cic = "01")            else data_sel;
   alu_sel_o  <= alu_sel;
   sr_sel_o   <= sr_sel;
   sp_sel_o   <= sp_sel;
   xr_sel_o   <= xr_sel;
   yr_sel_o   <= yr_sel;
   mr_sel_o   <= mr_sel;
   reg_sel_o  <= reg_sel;
   zp_sel_o   <= zp_sel;


   ----------------
   -- Debug Output
   ----------------

   invalid_o  <= invalid_inst;
   debug_o( 2 downto  0) <= cnt;    -- One byte
   debug_o( 7 downto  3) <= (others => '0');
   debug_o(15 downto  8) <= data_i when cnt = 0 else ir;     -- One byte
   debug_o(59 downto 16) <= ctl;    -- Two bytes
   debug_o(63 downto 60) <= (others => '0');

end architecture structural;

