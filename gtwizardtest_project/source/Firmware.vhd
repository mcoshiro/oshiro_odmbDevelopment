library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

use work.Firmware_pkg.all;

entity Firmware is
  PORT (
    OUTPUT : out std_logic_vector(63 downto 0);
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
);
end Firmware;

architecture Behavioral of Firmware is

--hard-coded pointer to master channel's packed index (see exdes for general calculation)
--selects index of rxoutclk_out/txoutclk_out
constant master_ch_packed_idx : integer := 1;

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
    gtwiz_userclk_tx_active_in : IN std_logic := '0';
    gtwiz_userclk_rx_active_in : IN std_logic := '0';
    gtwiz_reset_clk_freerun_in : IN std_logic := '0';
    gtwiz_reset_all_in : IN std_logic := '0';
    gtwiz_reset_tx_pll_and_datapath_in : IN std_logic := '0';
    gtwiz_reset_tx_datapath_in : IN std_logic := '0';
    gtwiz_reset_rx_pll_and_datapath_in : IN std_logic := '0';
    gtwiz_reset_rx_datapath_in : IN std_logic := '0';
    gtwiz_reset_rx_cdr_stable_out : OUT std_logic := '0';
    gtwiz_reset_tx_done_out : OUT std_logic := '0';
    gtwiz_reset_rx_done_out : OUT std_logic := '0';
    gtwiz_userdata_tx_in : IN std_logic_vector(63 downto 0);
    gtwiz_userdata_rx_out : OUT std_logic_vector(63 downto 0);
    gtrefclk00_in : IN std_logic;
    qpll0outclk_out : OUT std_logic;
    qpll0outrefclk_out : OUT std_logic;
    gthrxn_in : IN std_logic_vector(1 downto 0);
    gthrxp_in : IN std_logic_vector(1 downto 0);
    rx8b10ben_in : IN std_logic_vector(1 downto 0);
    rxusrclk_in : IN std_logic_vector(1 downto 0);
    rxusrclk2_in : IN std_logic_vector(1 downto 0);
    tx8b10ben_in : IN std_logic_vector(1 downto 0);
    txctrl0_in : IN std_logic_vector(31 downto 0);
    txctrl1_in : IN std_logic_vector(31 downto 0);
    txctrl2_in : IN std_logic_vector(15 downto 0);
    txusrclk_in : IN std_logic_vector(1 downto 0);
    txusrclk2_in : IN std_logic_vector(1 downto 0);
    gthtxn_out : OUT std_logic_vector(1 downto 0);
    gthtxp_out : OUT std_logic_vector(1 downto 0);
    gtpowergood_out : OUT std_logic_vector(1 downto 0);
    rxctrl0_out : OUT std_logic_vector(31 downto 0);
    rxctrl1_out : OUT std_logic_vector(31 downto 0);
    rxctrl2_out : OUT std_logic_vector(15 downto 0);
    rxctrl3_out : OUT std_logic_vector(15 downto 0);
    rxoutclk_out : OUT std_logic_vector(1 downto 0);
    rxpmaresetdone_out : OUT std_logic_vector(1 downto 0);
    txoutclk_out : OUT std_logic_vector(1 downto 0);
    txpmaresetdone_out : OUT std_logic_vector(1 downto 0);
    rxcommadeten_in : in std_logic_vector ( 1 downto 0 );
    rxmcommaalignen_in : in std_logic_vector ( 1 downto 0 );
    rxpcommaalignen_in : in std_logic_vector ( 1 downto 0 );
    rxbyteisaligned_out : out std_logic_vector ( 1 downto 0 );
    rxbyterealign_out : out std_logic_vector ( 1 downto 0 );
    rxcommadet_out : out std_logic_vector ( 1 downto 0 )
  );
end component;

--gth wizard signals
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
signal hb_gtwiz_reset_clk_freerun_buf_int : std_logic;
signal gtwiz_reset_tx_done_int : std_logic;
signal gtwiz_reset_rx_done_int : std_logic;
signal gtwiz_reset_all_int : std_logic;
signal gtwiz_reset_rx_datapath_int : std_logic;
signal txoutclk_int : std_logic_vector(1 downto 0);
signal rxoutclk_int : std_logic_vector(1 downto 0);
signal gtrefclk00_int : std_logic;
signal gtwiz_userdata_tx_int : std_logic_vector(63 downto 0);
signal gtwiz_userdata_rx_int : std_logic_vector(63 downto 0);
signal qpll0outclk_int : std_logic;
signal qpll0outrefclk_int : std_logic;
signal rxbyteisaligned_int : std_logic_vector(1 downto 0);
signal rxbyterealign_int : std_logic_vector(1 downto 0);
signal rxcommadet_int : std_logic_vector(1 downto 0);
signal txctrl2_int : std_logic_vector(15 downto 0);
--signals for controlling resets and clocks to gth
signal gtwiz_userclk_rx_reset_int : std_logic;
signal gtwiz_userclk_tx_reset_int : std_logic;
signal gtwiz_userclk_rx_active_int : std_logic;
signal gtwiz_userclk_rx_active_meta : std_logic;
signal gtwiz_userclk_tx_active_int : std_logic;
signal gtwiz_userclk_tx_active_meta : std_logic;
--vio clock crossing signals
signal vio_reset_tx_done_sync : std_logic := '0';
signal vio_reset_tx_done_meta : std_logic := '0';
signal vio_reset_rx_done_sync : std_logic := '0';
signal vio_reset_rx_done_meta : std_logic := '0';
signal vio_userclk_rx_reset_sync : std_logic := '1';
signal vio_userclk_rx_reset_meta : std_logic := '1';
signal vio_userclk_tx_reset_sync : std_logic := '1';
signal vio_userclk_tx_reset_meta : std_logic := '1';
--signals related to tx data generation
signal reset_alignment : std_logic := '0';
signal align_reset_done : std_logic := '1';
signal align_reset_counter : integer range 0 to 512 := 0;
signal slv_counter : std_logic_vector(15 downto 0) := x"0000";
  
begin
  
   --return rx data from wrapper and associated clock as output
   OUTPUT <= gtwiz_userdata_rx_int;
   rxclk_out <= gtwiz_rx_usrclk_out;
  
   --(de)vectorize hardware connections for channels 0 and 1
   gthrxn_int <= ch1_gthrxn_in & ch0_gthrxn_in;
   gthrxp_int <= ch1_gthrxp_in & ch0_gthrxp_in;
   ch0_gthtxn_out <= gthtxn_int(0);
   ch1_gthtxn_out <= gthtxn_int(1);
   ch0_gthtxp_out <= gthtxp_int(0);
   ch1_gthtxp_out <= gthtxp_int(1);
   
   --vectorize clocks for the two channels
   txusrclk_int <= gtwiz_tx_usrclk_out & gtwiz_tx_usrclk_out;
   txusrclk2_int <= gtwiz_tx_usrclk2_out & gtwiz_tx_usrclk2_out;
   rxusrclk_int <= gtwiz_rx_usrclk_out & gtwiz_rx_usrclk_out;
   rxusrclk2_int <= gtwiz_rx_usrclk2_out & gtwiz_rx_usrclk2_out;
   
   --disable userclk until resetdone otherwise, bad things will happen
   gtwiz_userclk_rx_reset_int <= not (rxpmaresetdone_int(0) and rxpmaresetdone_int(1));
   gtwiz_userclk_tx_reset_int <= not (txpmaresetdone_int(0) and txpmaresetdone_int(1));
   
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
     O => gtrefclk00_int
   );
   bufg_gt_rx_usrclk_inst : BUFG_GT
   port map (
     O => gtwiz_rx_usrclk_out,
     CE => '1',
     CEMASK => '0',
     CLR => gtwiz_userclk_rx_reset_int,
     CLRMASK => '0',
     DIV => "000",
     I => rxoutclk_int(master_ch_packed_idx)
   );
   bufg_gt_tx_usrclk_inst : BUFG_GT
   port map (
     O => gtwiz_tx_usrclk_out,
     CE => '1',
     CEMASK => '0',
     CLR => gtwiz_userclk_tx_reset_int,
     CLRMASK => '0',
     DIV => "000",
     I => txoutclk_int(master_ch_packed_idx)
   );
   gtwiz_tx_usrclk2_out <= gtwiz_tx_usrclk_out;
   gtwiz_rx_usrclk2_out <= gtwiz_rx_usrclk_out;
   
   bufg_clk_freerun_inst : BUFG
   port map (
     O => hb_gtwiz_reset_clk_freerun_buf_int,
     I => clk40
   );
  
  gth_vio_i : gtwizard_reset_vio
  PORT MAP (
        clk => hb_gtwiz_reset_clk_freerun_buf_int,
        probe_in0 => vio_reset_tx_done_sync,
        probe_in1 => vio_reset_rx_done_sync,
        probe_in2 => vio_userclk_rx_reset_sync,
        probe_in3 => vio_userclk_tx_reset_sync,
        probe_out0 => gtwiz_reset_all_int,
        probe_out1 => gtwiz_reset_rx_datapath_int,
        probe_out2 => reset_alignment
        );

  my_gtwiz_test : gtwizard_test
  PORT MAP (
    --gtwiz_userclk_tx_reset_int => not (txpmaresetdone_int(0) and txpmaresetdone_int(1));
    gtwiz_userclk_tx_active_in => gtwiz_userclk_tx_active_int,
    gtwiz_userclk_rx_active_in => gtwiz_userclk_rx_active_int,
    gtwiz_reset_clk_freerun_in => hb_gtwiz_reset_clk_freerun_buf_int,
    gtwiz_reset_all_in => gtwiz_reset_all_int,
    gtwiz_reset_tx_pll_and_datapath_in => '0',
    gtwiz_reset_tx_datapath_in => '0',
    gtwiz_reset_rx_pll_and_datapath_in => '0',
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
  --generate gtwiz_active signals when clock running and not reset asserted
  process (gtwiz_rx_usrclk_out, gtwiz_userclk_rx_reset_int)
  begin
    if rising_edge(gtwiz_rx_usrclk_out) or rising_edge(gtwiz_userclk_rx_reset_int) then
      if gtwiz_userclk_rx_reset_int='1' then
        gtwiz_userclk_rx_active_int <= '0';
        gtwiz_userclk_rx_active_meta <= '0';
      else
        gtwiz_userclk_rx_active_int <= gtwiz_userclk_rx_active_meta;
        gtwiz_userclk_rx_active_meta <= '1';
      end if;
    end if;
  end process;
  process (gtwiz_tx_usrclk_out, gtwiz_userclk_tx_reset_int)
  begin
    if rising_edge(gtwiz_tx_usrclk_out) or rising_edge(gtwiz_userclk_tx_reset_int) then
      if gtwiz_userclk_tx_reset_int='1' then
        gtwiz_userclk_tx_active_int <= '0';
        gtwiz_userclk_tx_active_meta <= '0';
      else
        gtwiz_userclk_tx_active_int <= gtwiz_userclk_tx_active_meta;
        gtwiz_userclk_tx_active_meta <= '1';
      end if;
    end if;
  end process;
  
  --generate tx data/alignment comma characters: after reset, send comma characters until counter saturates, then start sending counter
  process (gtwiz_tx_usrclk_out)
  begin
    if rising_edge(gtwiz_tx_usrclk_out) then
      if (reset_alignment='1') then
          slv_counter <= x"0000";
          align_reset_counter <= 0;
          align_reset_done <= '0';
          txctrl2_int <= x"0f03";
      else 
        if (align_reset_done='1') then
          slv_counter <= slv_counter + 1;
          gtwiz_userdata_tx_int <= x"503c503c" & slv_counter & x"503c";
        else
          align_reset_counter <= align_reset_counter + 1;
          if (align_reset_counter=510) then
            txctrl2_int <= x"0000";
            align_reset_done <= '1';
          end if;
          gtwiz_userdata_tx_int <= x"0000003c0000003c";
        end if;
      end if;
    end if;
  end process;
  
  --sync vio signals into freerun clock domain
  process (hb_gtwiz_reset_clk_freerun_buf_int)
  begin
    if rising_edge(hb_gtwiz_reset_clk_freerun_buf_int) then
      vio_reset_tx_done_sync <= vio_reset_tx_done_meta;
      vio_reset_tx_done_meta <= gtwiz_reset_tx_done_int;
      vio_reset_rx_done_sync <= vio_reset_rx_done_meta;
      vio_reset_rx_done_meta <= gtwiz_reset_rx_done_int;
      vio_userclk_rx_reset_sync <= vio_userclk_rx_reset_meta;
      vio_userclk_rx_reset_meta <= gtwiz_userclk_rx_reset_int;
      vio_userclk_tx_reset_sync <= vio_userclk_tx_reset_meta;
      vio_userclk_tx_reset_meta <= gtwiz_userclk_tx_reset_int;
    end if;
  end process;

  end Behavioral;

