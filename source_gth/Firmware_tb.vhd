library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

use work.Firmware_pkg.all;

entity Firmware_tb is
  PORT ( 
    -- 300 MHz clk_in
    CLK_IN_P : in std_logic;
    CLK_IN_N : in std_logic;
    -- 40 MHz clk out
    J36_USER_SMA_GPIO_P : out std_logic;
    -- GTH stuff
    mgtrefclk0_x0y3_p: in std_logic;
    mgtrefclk0_x0y3_n: in std_logic;
    ch0_gthrxn_in: in std_logic;
    ch0_gthrxp_in: in std_logic;
    ch0_gthtxn_out: out std_logic;
    ch0_gthtxp_out: out std_logic;
    ch1_gthrxn_in: in std_logic;
    ch1_gthrxp_in: in std_logic;
    ch1_gthtxn_out: out std_logic;
    ch1_gthtxp_out: out std_logic
  );      
end Firmware_tb;

architecture Behavioral of Firmware_tb is
  component clockManager is
  port (
    CLK_IN300 : in std_logic := '0';
    CLK_OUT40 : out std_logic := '0';
    CLK_OUT10 : out std_logic := '0';
    CLK_OUT80 : out std_logic := '0'
  );
  end component;
  component ila is
  port (
    clk : in std_logic := '0';
    probe0 : in std_logic_vector(31 downto 0) := (others=> '0')
    --probe1 : in std_logic_vector(4095 downto 0) := (others => '0')
  );
  end component;
  component lut_input1 is
  port (
    clka : in std_logic := '0';
    addra : in std_logic_vector(1 downto 0) := (others=> '0');
    douta : out std_logic_vector(11 downto 0) := (others => '0')
  );
  end component;
  component lut_input2 is
  port (
    clka : in std_logic := '0';
    addra : in std_logic_vector(1 downto 0) := (others=> '0');
    douta : out std_logic_vector(11 downto 0) := (others => '0')
  );
  end component;

  -- Clock signals
  signal clk_in_buf : std_logic := '0';
  signal sysclk : std_logic := '0';
  signal sysclkQuarter : std_logic := '0'; 
  signal sysclkDouble : std_logic := '0';
  signal inputCounter: unsigned(13 downto 0) := (others=> '0');
  signal intime_s: std_logic := '0';
  -- Constants
  constant bw_input1 : integer := 12;
  constant bw_input2 : integer := 12;
  constant bw_output : integer := 20;
  constant bw_addr : integer := 2;
  constant nclocksrun : integer := 32000;
  -- Input to firmware signals
  signal input1_s: std_logic_vector(bw_input1-1 downto 0) := (others=> '0');
  signal input2_s: std_logic_vector(bw_input2-1 downto 0) := (others=> '0');
  -- Output to firmware signals
  signal output_s: std_logic_vector(bw_output-1 downto 0) := (others=> '0');
  signal output_clk : std_logic := '0';
  -- ILA
  signal trig0 : std_logic_vector(255 downto 0) := (others=> '0');
  signal data : std_logic_vector(31 downto 0) := (others=> '0');
  -- LUT input
  signal lut_input_addr_s : unsigned(bw_addr-1 downto 0) := (others=> '1');
  signal lut_input1_dout_c : std_logic_vector(bw_input1-1 downto 0) := (others=> '0');
  signal lut_input2_dout_c : std_logic_vector(bw_input2-1 downto 0) := (others=> '0');

begin

  input_clk_simulation_i : if in_simulation generate
    process
      constant clk_period_by_2 : time := 1.666 ns;
      begin
      while 1=1 loop
        clk_in_buf <= '0';
        wait for clk_period_by_2;
        clk_in_buf <= '1';
        wait for clk_period_by_2;
      end loop;
    end process;
  end generate input_clk_simulation_i;
  input_clk_synthesize_i : if in_synthesis generate
    ibufg_i : IBUFGDS
    port map (
               I => CLK_IN_P,
               IB => CLK_IN_N,
               O => clk_in_buf
             );
  end generate input_clk_synthesize_i;

  ClockManager_i : clockManager
  port map(
            CLK_IN300=> clk_in_buf,
            CLK_OUT40=> sysclk,
            CLK_OUT10=> sysclkQuarter,
            CLK_OUT80=> sysclkDouble
          );

  J36_USER_SMA_GPIO_P <= sysclk;

  i_ila : ila
  port map(
    clk => output_clk,
    --probe0 => trig0,
    probe0 => data
  );
  trig0(0) <= intime_s;
  trig0(13 downto 2) <= lut_input1_dout_c;
  trig0(25 downto 14) <= lut_input2_dout_c;
  --data(11 downto 0) <= input1_s;
  --data(23 downto 12) <= input2_s;
  --data(43 downto 24) <= output_s;
  --data(44) <= sysclkQuarter;
  data(19 downto 0) <= output_s;
  data(20) <= output_clk;

  -- Simulation process.
  inputGenerator_i: process (sysclk) is

    --Values
    variable init_input1: unsigned(bw_input1-1 downto 0):= to_unsigned(652,bw_input1);
    variable init_input2: unsigned(bw_input2-1 downto 0):= to_unsigned(2,bw_input2);

  begin

    -- Simulate data coming out every fourth clock
    if sysclk'event and sysclk='1' then

      inputCounter <= inputCounter + 1;

      -- Initalize lut_input_addr_s
      if inputCounter=5 then
        lut_input_addr_s <= to_unsigned(0,bw_addr);
        intime_s <= '0';
        input1_s <= std_logic_vector(init_input1);
        input2_s <= std_logic_vector(init_input2);
      -- Start giving lut address
      elsif inputCounter=6 then
        lut_input_addr_s <= lut_input_addr_s + 1;
        intime_s <= '0';
        input1_s <= std_logic_vector(init_input1);
        input2_s <= std_logic_vector(init_input2);
      -- Module gets input data
      elsif (inputCounter>=7) and (inputCounter<=nclocksrun+7) then
        lut_input_addr_s <= lut_input_addr_s + 1;
        intime_s <= '1';
        input1_s <= std_logic_vector(lut_input1_dout_c);
        input2_s <= std_logic_vector(lut_input2_dout_c);
      -- Stop giving data after nclocksrun
      else
        lut_input_addr_s <= to_unsigned(0,bw_addr);
        intime_s <= '0';
        input1_s <= std_logic_vector(init_input1);
        input2_s <= std_logic_vector(init_input2);
      end if;
      
    end if;

  end process;

  -- Input LUTs
  lut_input1_i: lut_input1
  port map(
            clka=> sysclk,
            addra=> std_logic_vector(lut_input_addr_s),
            douta=> lut_input1_dout_c
          );
  lut_input2_i: lut_input2
  port map(
            clka=> sysclk,
            addra=> std_logic_vector(lut_input_addr_s),
            douta=> lut_input2_dout_c
          );

  -- Firmware process
  firmware_i: entity work.Firmware
  port map(
            clk40=> sysclk,
            INPUT1=> input1_s,
            INPUT2=> input2_s,
            OUTPUT=> output_s,
            rxclk_out => output_clk,
    	    mgtrefclk0_x0y3_p=> mgtrefclk0_x0y3_p,
    	    mgtrefclk0_x0y3_n=> mgtrefclk0_x0y3_n,
    	    ch0_gthrxn_in=> ch0_gthrxn_in,
    	    ch0_gthrxp_in=> ch0_gthrxp_in,
    	    ch0_gthtxn_out=> ch0_gthtxn_out,
    	    ch0_gthtxp_out=> ch0_gthtxp_out,
    	    ch1_gthrxn_in=> ch1_gthrxn_in,
    	    ch1_gthrxp_in=> ch1_gthrxp_in,
    	    ch1_gthtxn_out=> ch1_gthtxn_out,
    	    ch1_gthtxp_out=> ch1_gthtxp_out
          );

end Behavioral;
