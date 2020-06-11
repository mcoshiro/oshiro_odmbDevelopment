set_property package_pin P5 [get_ports mgtrefclk0_x0y3_n]
set_property package_pin P6 [get_ports mgtrefclk0_x0y3_p]

set_property LOC AK17 [get_ports CLK_IN_P]
set_property IOSTANDARD  DIFF_SSTL12 [get_ports CLK_IN_P]
set_property ODT         RTT_48 [get_ports CLK_IN_P]

set_property LOC AK16 [get_ports CLK_IN_N]
set_property IOSTANDARD  DIFF_SSTL12 [get_ports CLK_IN_N]
set_property ODT         RTT_48 [get_ports CLK_IN_N]

set_property LOC H27 [get_ports J36_USER_SMA_GPIO_P]
set_property IOSTANDARD  LVCMOS18 [get_ports J36_USER_SMA_GPIO_P]

# Constrain only P side of the clock: https://www.xilinx.com/support/answers/57109.html
create_clock -period 3.333 -name clk_in [get_ports CLK_IN_P]
set_input_jitter [get_clocks -of_objects [get_ports CLK_IN_P]] 0.033330000000000005
create_clock -name clk_mgtrefclk0_x0y3_p -period 6.4 [get_ports mgtrefclk0_x0y3_p]
#create_clock -name rxoutclk_out [get_ports firmware_i/my_gtwiz_test/rxoutclk_out[1]]
#create_clock -name txoutclk_out [get_ports firmware_i/my_gtwiz_test/txoutclk_out[1]]

# get_ports vs get_pins: https://electronics.stackexchange.com/questions/339401/get-ports-vs-get-pins-vs-get-nets-vs-get-registers
# To match timing from same source clock: https://forums.xilinx.com/t5/Timing-Analysis/CLOCK-DELAY-GROUP-doesn-t-seem-to-be-working/td-p/899055

#false paths
#set_false_path -from [get_pins firmware_i/gtwiz_userclk_rx_reset_int*] -quiet
#set_false_path -from [get_pins firmware_i/gtwiz_userclk_tx_reset_int*] -quiet
set_false_path -to [get_cells -hierarchical -filter {NAME =~ *firmware_i/*gtwiz_userclk_rx_active_*_reg}] -quiet
set_false_path -to [get_cells -hierarchical -filter {NAME =~ *firmware_i/*gtwiz_userclk_tx_active_*_reg}] -quiet
#set_false_path -to [get_cells firmware_i/bufg_gt_rx_usrclk_inst]
set_false_path -through [get_pins firmware_i/gth_vio_i/probe_in*] -quiet
set_false_path -through [get_pins firmware_i/gth_vio_i/probe_out*] -quiet
set_false_path -to firmware_i/vio_reset_tx_done_meta_reg/D -quiet
set_false_path -to firmware_i/vio_reset_rx_done_meta_reg/D -quiet

#set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets firmware_i/tx_clrsync]
#set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets firmware_i/tx_cesync]

#remove dont touch so vivado can put in BUFG_GT_SYNC
set_property DONT_TOUCH false [get_cells firmware_i]
#set_property DONT_TOUCH false [get_cells firmware_i/bufg_gt_rx_usrclk_inst]
#set_property DONT_TOUCH false [get_cells firmware_i/bufg_gt_tx_usrclk_inst]
set_property DONT_TOUCH false [get_cells firmware_i/gtwiz_userclk_tx_inst]
set_property DONT_TOUCH false [get_cells firmware_i/gtwiz_userclk_rx_inst]