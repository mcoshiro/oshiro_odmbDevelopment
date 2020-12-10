library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

--library work;
use work.ucsb_types.all;

--use work.Firmware_pkg.all;     -- for switch between sim and synthesis

entity ODMB7_UCSB_DEV is
  generic (
    NCFEB       : integer range 1 to 7 := 7  -- Number of DCFEBS, 7 for ME1/1, 5
  );
  PORT (
    --------------------
    -- CMSCLK
    --------------------
    CMS_CLK_FPGA_P : in std_logic;                        -- Bank 45
    CMS_CLK_FPGA_N : in std_logic;                        -- Bank 45

    --------------------
    -- Signals controlled by ODMB_VME
    --------------------
    VME_DATA        : inout std_logic_vector(15 downto 0); -- Bank 48
    VME_GAP_B       : in std_logic;                        -- Bank 48
    VME_GA_B        : in std_logic_vector(4 downto 0);     -- Bank 48
    VME_ADDR        : in std_logic_vector(23 downto 1);    -- Bank 46
    VME_AM          : in std_logic_vector(5 downto 0);     -- Bank 46
    VME_AS_B        : in std_logic;                        -- Bank 46
    VME_DS_B        : in std_logic_vector(1 downto 0);     -- Bank 46
    VME_LWORD_B     : in std_logic;                        -- Bank 48
    VME_WRITE_B     : in std_logic;                        -- Bank 48
    VME_IACK_B      : in std_logic;                        -- Bank 48
    VME_BERR_B      : in std_logic;                        -- Bank 48
    VME_SYSRST_B    : in std_logic;                        -- Bank 48, not used
    VME_SYSFAIL_B   : in std_logic;                        -- Bank 48
    VME_CLK_B       : in std_logic;                        -- Bank 48, not used
    KUS_VME_OE_B    : out std_logic;                       -- Bank 44
    KUS_VME_DIR     : out std_logic;                       -- Bank 44
    VME_DTACK_KUS_B : out std_logic;                       -- Bank 44

    DCFEB_TCK_P    : out std_logic_vector(NCFEB downto 1); -- Bank 68
    DCFEB_TCK_N    : out std_logic_vector(NCFEB downto 1); -- Bank 68
    DCFEB_TMS_P    : out std_logic;                        -- Bank 68
    DCFEB_TMS_N    : out std_logic;                        -- Bank 68
    DCFEB_TDI_P    : out std_logic;                        -- Bank 68
    DCFEB_TDI_N    : out std_logic;                        -- Bank 68
    DCFEB_TDO_P    : in  std_logic_vector(NCFEB downto 1); -- Bank 67-68
    DCFEB_TDO_N    : in  std_logic_vector(NCFEB downto 1); -- Bank 67-68
    DCFEB_DONE     : in  std_logic_vector(NCFEB downto 1); -- Bank 68
    RESYNC_P       : out std_logic;                        -- Bank 66
    RESYNC_N       : out std_logic;                        -- Bank 66
    BC0_P          : out std_logic;                        -- Bank 68
    BC0_N          : out std_logic;                        -- Bank 68
    INJPLS_P       : out std_logic;                        -- Bank 66, ODMB CTRL
    INJPLS_N       : out std_logic;                        -- Bank 66, ODMB CTRL
    EXTPLS_P       : out std_logic;                        -- Bank 66, ODMB CTRL
    EXTPLS_N       : out std_logic;                        -- Bank 66, ODMB CTRL
    L1A_P          : out std_logic;                        -- Bank 66, ODMB CTRL
    L1A_N          : out std_logic;                        -- Bank 66, ODMB CTRL
    L1A_MATCH_P    : out std_logic_vector(NCFEB downto 1); -- Bank 66, ODMB CTRL
    L1A_MATCH_N    : out std_logic_vector(NCFEB downto 1); -- Bank 66, ODMB CTRL
    PPIB_OUT_EN_B  : out std_logic;                        -- Bank 68

    KUS_DL_SEL_B   : out std_logic;                        -- Bank 47
    DONE           : in std_logic;                         -- Bank 66
    FPGA_SEL_18    : out std_logic;                        -- Bank 47
    RST_CLKS_18_B  : out std_logic;                        -- Bank 47

    LVMB_PON   : out std_logic_vector(7 downto 0);
    PON_LOAD   : out std_logic;
    PON_OE_B   : out std_logic;
    R_LVMB_PON : in  std_logic_vector(7 downto 0);
    LVMB_CSB   : out std_logic_vector(6 downto 0);
    LVMB_SCLK  : out std_logic;
    LVMB_SDIN  : out std_logic
    --LVMB_SDOUT : in  std_logic;

    --DCFEB_PRBS_FIBER_SEL : out std_logic_vector(3 downto 0);
    --DCFEB_PRBS_EN        : out std_logic;
    --DCFEB_PRBS_RST       : out std_logic;
    --DCFEB_PRBS_RD_EN     : out std_logic;
    --DCFEB_RXPRBSERR      : in  std_logic;
    --DCFEB_PRBS_ERR_CNT   : in  std_logic_vector(15 downto 0);

    --OTMB_TX : in  std_logic_vector(48 downto 0);
    --OTMB_RX : out std_logic_vector(5 downto 0);

    --------------------
    -- Other
    --------------------
    --DIAGOUT     : out std_logic_vector(17 downto 0); --for debugging
    --RST         : in std_logic;

    --------------------------------
    -- KCU signals (not in real ODMB)
    --------------------------------
    --VME_DATA_IN    : in std_logic_vector (15 downto 0); --no internal IOBUFs on KCU
    --VME_DATA_OUT   : out std_logic_vector (15 downto 0) --no internal IOBUFs on KCU
    );
end ODMB7_UCSB_DEV;

architecture Behavioral of ODMB7_UCSB_DEV is
  -- Constants
  constant bw_data  : integer := 16; -- data bit width

  component clockManager is
  port (
    RESET : in std_logic := '0';
    CLK_IN1_P  : in std_logic := '0';
    CLK_IN1_N  : in std_logic := '0';
    CLK_OUT160 : out std_logic := '0';
    CLK_OUT80  : out std_logic := '0';
    CLK_OUT40  : out std_logic := '0';
    CLK_OUT20  : out std_logic := '0';
    CLK_OUT10  : out std_logic := '0'
  );
  end component;

  component ODMB_VME is
    generic (
      NCFEB       : integer range 1 to 7 := 7  -- Number of DCFEBS, 7 for ME1/1, 5
      );
    port (
      --------------------
      -- Clock
      --------------------
      CLK160      : in std_logic;  -- For dcfeb prbs (160MHz)
      CLK40       : in std_logic;  -- NEW (fastclk -> 40MHz)
      CLK10       : in std_logic;  -- NEW (midclk -> fastclk/4 -> 10MHz)
      CLK2P5      : in std_logic;  -- 2.5 MHz clock

      --------------------
      -- VME signals  <-- relevant ones only
      --------------------
      VME_DATA_IN   : in std_logic_vector (15 downto 0);
      VME_DATA_OUT  : out std_logic_vector (15 downto 0);
      VME_GAP_B     : in std_logic;     -- Also known as GA(5)
      VME_GA_B      : in std_logic_vector (4 downto 0);
      VME_ADDR      : in std_logic_vector (23 downto 1);
      VME_AM        : in std_logic_vector (5 downto 0);
      VME_AS_B      : in std_logic;
      VME_DS_B      : in std_logic_vector (1 downto 0);
      VME_LWORD_B   : in std_logic;
      VME_WRITE_B   : in std_logic;
      VME_IACK_B    : in std_logic;
      VME_BERR_B    : in std_logic;
      VME_SYSFAIL_B : in std_logic;
      VME_DTACK_B   : inout std_logic;
      VME_OE_B      : out std_logic;
      VME_DIR_B     : out std_logic;

      --------------------
      -- JTAG Signals To/From DCFEBs
      --------------------
      DCFEB_TCK    : out std_logic_vector (NCFEB downto 1);
      DCFEB_TMS    : out std_logic;
      DCFEB_TDI    : out std_logic;
      DCFEB_TDO    : in  std_logic_vector (NCFEB downto 1);

      DCFEB_DONE     : in std_logic_vector (NCFEB downto 1);
      DCFEB_INITJTAG : in std_logic;   -- TODO: where does this fit in

      --------------------
      -- From/To LVMB: ODMB & ODMB7 design, ODMB5 to be seen
      --------------------
      LVMB_PON   : out std_logic_vector(7 downto 0);
      PON_LOAD   : out std_logic;
      PON_OE_B   : out std_logic;
      R_LVMB_PON : in  std_logic_vector(7 downto 0);
      LVMB_CSB   : out std_logic_vector(6 downto 0);
      LVMB_SCLK  : out std_logic;
      LVMB_SDIN  : out std_logic;
      --LVMB_SDOUT : in  std_logic;

      -- DIAGOUT_LVDBMON  : out std_logic_vector(17 downto 0);

      --------------------
      -- TODO: DCFEB PRBS signals
      --------------------
--      DCFEB_PRBS_FIBER_SEL : out std_logic_vector(3 downto 0);
--      DCFEB_PRBS_EN        : out std_logic;
--      DCFEB_PRBS_RST       : out std_logic;
--      DCFEB_PRBS_RD_EN     : out std_logic;
--      DCFEB_RXPRBSERR      : in  std_logic;
--      DCFEB_PRBS_ERR_CNT   : in  std_logic_vector(15 downto 0);

      --------------------
      -- TODO: OTMB PRBS signals
      --------------------
--      OTMB_TX : in  std_logic_vector(48 downto 0);
--      OTMB_RX : out std_logic_vector(5 downto 0);
      
      --------------------
      -- VMEMON Configuration signals for top level
      --------------------
      FW_RESET             : out std_logic;
      L1A_RESET_PULSE      : out std_logic;
      TEST_INJ             : out std_logic;
      TEST_PLS             : out std_logic;
      TEST_BC0             : out std_logic;
      TEST_PED             : out std_logic;
      TEST_LCT             : out std_logic;
      MASK_L1A             : out std_logic_vector(NCFEB downto 0);
      MASK_PLS             : out std_logic;
      ODMB_CTRL            : out std_logic_vector(15 downto 0);
      ODMB_DATA            : in std_logic_vector(15 downto 0);
      ODMB_DATA_SEL        : out std_logic_vector(7 downto 0);

      --------------------
      -- VMECONFREGS Configuration signals for top level
      --------------------
      LCT_L1A_DLY          : out std_logic_vector(5 downto 0);
      INJ_DLY              : out std_logic_vector(4 downto 0);
      EXT_DLY              : out std_logic_vector(4 downto 0);
      CALLCT_DLY           : out std_logic_vector(3 downto 0);
      CABLE_DLY            : out integer range 0 to 1;

      --------------------
      -- Other
      --------------------
      DIAGOUT     : out std_logic_vector (17 downto 0); -- for debugging
      STROBE_OUT  : out std_logic;
      RST         : in std_logic;
    --Baseline debugging signals
    OUT_SELFEB : out std_logic_vector(NCFEB downto 1);
    OUT_LOAD : out std_logic;
    OUT_BUSY : out std_logic;
    OUT_TCK_GLOBAL : out std_logic;
    OUT_SHIHEAD : out std_logic;
    OUT_SHDHEAD : out std_logic;
    OUT_SHDATA : out std_logic;
    OUT_SHTAIL : out std_logic
      );
  end component;

  component ODMB_CTRL is
    generic (
      NCFEB       : integer range 1 to 7 := 7  -- Number of DCFEBS, 7 for ME1/1, 5
      );
    port (
      --------------------
      -- Clock
      --------------------
      CLK80       : in std_logic;
      CLK40       : in std_logic;

      --------------------
      -- ODMB VME <-> CALIBTRIG
      --------------------
      TEST_CCBINJ   : in std_logic;
      TEST_CCBPLS   : in std_logic;
      TEST_CCBPED   : in std_logic;

      --------------------
      -- Delay registers (from VMECONFREGS)
      --------------------
      LCT_L1A_DLY   : in std_logic_vector(5 downto 0);
      INJ_DLY       : in std_logic_vector(4 downto 0);
      EXT_DLY       : in std_logic_vector(4 downto 0);
      CALLCT_DLY    : in std_logic_vector(3 downto 0);

      --------------------
      -- Configuration
      --------------------
      CAL_MODE      : in std_logic;
      PEDESTAL      : in std_logic;

      --------------------
      -- Triggers
      --------------------
      RAW_L1A       : in std_logic;
      
      --------------------
      -- To/From DCFEBs (FF-EMU-MOD)
      --------------------
      DCFEB_INJPULSE  : out std_logic;
      DCFEB_EXTPULSE  : out std_logic;
      DCFEB_L1A       : out std_logic;
      DCFEB_L1A_MATCH : out std_logic_vector(NCFEB downto 1);

      --------------------
      -- Other
      --------------------
      DIAGOUT     : out std_logic_vector (17 downto 0); -- for debugging
      RST         : in std_logic
      );
  end component;

  component LCTDLY is  -- Aligns RAW_LCT with L1A by 2.4 us to 4.8 us
    port (
      DIN   : in std_logic;
      CLK   : in std_logic;
      DELAY : in std_logic_vector(5 downto 0);
      DOUT : out std_logic
      );
  end component;
  
  component ila is
    port (
      clk : in std_logic := '0';
      probe0 : in std_logic_vector(127 downto 0) := (others=> '0')
    );
    end component;

  --------------------------------------
  -- VME signals
  --------------------------------------
  -- signal cmd_adrs     : std_logic_vector (15 downto 0);
  signal vme_dir_b    : std_logic;
  signal vme_dir      : std_logic;
  signal vme_oe_b_inner : std_logic;
  signal vme_dtack    : std_logic;
  signal vme_data_out_buf, vme_data_in_buf : std_logic_vector(15 downto 0) := (others => '0');
  signal diagout      : std_logic_vector(17 downto 0) := (others => '0');
  signal rst          : std_logic := '0';

  --------------------------------------
  -- Clock synthesizer and clock signals
  --------------------------------------
  signal clk160_unbuf    : std_logic := '0';
  signal clk160          : std_logic := '0';
  signal clk80_unbuf     : std_logic := '0';
  signal clk80           : std_logic := '0';
  signal clk40_unbuf     : std_logic := '0';
  signal clk40           : std_logic := '0';
  signal clk20_unbuf     : std_logic := '0';
  signal clk20           : std_logic := '0';
  signal clk10_unbuf     : std_logic := '0';
  signal clk10           : std_logic := '0';
  signal clk5_unbuf      : std_logic := '0';
  signal clk5_inv        : std_logic := '1';
  signal clk2p5_unbuf    : std_logic := '0';
  signal clk2p5_inv      : std_logic := '1';
  signal clk2p5          : std_logic := '0';

  --------------------------------------
  -- PPIB/DCFEB signals
  --------------------------------------
  signal dcfeb_tck    : std_logic_vector (NCFEB downto 1) := (others => '0');
  signal dcfeb_tms    : std_logic := '0';
  signal dcfeb_tdi    : std_logic := '0';
  signal dcfeb_tdo    : std_logic_vector (NCFEB downto 1) := (others => '0');
  -- signal dcfeb_tms_t  : std_logic := '0';

  signal reset_pulse, reset_pulse_q : std_logic := '0';
  signal l1acnt_rst, l1a_reset_pulse, l1a_reset_pulse_q : std_logic := '0';
  signal l1acnt_rst_meta, l1acnt_rst_sync : std_logic := '0';
  signal premask_injpls, premask_extpls, dcfeb_injpls, dcfeb_extpls : std_logic := '0';
  signal test_bc0, pre_bc0, dcfeb_bc0, dcfeb_resync : std_logic := '0';
  signal dcfeb_l1a, masked_l1a, odmbctrl_l1a : std_logic := '0';
  signal dcfeb_l1a_match, masked_l1a_match, odmbctrl_l1a_match : std_logic_vector(NCFEB downto 1) := (others => '0');

  -- signals to generate dcfeb_initjtag when DCFEBs are done programming
  signal pon_rst_reg : std_logic_vector(31 downto 0) := x"00FFFFFF";
  signal pon_reset : std_logic := '0';
  signal done_cnt_en, done_cnt_rst                           : std_logic_vector(NCFEB downto 1);
  type done_cnt_type is array (NCFEB downto 1) of integer range 0 to 3;
  signal done_cnt                                            : done_cnt_type;
  type done_state_type is (DONE_IDLE, DONE_LOW, DONE_COUNTING);
  type done_state_array_type is array (NCFEB downto 1) of done_state_type;
  signal done_next_state, done_current_state                 : done_state_array_type;
  signal dcfeb_done_pulse : std_logic_vector(NCFEB downto 1) := (others => '0');
  signal dcfeb_initjtag : std_logic := '0';
  signal dcfeb_initjtag_d : std_logic := '0';
  signal dcfeb_initjtag_dd : std_logic := '0';

  --------------------------------------
  -- Triggers
  --------------------------------------
  signal test_lct, test_pb_lct, test_l1a : std_logic := '0';
  signal raw_l1a : std_logic := '0';
  
  --------------------------------------
  -- Internal configuration signals
  --------------------------------------
  signal mask_pls : std_logic := '0';
  signal mask_l1a : std_logic_vector(NCFEB downto 0) := (others => '0');
  signal lct_l1a_dly : std_logic_vector(5 downto 0) := (others => '0');
  signal inj_dly : std_logic_vector(4 downto 0) := (others => '0');
  signal ext_dly : std_logic_vector(4 downto 0) := (others => '0');
  signal callct_dly : std_logic_vector(3 downto 0) := (others => '0');
  signal cable_dly : integer range 0 to 1;
  signal odmb_ctrl_reg : std_logic_vector(15 downto 0) := (others => '0');

  --------------------------------------
  -- ODMB VME<->ODMB CTRL signals
  --------------------------------------
  signal test_inj, test_pls, test_ped : std_logic := '0';

  --------------------------------------
  -- Reset signals
  --------------------------------------
  signal fw_reset, fw_reset_q : std_logic := '0';
  signal ccb_softrst_b_q : std_logic := '1'; --no CCB currently
  signal fw_rst_reg : std_logic_vector(31 downto 0) := (others => '0');
  signal reset : std_logic := '0';

  --------------------------------------
  -- Data readout signals
  --------------------------------------
  signal odmb_data : std_logic_vector(15 downto 0) := (others => '0');
  signal odmb_data_sel : std_logic_vector(7 downto 0) := (others => '0');
  
  --------------------------------------
  -- Debug signals
  --------------------------------------
  attribute mark_debug : string;
  signal ila_probe : std_logic_vector(127 downto 0) := (others => '0');
  signal vme_crate_addr : std_logic_vector(4 downto 0) := (others => '0');
  signal vme_cmd : std_logic_vector(15 downto 0) := (others => '0');
  signal strobe : std_logic := '0';
  attribute mark_debug of vme_crate_addr : signal is "true";
  attribute mark_debug of vme_cmd : signal is "true";

  signal load, busy, tck_global, shihead, shdhead, shdata, shtail : std_logic := '0';
  signal selfeb : std_logic_vector(7 downto 1) := (others => '0');

begin

  -------------------------------------------------------------------------------------------
  -- Temporary debugging code
  -------------------------------------------------------------------------------------------
  i_ila : ila
    port map(
      clk => clk40,   -- everything is clocked on 40 MHz or slower so to maximize useful buffer size use 40 MHz
      probe0 => ila_probe
    );
  --ila_probe(0) <= clk40;
  ila_probe(17 downto 2) <= vme_data_in_buf;
  ila_probe(33 downto 18) <= vme_data_out_buf;
  ila_probe(38 downto 34) <= vme_crate_addr;
  ila_probe(54 downto 39) <= vme_cmd;
  ila_probe(60 downto 55) <= VME_AM;
  ila_probe(65 downto 61) <= VME_GA_B;
  ila_probe(66) <= VME_GAP_B;
  ila_probe(67) <= VME_AS_B;
  ila_probe(69 downto 68) <= VME_DS_B;
  ila_probe(70) <= VME_SYSFAIL_B;
  ila_probe(71) <= VME_BERR_B;
  ila_probe(72) <= VME_IACK_B;
  ila_probe(73) <= VME_LWORD_B;
  ila_probe(74) <= VME_WRITE_B;
  ila_probe(75) <= vme_dtack;
  ila_probe(76) <= vme_dir;
  ila_probe(77) <= vme_oe_b_inner;
  ila_probe(78) <= strobe;
  ila_probe(85 downto 79) <= dcfeb_tck;
  ila_probe(92 downto 86) <= dcfeb_tdo;
  ila_probe(93) <= dcfeb_tdi;
  ila_probe(94) <= dcfeb_tms;
  ila_probe(95) <= load;
  ila_probe(96) <= busy;
  ila_probe(97) <= tck_global;
  ila_probe(104 downto 98) <= selfeb;
  ila_probe(105) <= shihead;
  ila_probe(106) <= shdhead;
  ila_probe(107) <= shdata;
  ila_probe(108) <= shtail;
  vme_crate_addr <= VME_ADDR(23 downto 19);
  vme_cmd <= VME_ADDR(15 downto 1) & "0";

  -------------------------------------------------------------------------------------------
  -- Don't kill JTAG or clocks
  -------------------------------------------------------------------------------------------

  KUS_DL_SEL_B <= '1';
  FPGA_SEL_18 <= '0';
  RST_CLKS_18_B <= '1';

  -------------------------------------------------------------------------------------------
  -- Handle clock synthesizer signals and generate clocks
  -------------------------------------------------------------------------------------------

  -- In first version of test firmware, we will want to generate everything from 40 MHz cms clock, likely with Clock Manager IP
  -- generate 20 and 2p5 clock
  ClockManager_i : clockManager
  port map(
    RESET => '0',
    CLK_IN1_P => CMS_CLK_FPGA_P,
    CLK_IN1_N => CMS_CLK_FPGA_N,
    CLK_OUT160 => clk160_unbuf,
    CLK_OUT80 => clk80_unbuf,
    CLK_OUT40 => clk40_unbuf,
    CLK_OUT20 => clk20_unbuf,
    CLK_OUT10 => clk10_unbuf
  );

  --generate slower clocks with flip flops
  clk5_inv <= not clk5_unbuf;
  clk2p5_inv <= not clk2p5_unbuf;
  FD_clk5   : FD port map(D => clk5_inv,   C => clk10, Q => clk5_unbuf  );
  FD_clk2p5 : FD port map(D => clk2p5_inv, C => clk10, Q => clk2p5_unbuf);
  BUFG_clk160  : BUFG port map(I => clk160_unbuf, O => clk160);
  BUFG_clk80  : BUFG port map(I => clk80_unbuf, O => clk80);
  BUFG_clk40  : BUFG port map(I => clk40_unbuf, O => clk40);
  BUFG_clk20  : BUFG port map(I => clk20_unbuf, O => clk20);
  BUFG_clk10  : BUFG port map(I => clk10_unbuf, O => clk10);
  BUFG_clk2p5 : BUFG port map(I => clk2p5_unbuf, O => clk2p5);

  -------------------------------------------------------------------------------------------
  -- Handle VME signals
  -------------------------------------------------------------------------------------------

  -- Handle VME data direction line
  VME_DTACK_KUS_B <= vme_dtack;
  KUS_VME_DIR <= vme_dir;
  vme_dir <= not vme_dir_b;
  KUS_VME_OE_B <= vme_oe_b_inner;

  --real board/simulation can have IOBUFs
  GEN_VMEOUT_16 : for I in 0 to 15 generate
  begin
    VME_BUF : IOBUF port map(O => vme_data_in_buf(I), IO => VME_DATA(I), I => vme_data_out_buf(I), T => vme_dir_b); 
  end generate GEN_VMEOUT_16;
  

  -------------------------------------------------------------------------------------------
  -- Handle PPIB/DCFEB signals
  -------------------------------------------------------------------------------------------

  PPIB_OUT_EN_B <= '0';
  -- Handle DCFEB I/O buffers
  -- OB_DCFEB_TMS: OBUFTDS port map (I => dcfeb_tms, O => DCFEB_TMS_P, OB => DCFEB_TMS_N, T => dcfeb_tms_t);
  --real board/simulation has I/OBUFs
  OB_DCFEB_TMS: OBUFDS port map (I => dcfeb_tms, O => DCFEB_TMS_P, OB => DCFEB_TMS_N);
  OB_DCFEB_TDI: OBUFDS port map (I => dcfeb_tdi, O => DCFEB_TDI_P, OB => DCFEB_TDI_N);
  OB_DCFEB_INJPLS: OBUFDS port map (I => dcfeb_injpls, O => INJPLS_P, OB => INJPLS_N);
  OB_DCFEB_EXTPLS: OBUFDS port map (I => dcfeb_extpls, O => EXTPLS_P, OB => EXTPLS_N);
  OB_DCFEB_RESYNC: OBUFDS port map (I => dcfeb_resync, O => RESYNC_P, OB => RESYNC_N);
  OB_DCFEB_BC0: OBUFDS port map (I => dcfeb_bc0, O => BC0_P, OB => BC0_N);
  OB_DCFEB_L1A: OBUFDS port map (I => dcfeb_l1a, O => L1A_P, OB => L1A_N);
  GEN_DCFEBJTAG_7 : for I in 1 to NCFEB generate
  begin
    OB_DCFEB_TCK: OBUFDS port map (I => dcfeb_tck(I), O => DCFEB_TCK_P(I), OB => DCFEB_TCK_N(I));
    IB_DCFEB_TDO: IBUFDS port map (O => dcfeb_tdo(I), I => DCFEB_TDO_P(I), IB => DCFEB_TDO_N(I));
    OB_DCFEB_L1A_MATCH: OBUFDS port map (I => dcfeb_l1a_match(I), O => L1A_MATCH_P(I), OB => L1A_MATCH_N(I));
  end generate GEN_DCFEBJTAG_7;

  --generate pulses if not masked
  dcfeb_injpls <= '0' when mask_pls = '1' else premask_injpls;
  dcfeb_extpls <= '0' when mask_pls = '1' else premask_extpls;
  
  --generate RESYNC, BC0, L1A, and L1A match signals to DCFEBs
  RESETPULSE : PULSE2SAME port map(DOUT => reset_pulse, CLK_DOUT => clk40, RST => '0', DIN => reset);
  FD_RESETPULSE_Q : FD port map (Q => reset_pulse_q,     C => CLK40, D => reset_pulse);
  FD_L1APULSE_Q   : FD port map (Q => l1a_reset_pulse_q, C => CLK40, D => l1a_reset_pulse);

  --TODO: fix this logic, copied from ODMB because timing violations
  --l1acnt_rst <= clk20 and (l1a_reset_pulse or l1a_reset_pulse_q or reset_pulse or reset_pulse_q);
  proc_sync_l1acnt : process (clk40)
  begin
  if rising_edge(clk40) then
    l1acnt_rst <= (l1a_reset_pulse or l1a_reset_pulse_q or reset_pulse or reset_pulse_q);
    l1acnt_rst_meta <= l1acnt_rst;
    l1acnt_rst_sync <= l1acnt_rst_meta;
  end if;
  end process;
  
  pre_bc0    <= test_bc0;
  masked_l1a <= '0' when mask_l1a(0)='1' else odmbctrl_l1a;

  DS_RESYNC : DELAY_SIGNAL generic map (NCYCLES_MAX => 1) port map (DOUT => dcfeb_resync, CLK => CLK40, NCYCLES => cable_dly, DIN => l1acnt_rst_sync);
  DS_BC0    : DELAY_SIGNAL generic map (NCYCLES_MAX => 1) port map (DOUT => dcfeb_bc0,    CLK => CLK40, NCYCLES => cable_dly, DIN => pre_bc0   );
  DS_L1A    : DELAY_SIGNAL generic map (NCYCLES_MAX => 1) port map (DOUT => dcfeb_l1a,    CLK => CLK40, NCYCLES => cable_dly, DIN => masked_l1a);

  GEN_DCFEB_L1A_MATCH : for I in 1 to NCFEB generate
  begin
    masked_l1a_match(I) <= '0' when mask_l1a(I)='1' else odmbctrl_l1a_match(I);
    DS_L1A_MATCH : DELAY_SIGNAL generic map (NCYCLES_MAX => 1) port map (DOUT => dcfeb_l1a_match(I), CLK => CLK40, NCYCLES => cable_dly, DIN => masked_l1a_match(I));
  end generate GEN_DCFEB_L1A_MATCH;

  -- FSM to handle initialization when DONE received from DCFEBs
  -- Generate dcfeb_initjtag
  done_fsm_regs : process (done_next_state, pon_reset, CLK10)
  begin
    for dev in 1 to NCFEB loop
      if (pon_reset = '1') then
        done_current_state(dev) <= DONE_LOW;
      elsif rising_edge(CLK10) then
        done_current_state(dev) <= done_next_state(dev);
        if done_cnt_rst(dev) = '1' then
          done_cnt(dev) <= 0;
        elsif done_cnt_en(dev) = '1' then
          done_cnt(dev) <= done_cnt(dev) + 1;
        end if;
      end if;
    end loop;
  end process;

  done_fsm_logic : process (done_current_state, DCFEB_DONE, done_cnt)
  begin
    for dev in 1 to NCFEB loop
      case done_current_state(dev) is
        when DONE_IDLE =>
          done_cnt_en(dev)      <= '0';
          dcfeb_done_pulse(dev) <= '0';
          if (DCFEB_DONE(dev) = '0') then
            done_next_state(dev) <= DONE_LOW;
            done_cnt_rst(dev)    <= '1';
          else
            done_next_state(dev) <= DONE_IDLE;
            done_cnt_rst(dev)    <= '0';
          end if;

        when DONE_LOW =>
          done_cnt_en(dev)      <= '0';
          dcfeb_done_pulse(dev) <= '0';
          done_cnt_rst(dev)     <= '0';
          if (DCFEB_DONE(dev) = '1') then
            done_next_state(dev) <= DONE_COUNTING;
          else
            done_next_state(dev) <= DONE_LOW;
          end if;

        when DONE_COUNTING =>
          if (DCFEB_DONE(dev) = '0') then
            done_next_state(dev)  <= DONE_LOW;
            done_cnt_en(dev)      <= '0';
            dcfeb_done_pulse(dev) <= '0';
            done_cnt_rst(dev)     <= '1';
          elsif (done_cnt(dev) = 3) then  -- DONE has to be high at least 400 us to avoid spurious edges
            done_next_state(dev)  <= DONE_IDLE;
            done_cnt_en(dev)      <= '0';
            dcfeb_done_pulse(dev) <= '1';
            done_cnt_rst(dev)     <= '0';
          else
            done_next_state(dev)  <= DONE_COUNTING;
            done_cnt_en(dev)      <= '1';
            dcfeb_done_pulse(dev) <= '0';
            done_cnt_rst(dev)     <= '0';
          end if;
      end case;
    end loop;
  end process;

  dcfeb_initjtag_dd <= or_reduce(dcfeb_done_pulse);
  -- FIXME: temporarily using clk40 so I don't have to wait an eternity, 10kHz in realistic design
  DS_DCFEB_INITJTAG    : DELAY_SIGNAL generic map(240) port map(DOUT => dcfeb_initjtag_d, CLK => CLK40, NCYCLES => 240, DIN => dcfeb_initjtag_dd);
  -- FIXME: temporarily using clk40 so I don't have to wait an eternity, 625kHz in realistic design
  PULSE_DCFEB_INITJTAG : NPULSE2FAST port map(DOUT => dcfeb_initjtag, CLK_DOUT => CLK40, RST => '0', NPULSE => 5, DIN => dcfeb_initjtag_d);

  -------------------------------------------------------------------------------------------
  -- Handle Triggers
  -------------------------------------------------------------------------------------------

  test_pb_lct <= test_lct;
  LCTDLY_GTRG : LCTDLY port map(DIN => test_pb_lct, CLK => CLK40, DELAY => lct_l1a_dly, DOUT => test_l1a);
  raw_l1a <= test_l1a;

  -------------------------------------------------------------------------------------------
  -- Handle Internal configuration signals
  -------------------------------------------------------------------------------------------

  -------------------------------------------------------------------------------------------
  -- Handle reset signals
  -------------------------------------------------------------------------------------------

  FD_FW_RESET : FD port map (Q => fw_reset_q, C => CLK40, D => fw_reset);
  fw_rst_reg <= x"3FFFF000" when ((fw_reset_q = '0' and fw_reset = '1') or ccb_softrst_b_q = '0') else
                  fw_rst_reg(30 downto 0) & '0' when rising_edge(clk40) else
                  fw_rst_reg;
  reset <= fw_rst_reg(31) or pon_rst_reg(31) or RST;
  -- original: reset <= fw_rst_reg(31) or pon_rst_reg(31) or not pb0_q;
  -- pon_rst_reg used to be reset from pll lock
  pon_rst_reg    <= pon_rst_reg(30 downto 0) & '0' when rising_edge(clk40) else
                    pon_rst_reg;
  pon_reset <= pon_rst_reg(31);

  -------------------------------------------------------------------------------------------
  -- Handle data readout
  -------------------------------------------------------------------------------------------

  odmb_status_pro : process (odmb_data_sel, VME_GAP_B, VME_GA_B)
  begin
    
    case odmb_data_sel is

      --debug register
      when x"06" => odmb_data <= x"7E57";

      when x"20" => odmb_data <= "0000000000" & VME_GAP_B & VME_GA_B;

      when others => odmb_data <= (others => '1');
    end case;
  end process;

  -------------------------------------------------------------------------------------------
  -- Sub-modules
  -------------------------------------------------------------------------------------------
  
  MBV : ODMB_VME
    generic map (
      NCFEB => NCFEB
      )
    port map (
      CLK160         => CLK160,
      CLK40          => CLK40,
      CLK10          => CLK10,
      CLK2P5	     => clk2p5,

      VME_DATA_IN    => vme_data_in_buf,
      VME_DATA_OUT   => vme_data_out_buf,
      VME_GAP_B      => VME_GAP_B,
      VME_GA_B       => VME_GA_B,
      VME_ADDR       => VME_ADDR,
      VME_AM         => VME_AM,
      VME_AS_B       => VME_AS_B,
      VME_DS_B       => VME_DS_B,
      VME_LWORD_B    => VME_LWORD_B,
      VME_WRITE_B    => VME_WRITE_B,
      VME_IACK_B     => VME_IACK_B,
      VME_BERR_B     => VME_BERR_B,
      VME_SYSFAIL_B  => VME_SYSFAIL_B,
      VME_DTACK_B    => vme_dtack,
      VME_OE_B       => vme_oe_b_inner,
      VME_DIR_B      => vme_dir_b,      -- to be used in IOBUF

      DCFEB_TCK      => dcfeb_tck,
      DCFEB_TMS      => dcfeb_tms,
      DCFEB_TDI      => dcfeb_tdi,
      DCFEB_TDO      => dcfeb_tdo,
      DCFEB_DONE     => DCFEB_DONE,
      DCFEB_INITJTAG => dcfeb_initjtag,

      LVMB_PON    => LVMB_PON,
      PON_LOAD    => PON_LOAD,
      PON_OE_B    => PON_OE_B,
      R_LVMB_PON  => R_LVMB_PON,
      LVMB_CSB    => LVMB_CSB,
      LVMB_SCLK   => LVMB_SCLK,
      LVMB_SDIN   => LVMB_SDIN,
--      LVMB_SDOUT  => LVMB_SDOUT,

--      DCFEB_PRBS_FIBER_SEL  => DCFEB_PRBS_FIBER_SEL,
--      DCFEB_PRBS_EN         => DCFEB_PRBS_EN,
--      DCFEB_PRBS_RST        => DCFEB_PRBS_RST,
--      DCFEB_PRBS_RD_EN      => DCFEB_PRBS_RD_EN,
--      DCFEB_RXPRBSERR       => DCFEB_RXPRBSERR,
--      DCFEB_PRBS_ERR_CNT    => DCFEB_PRBS_ERR_CNT,

--      OTMB_TX  => OTMB_TX,
--      OTMB_RX  => OTMB_RX,
      
      FW_RESET => fw_reset,
      L1A_RESET_PULSE => l1a_reset_pulse,
      TEST_INJ => test_inj,
      TEST_PLS => test_pls,
      TEST_BC0 => test_bc0,
      TEST_PED => test_ped,
      TEST_LCT => test_lct,
      MASK_L1A => mask_l1a,
      MASK_PLS => mask_pls,
      ODMB_CTRL => odmb_ctrl_reg,
      ODMB_DATA => odmb_data,
      ODMB_DATA_SEL => odmb_data_sel,

      LCT_L1A_DLY => lct_l1a_dly,
      INJ_DLY => inj_dly, 
      EXT_DLY => ext_dly, 
      CALLCT_DLY => callct_dly, 
      CABLE_DLY => cable_dly,

      DIAGOUT  => DIAGOUT,
      STROBE_OUT => strobe,
      RST      => reset,
      OUT_SELFEB => selfeb,
      OUT_LOAD => load,
      OUT_BUSY => busy,
      OUT_TCK_GLOBAL => tck_global,
      OUT_SHIHEAD => shihead,
      OUT_SHDHEAD => shdhead,
      OUT_SHDATA => shdata,
      OUT_SHTAIL => shtail
      );

  MBC : ODMB_CTRL 
    generic map (
      NCFEB => NCFEB
      )
    port map (
      CLK80 => CLK80,
      CLK40 => CLK40,

      TEST_CCBINJ => test_inj,
      TEST_CCBPLS => test_pls,
      TEST_CCBPED => test_ped, 

      CAL_MODE => odmb_ctrl_reg(0),
      PEDESTAL => odmb_ctrl_reg(13),

      RAW_L1A => raw_l1a,

      LCT_L1A_DLY => lct_l1a_dly,
      INJ_DLY => inj_dly, 
      EXT_DLY => ext_dly, 
      CALLCT_DLY => callct_dly, 
      
      DCFEB_INJPULSE => premask_injpls,
      DCFEB_EXTPULSE => premask_extpls,
      DCFEB_L1A => odmbctrl_l1a,                    
      DCFEB_L1A_MATCH => odmbctrl_l1a_match,        

      DIAGOUT => open,
      RST => reset
      );

end Behavioral;
