if { $argc != 1 } {
  puts "\[Error\] Please type in one of the below commands in the source directory"
  puts "vivado -nojournal -nolog -mode batch -source ip_generator.tcl -tclargs xcku040-ffva1156-2-e"
  puts "vivado -nojournal -nolog -mode batch -source ip_generator.tcl -tclargs xcku035-ffva1156-1-c"
} else {
  # Set environment variable
  set FPGA_TYPE [lindex $argv 0] 

  # Create ip project manager
  create_project managed_ip_project ../ip/$FPGA_TYPE/managed_ip_project -part $FPGA_TYPE -ip -force
  set_property target_language VHDL [current_project]
  set_property target_simulator XSim [current_project]
  
  # Create clockManager
  create_ip -name clk_wiz -vendor xilinx.com -library ip -version 5.4 -module_name clockManager -dir ../ip/$FPGA_TYPE
  set_property -dict [list CONFIG.PRIM_IN_FREQ {300} CONFIG.CLKOUT2_USED {true} CONFIG.CLKOUT3_USED {true} CONFIG.PRIMARY_PORT {clk_in300} CONFIG.CLK_OUT1_PORT {clk_out40} CONFIG.CLK_OUT2_PORT {clk_out10} CONFIG.CLK_OUT3_PORT {clk_out80} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {40} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {10} CONFIG.USE_LOCKED {false} CONFIG.USE_RESET {false} CONFIG.CLKIN1_JITTER_PS {33.330000000000005} CONFIG.MMCM_DIVCLK_DIVIDE {3} CONFIG.MMCM_CLKIN1_PERIOD {3.333} CONFIG.MMCM_CLKIN2_PERIOD {10.0} CONFIG.MMCM_CLKOUT0_DIVIDE_F {25.000} CONFIG.MMCM_CLKOUT1_DIVIDE {100} CONFIG.MMCM_CLKOUT2_DIVIDE {10} CONFIG.NUM_OUT_CLKS {3} CONFIG.CLKOUT1_JITTER {155.514} CONFIG.CLKOUT2_JITTER {203.128} CONFIG.CLKOUT2_PHASE_ERROR {98.575} CONFIG.CLKOUT3_JITTER {129.666} CONFIG.CLKOUT3_PHASE_ERROR {98.575} CONFIG.CLKOUT1_DRIVES {BUFG} CONFIG.CLKOUT2_DRIVES {BUFG} CONFIG.CLKOUT3_DRIVES {BUFG} CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} CONFIG.CLKOUT1_MATCHED_ROUTING {true} CONFIG.CLKOUT2_MATCHED_ROUTING {true} CONFIG.CLKOUT3_MATCHED_ROUTING {true} CONFIG.PRIM_SOURCE {No_buffer}] [get_ips clockManager]
  
  # Create ila
  create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila -dir ../ip/$FPGA_TYPE
  set_property -dict [list CONFIG.C_PROBE0_WIDTH {64}] [get_ips ila]

  #create gtwizard_test
  create_ip -name gtwizard_ultrascale -vendor xilinx.com -library ip -version 1.7 -module_name gtwizard_test -dir ../ip/$FPGA_TYPE
  set_property -dict [list CONFIG.CHANNEL_ENABLE {X0Y10 X0Y9} CONFIG.TX_MASTER_CHANNEL {X0Y10} CONFIG.RX_MASTER_CHANNEL {X0Y10} CONFIG.TX_LINE_RATE {10} CONFIG.TX_REFCLK_FREQUENCY {156.25} CONFIG.TX_DATA_ENCODING {8B10B} CONFIG.RX_LINE_RATE {10} CONFIG.RX_REFCLK_FREQUENCY {156.25} CONFIG.RX_DATA_DECODING {8B10B} CONFIG.RX_COMMA_P_ENABLE {true} CONFIG.RX_COMMA_M_ENABLE {true} CONFIG.RX_COMMA_P_VAL {1001111100} CONFIG.RX_COMMA_M_VAL {0110000011} CONFIG.RX_COMMA_ALIGN_WORD {4} CONFIG.RX_REFCLK_SOURCE {X0Y10 clk0+1 X0Y9 clk0+1} CONFIG.TX_REFCLK_SOURCE {X0Y10 clk0+1 X0Y9 clk0+1} CONFIG.FREERUN_FREQUENCY {40} CONFIG.TX_INT_DATA_WIDTH {40} CONFIG.RX_INT_DATA_WIDTH {40} CONFIG.RX_JTOL_FC {5.9988002} CONFIG.RX_COMMA_MASK {1111111111} CONFIG.TXPROGDIV_FREQ_VAL {250}] [get_ips gtwizard_test]

  #create gtwizard_reset_vio
  create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name gtwizard_reset_vio -dir ../ip/$FPGA_TYPE
  set_property -dict [list CONFIG.C_NUM_PROBE_OUT {3} CONFIG.C_EN_PROBE_IN_ACTIVITY {1} CONFIG.C_NUM_PROBE_IN {4}] [get_ips gtwizard_reset_vio]

  puts "\[Success\] Created ip for $FPGA_TYPE"
  close_project
}
