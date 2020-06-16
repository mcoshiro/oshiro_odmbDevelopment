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
    probe0 : in std_logic_vector(63 downto 0) := (others=> '0')
    --probe1 : in std_logic_vector(4095 downto 0) := (others => '0')
  );
  end component;

  -- Clock signals
  signal clk_in_buf : std_logic := '0';
  signal sysclk : std_logic := '0';
  signal sysclkQuarter : std_logic := '0'; 
  signal sysclkDouble : std_logic := '0';
  -- Constants
  constant bw_output : integer := 20;
  -- Output to firmware signals
  --signal output_s: std_logic_vector(bw_output-1 downto 0) := (others=> '0');
  signal output_s : std_logic_vector(63 downto 0) := (others=>'0');
  signal output_clk : std_logic := '0';
  -- ILA
  signal data : std_logic_vector(63 downto 0) := (others=> '0');

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
  data <= output_s;

  -- Simulation process.

  -- Firmware process
  firmware_i: entity work.Firmware
  port map(
            clk40=> sysclk,
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
