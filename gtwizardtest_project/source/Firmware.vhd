library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

use work.Firmware_pkg.all;

entity Firmware is
  PORT (
    INPUT1 : in std_logic_vector(11 downto 0);
    INPUT2 : in std_logic_vector(11 downto 0);
    OUTPUT : out std_logic_vector(19 downto 0);
    --new gth ports
    rxclk_out : out std_logic;
    mgtrefclk0_x0y3_p: in std_logic;
    mgtrefclk0_x0y3_n: in std_logic;
    ch0_gthrxn_in: in std_logic;
    ch0_gthrxp_in: in std_logic;
    ch0_gthtxn_out: out std_logic;
    ch0_gthtxp_out: out std_logic;
    ch1_gthrxn_in: in std_logic;
    ch1_gthrxp_in: in std_logic;
    ch1_gthtxn_out: out std_logic;
    ch1_gthtxp_out: out std_logic;
    clk40 : in std_logic
    --sel_si750_clk_i: in std_logic;
    --CLK_IN_P: in std_logic;
    --CLK_IN_N: in std_logic;
);
end Firmware;

architecture Behavioral of Firmware is

--gth vectorized signals
signal gthrxn_int : std_logic_vector(1 downto 0);
signal gthrxp_int : std_logic_vector(1 downto 0);
signal gthtxn_int : std_logic_vector(1 downto 0);
signal gthtxp_int : std_logic_vector(1 downto 0);
signal gtwiz_rx_usrclk_out : std_logic;
signal gtwiz_tx_usrclk_out : std_logic;
signal gtwiz_rx_usrclk2_out : std_logic;
signal gtwiz_tx_usrclk2_out : std_logic;
signal txusrclk_int : std_logic_vector(1 downto 0);
signal txusrclk2_int : std_logic_vector(1 downto 0);
signal rxusrclk_int : std_logic_vector(1 downto 0);
signal rxusrclk2_int : std_logic_vector(1 downto 0);
signal txpmaresetdone_int : std_logic_vector(1 downto 0);
signal rxpmaresetdone_int : std_logic_vector(1 downto 0);
signal gtwiz_userclk_rx_reset_int : std_logic;
signal gtwiz_userclk_tx_reset_int : std_logic;
signal gtwiz_userclk_rx_active_int : std_logic_vector(0 downto 0);
signal gtwiz_userclk_rx_active_meta : std_logic;
signal gtwiz_userclk_tx_active_int : std_logic_vector(0 downto 0);
signal gtwiz_userclk_tx_active_meta : std_logic;
signal hb_gtwiz_reset_clk_freerun_buf_int : std_logic_vector(0 downto 0);
signal gtwiz_reset_tx_done_int : std_logic_vector(0 downto 0);
signal gtwiz_reset_rx_done_int : std_logic_vector(0 downto 0);
--signal clk_out40 : std_logic;
signal gtwiz_reset_all_int : std_logic_vector(0 downto 0);
signal gtwiz_reset_rx_datapath_int : std_logic_vector(0 downto 0);
signal txoutclk_int : std_logic_vector(1 downto 0);
signal rxoutclk_int : std_logic_vector(1 downto 0);
signal counter1 : integer range 0 to 63 := 0;
signal align_reset_counter : integer range 0 to 512 := 0;
signal gtrefclk00_int : std_logic_vector(0 downto 0);
signal gtwiz_userdata_tx_int : std_logic_vector(63 downto 0);
signal gtwiz_userdata_rx_int : std_logic_vector(63 downto 0);
signal qpll0outclk_int : std_logic_vector(0 downto 0);
signal qpll0outrefclk_int : std_logic_vector(0 downto 0);
signal rx_cesync : std_logic;
signal rx_clrsync : std_logic;
signal tx_cesync : std_logic;
signal tx_clrsync : std_logic;
signal vio_reset_tx_done_sync : std_logic;
signal vio_reset_tx_done_meta : std_logic;
signal vio_reset_rx_done_sync : std_logic;
signal vio_reset_rx_done_meta : std_logic;
signal vio_userclk_rx_reset_sync : std_logic;
signal vio_userclk_rx_reset_meta : std_logic;
signal vio_userclk_tx_reset_sync : std_logic;
signal vio_userclk_tx_reset_meta : std_logic;
signal rxbyteisaligned_int : std_logic_vector(1 downto 0);
signal rxbyterealign_int : std_logic_vector(1 downto 0);
signal rxcommadet_int : std_logic_vector(1 downto 0);
signal txctrl2_int : std_logic_vector(15 downto 0);
signal reset_alignment : std_logic := '0';
signal align_reset_done : std_logic := '1';

--signal clk_out80 : std_logic;
--signal inclk_buf : std_logic;
--hard-coded pointer to master channel's packed index (see exdes for general calculation)
--selects index of rxoutclk_out/txoutclk_out
constant master_ch_packed_idx : integer := 1;

component gtwizard_ultrascale_1_example_gtwiz_userclk_tx is
 PORT (
    gtwiz_userclk_tx_srcclk_in      : IN std_logic := '0';
    gtwiz_userclk_tx_reset_in       : IN std_logic := '0';
    gtwiz_userclk_tx_usrclk_out     : OUT std_logic := '0';
    gtwiz_userclk_tx_usrclk2_out    : OUT std_logic := '0';
    gtwiz_userclk_tx_active_out     : OUT std_logic := '0');
 end component;

component gtwizard_reset_vio is
   PORT (
           clk                    : IN  std_logic := '0';
           probe_in0              : IN  std_logic := '0';
           probe_in1              : IN  std_logic := '0';
           probe_in2              : IN  std_logic := '0';
           probe_in3              : IN  std_logic := '0';
           probe_out0             : OUT std_logic := '0';
           probe_out1             : OUT std_logic := '0';
           probe_out2             : OUT std_logic := '0');
  end component;

component gtwizard_test is
  PORT (
    gtwiz_userclk_tx_active_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    gtwiz_userclk_rx_active_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    gtwiz_reset_clk_freerun_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    gtwiz_reset_all_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    gtwiz_reset_tx_pll_and_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    gtwiz_reset_tx_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    gtwiz_reset_rx_pll_and_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    gtwiz_reset_rx_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    gtwiz_reset_rx_cdr_stable_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    gtwiz_reset_tx_done_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    gtwiz_reset_rx_done_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    gtwiz_userdata_tx_in : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    gtwiz_userdata_rx_out : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    gtrefclk00_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    qpll0outclk_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    qpll0outrefclk_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gthrxn_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    gthrxp_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    rx8b10ben_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    rxusrclk_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    rxusrclk2_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    tx8b10ben_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    txctrl0_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    txctrl1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    txctrl2_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    txusrclk_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    txusrclk2_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    gthtxn_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    gthtxp_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    gtpowergood_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    rxctrl0_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    rxctrl1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    rxctrl2_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    rxctrl3_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    rxoutclk_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    rxpmaresetdone_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    txoutclk_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    txpmaresetdone_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    --currently no comma character checking
    rxcommadeten_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
    rxmcommaalignen_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
    rxpcommaalignen_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
    rxbyteisaligned_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
    rxbyterealign_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
    rxcommadet_out : out STD_LOGIC_VECTOR ( 1 downto 0 )
    --rxcommadeten_in
    --rxmcommaalignen_in
    --rxpcommaalignen_in
    --rxbyteisaligned_out
    --rxbytealign_out
    --rxcommadet_out
  );
end component;
  
begin
  
   --make vectors for channels 0 and 1
   OUTPUT <= gtwiz_userdata_rx_int(19 downto 0);
   gthrxn_int <= ch1_gthrxn_in & ch0_gthrxn_in;
   gthrxp_int <= ch1_gthrxp_in & ch0_gthrxp_in;
   ch0_gthtxn_out <= gthtxn_int(0);
   ch1_gthtxn_out <= gthtxn_int(1);
   ch0_gthtxp_out <= gthtxp_int(0);
   ch1_gthtxp_out <= gthtxp_int(1);
   rxclk_out <= gtwiz_rx_usrclk_out;
   --buffer clocks
   gtrefclk_buffer : IBUFDS_GTE3
   generic map (
     REFCLK_EN_TX_PATH => '0',
     REFCLK_HROW_CK_SEL => "00",
     REFCLK_ICNTL_RX => "00"
   )
   port map (
     I => mgtrefclk0_x0y3_p,
     IB => mgtrefclk0_x0y3_n,
     CEB => '0',
     O => gtrefclk00_int(0)
   );
--   bufg_gt_sync_rx : BUFG_GT_SYNC
--   port map (
--     CLK => gtwiz_rx_usrclk_out,
--     CE => '1',
--     CLR => gtwiz_userclk_rx_reset_int,
--     CESYNC => rx_cesync,
--     CLRSYNC => rx_clrsync
--   );
--   bufg_gt_rx_usrclk_inst : BUFG_GT
--   port map (
--     O => gtwiz_rx_usrclk_out,
--     CE => rx_cesync,
--     CEMASK => '0',
--     CLR => rx_clrsync,
--     CLRMASK => '0',
--     DIV => "000",
--     I => rxoutclk_int(master_ch_packed_idx)
--   );
--   bufg_gt_sync_tx : BUFG_GT_SYNC
--   port map (
--     CLK => gtwiz_tx_usrclk_out,
--     CE => '1',
--     CLR => gtwiz_userclk_tx_reset_int,
--     CESYNC => tx_cesync,
--     CLRSYNC => tx_clrsync
--   );
--   bufg_gt_tx_usrclk_inst : BUFG_GT
--   port map (
--     O => gtwiz_tx_usrclk_out,
--     CE => tx_cesync,
--     CEMASK => '0',
--     CLR => tx_clrsync,
--     CLRMASK => '0',
--     DIV => "000",
--     I => txoutclk_int(master_ch_packed_idx)
--   );
   gtwiz_userclk_rx_inst : gtwizard_ultrascale_1_example_gtwiz_userclk_tx
   port map (
     gtwiz_userclk_tx_srcclk_in => rxoutclk_int(master_ch_packed_idx),
     gtwiz_userclk_tx_reset_in => gtwiz_userclk_rx_reset_int,
     gtwiz_userclk_tx_usrclk_out => gtwiz_rx_usrclk_out,
     gtwiz_userclk_tx_usrclk2_out => gtwiz_rx_usrclk2_out,
     gtwiz_userclk_tx_active_out => gtwiz_userclk_rx_active_int(0)
   );
   gtwiz_userclk_tx_inst : gtwizard_ultrascale_1_example_gtwiz_userclk_tx
   port map (
     gtwiz_userclk_tx_srcclk_in => txoutclk_int(master_ch_packed_idx),
     gtwiz_userclk_tx_reset_in => gtwiz_userclk_tx_reset_int,
     gtwiz_userclk_tx_usrclk_out => gtwiz_tx_usrclk_out,
     gtwiz_userclk_tx_usrclk2_out => gtwiz_tx_usrclk2_out,
     gtwiz_userclk_tx_active_out => gtwiz_userclk_tx_active_int(0)
   );
   bufg_clk_freerun_inst : BUFG
   port map (
     O => hb_gtwiz_reset_clk_freerun_buf_int(0),
     I => clk40
   );
   --disable userclk until resetdone otherwise, bad things will happen
   gtwiz_userclk_rx_reset_int <= not (rxpmaresetdone_int(0) and rxpmaresetdone_int(1));
   gtwiz_userclk_tx_reset_int <= not (txpmaresetdone_int(0) and txpmaresetdone_int(1));
   --make vector doubles- each channel just uses the same clock
   txusrclk_int <= gtwiz_tx_usrclk_out & gtwiz_tx_usrclk_out;
   txusrclk2_int <= gtwiz_tx_usrclk2_out & gtwiz_tx_usrclk2_out;
   rxusrclk_int <= gtwiz_rx_usrclk_out & gtwiz_rx_usrclk_out;
   rxusrclk2_int <= gtwiz_rx_usrclk2_out & gtwiz_rx_usrclk2_out;
  
  gth_vio_i : gtwizard_reset_vio
  PORT MAP (
        clk => hb_gtwiz_reset_clk_freerun_buf_int(0),
        probe_in0 => vio_reset_tx_done_sync,
        probe_in1 => vio_reset_rx_done_sync,
        probe_in2 => vio_userclk_rx_reset_sync,
        probe_in3 => vio_userclk_tx_reset_sync,
        probe_out0 => gtwiz_reset_all_int(0),
        probe_out1 => gtwiz_reset_rx_datapath_int(0),
        probe_out2 => reset_alignment
        );
        

  my_gtwiz_test : gtwizard_test
  PORT MAP (
    --gtwiz_userclk_tx_reset_int => not (txpmaresetdone_int(0) and txpmaresetdone_int(1));
    gtwiz_userclk_tx_active_in => gtwiz_userclk_tx_active_int,
    gtwiz_userclk_rx_active_in => gtwiz_userclk_rx_active_int,
    gtwiz_reset_clk_freerun_in => hb_gtwiz_reset_clk_freerun_buf_int,
    gtwiz_reset_all_in => gtwiz_reset_all_int,
    gtwiz_reset_tx_pll_and_datapath_in => "0",
    gtwiz_reset_tx_datapath_in => "0",
    gtwiz_reset_rx_pll_and_datapath_in => "0",
    gtwiz_reset_rx_datapath_in => gtwiz_reset_rx_datapath_int,
    gtwiz_reset_rx_cdr_stable_out => open,
    gtwiz_reset_tx_done_out => gtwiz_reset_tx_done_int,
    gtwiz_reset_rx_done_out => gtwiz_reset_rx_done_int,
    gtwiz_userdata_tx_in => gtwiz_userdata_tx_int,
    gtwiz_userdata_rx_out => gtwiz_userdata_rx_int,
    gtrefclk00_in => gtrefclk00_int,
    qpll0outclk_out => qpll0outclk_int,
    qpll0outrefclk_out => qpll0outrefclk_int,
    gthrxn_in => gthrxn_int,
    gthrxp_in => gthrxp_int,
    rx8b10ben_in => "11",
    rxusrclk_in => rxusrclk_int,
    rxusrclk2_in => rxusrclk2_int,
    tx8b10ben_in => "11",
    txctrl0_in => x"00000000",
    txctrl1_in => x"00000000",
    txctrl2_in => txctrl2_int,
    txusrclk_in => txusrclk_int,
    txusrclk2_in => txusrclk2_int,
    gthtxn_out => gthtxn_int,
    gthtxp_out => gthtxp_int,
    gtpowergood_out => open,
    rxctrl0_out => open,
    rxctrl1_out => open,
    rxctrl2_out => open,
    rxctrl3_out => open,
    rxoutclk_out => rxoutclk_int,
    rxpmaresetdone_out => rxpmaresetdone_int,
    txoutclk_out => txoutclk_int,
    txpmaresetdone_out => txpmaresetdone_int,
    rxcommadeten_in => "11",
    rxmcommaalignen_in => "11",
    rxpcommaalignen_in => "11", 
    rxbyteisaligned_out => rxbyteisaligned_int,
    rxbyterealign_out => rxbyterealign_int,
    rxcommadet_out => rxcommadet_int
  );
  
  logic:  
  --generate gtwiz_active signals
--  process (gtwiz_rx_usrclk_out, gtwiz_userclk_rx_reset_int)
--  begin
--    if rising_edge(gtwiz_rx_usrclk_out) or rising_edge(gtwiz_userclk_rx_reset_int) then
--      if gtwiz_userclk_rx_reset_int='0' then
--        gtwiz_userclk_rx_active_int <= "0";
--        gtwiz_userclk_rx_active_meta <= '0';
--      else
--        gtwiz_userclk_rx_active_int(0) <= gtwiz_userclk_rx_active_meta;
--        gtwiz_userclk_rx_active_meta <= '1';
--      end if;
--    end if;
--  end process;
--  process (gtwiz_tx_usrclk_out, gtwiz_userclk_tx_reset_int)
--  begin
--    if rising_edge(gtwiz_tx_usrclk_out) or rising_edge(gtwiz_userclk_tx_reset_int) then
--      if gtwiz_userclk_tx_reset_int='0' then
--        gtwiz_userclk_tx_active_int <= "0";
--        gtwiz_userclk_tx_active_meta <= '0';
--      else
--        gtwiz_userclk_tx_active_int(0) <= gtwiz_userclk_tx_active_meta;
--        gtwiz_userclk_tx_active_meta <= '1';
--      end if;
--      counter_tx_sync <= counter_tx_meta;
--      counter_tx_meta <= counter1;
--    end if;
--  end process;
  process (gtwiz_tx_usrclk_out)
  begin
    --generate tx data: after reset, send comma characters until counter saturates, then start sending counter
    if (reset_alignment='1') then
      counter1 <= 0;
      align_reset_counter <= 0;
      align_reset_done <= '0';
      txctrl2_int <= x"0f0f";
    end if;
    if rising_edge(gtwiz_tx_usrclk_out) then
      if (align_reset_done='1') then
        counter1 <= counter1 + 1;
        gtwiz_userdata_tx_int <= x"530c530c503c" & std_logic_vector(to_unsigned(counter1,16));
      else
        align_reset_counter <= align_reset_counter + 1;
        if (align_reset_counter=510) then
          txctrl2_int <= x"0000";
          align_reset_done <= '1';
        end if;
        gtwiz_userdata_tx_int <= x"3c3c3c3c3c3c3c3c";
      end if;
    end if;
  end process;
  
  process (hb_gtwiz_reset_clk_freerun_buf_int(0))
  begin
    if rising_edge(hb_gtwiz_reset_clk_freerun_buf_int(0)) then
      vio_reset_tx_done_sync <= vio_reset_tx_done_meta;
      vio_reset_tx_done_meta <= gtwiz_reset_tx_done_int(0);
      vio_reset_rx_done_sync <= vio_reset_rx_done_meta;
      vio_reset_rx_done_meta <= gtwiz_reset_rx_done_int(0);
      vio_userclk_rx_reset_sync <= vio_userclk_rx_reset_meta;
      vio_userclk_rx_reset_meta <= gtwiz_userclk_rx_reset_int;
      vio_userclk_tx_reset_sync <= vio_userclk_tx_reset_meta;
      vio_userclk_tx_reset_meta <= gtwiz_userclk_tx_reset_int;
    end if;
  end process;
  --process (hb_gtwiz_reset_clk_freerun_buf_int(0))
  --begin
  --  if (hb_gtwiz_reset_clk_freerun_buf_int(0)'event and hb_gtwiz_reset_clk_freerun_buf_int(0)='1') then  
  --  end if;
  --end process;

  end Behavioral;

