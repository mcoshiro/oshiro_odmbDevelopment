library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Firmware_pkg.all;

entity Firmware is
  PORT ( CLKIN : in STD_LOGIC;
    INPUT1 : in std_logic_vector(11 downto 0);
    INPUT2 : in std_logic_vector(11 downto 0);
    OUTPUT : out std_logic_vector(19 downto 0)
);
end Firmware;

architecture Behavioral of Firmware is

signal wr_en : std_logic := '0';
signal rd_en : std_logic := '0';
signal din : std_logic_vector(18-1 downto 0) := (others => '0');
signal dout : std_logic_vector(18-1 downto 0) := (others => '0');
signal wr_rst_busy : std_logic := '0';
signal srst : std_logic := '0';
signal prog_full : std_logic := '0';
signal empty : std_logic := '0';
signal half_clk : std_logic := '0';
signal quarter_clk : std_logic := '0';
signal fsm : std_logic_vector(4-1 downto 0) := "0100";
signal pseudorandom_one : integer := 5;
signal pseudorandom_two : integer := 5;
signal init_counter : integer := 0;

component datafifo_dcfeb is
   PORT (
           wr_clk                    : IN  std_logic := '0';
           rd_clk                    : IN  std_logic := '0';
           srst                      : IN  std_logic := '0';
           prog_full                 : OUT std_logic := '0';
           wr_rst_busy               : OUT  std_logic := '0';
           rd_rst_busy               : OUT  std_logic := '0';
           wr_en                     : IN  std_logic := '0';
           rd_en                     : IN  std_logic := '0';
           din                       : IN  std_logic_vector(18-1 DOWNTO 0) := (OTHERS => '0');
           dout                      : OUT std_logic_vector(18-1 DOWNTO 0) := (OTHERS => '0');
           full                      : OUT std_logic := '0';
           empty                     : OUT std_logic := '1');
  end component;
  
begin

   datafifo_dcfeb_pm : datafifo_dcfeb
 PORT MAP (
    wr_clk => CLKIN,
    rd_clk => CLKIN,
    din => din,
    dout => dout,
    wr_en => wr_en,
    rd_en => rd_en,
    wr_rst_busy => wr_rst_busy,
    prog_full => prog_full,
    srst => srst,
    empty => empty
    );

  --fsm independent connections
  --din <= "000000" & INPUT1;
  din <= std_logic_vector(to_unsigned(pseudorandom_one,18));
  OUTPUT <= fsm & dout(15 downto 0);

  --fsm dependent  connections
  wr_en <= CLKIN when fsm="0010" else '0';
  rd_en <= '1' when fsm="0001" else half_clk;
  srst <= '1' when fsm="0000" else '0';

  --fsm logic
  fsm <= "0001" when fsm="0010" and prog_full='1' else
	 "0000" when fsm="0001" and empty='1' else
	 "0011" when fsm="0000" and wr_rst_busy='1' else
	 "0010" when fsm="0011" and wr_rst_busy='0' else
	 "0000" when fsm="0100" and init_counter=15 else
	 fsm;
  
  --generate half_clk and input
  logic: process (CLKIN)
    begin
    if CLKIN'event and CLKIN='1' then
      -- Pipeline 0 (Buffer for input)
      half_clk <= not half_clk;
      init_counter <= init_counter + 1;
      pseudorandom_one <= (pseudorandom_one * 293 + 233) mod 983;
    end if;
  end process;
  
  process (half_clk)
      begin
      if half_clk'event and half_clk='1' then
        -- Pipeline 0 (Buffer for input)
        quarter_clk <= not quarter_clk;
      end if;
    end process;
  
  end Behavioral;

