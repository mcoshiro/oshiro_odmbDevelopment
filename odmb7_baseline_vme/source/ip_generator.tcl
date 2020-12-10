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

  #create ila
  create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila -dir ../ip/$FPGA_TYPE
  set_property -dict [list CONFIG.C_PROBE0_WIDTH {128} CONFIG.C_DATA_DEPTH {8192} CONFIG.Component_Name {ila}] [get_ips ila]

  #create clockManager
  create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clockManager -dir ../ip/$FPGA_TYPE
  set_property -dict [list CONFIG.Component_Name {clockManager} CONFIG.USE_PHASE_ALIGNMENT {true} CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} CONFIG.PRIM_IN_FREQ {40.000} CONFIG.CLKOUT2_USED {true} CONFIG.CLKOUT3_USED {true} CONFIG.CLKOUT4_USED {true} CONFIG.CLKOUT5_USED {true} CONFIG.CLK_OUT1_PORT {clk_out160} CONFIG.CLK_OUT2_PORT {clk_out80} CONFIG.CLK_OUT3_PORT {clk_out40} CONFIG.CLK_OUT4_PORT {clk_out20} CONFIG.CLK_OUT5_PORT {clk_out10} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {160.000} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {80.000} CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {40.000} CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {20.000} CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {10.000} CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} CONFIG.CLKIN1_JITTER_PS {250.0} CONFIG.CLKOUT1_DRIVES {Buffer} CONFIG.CLKOUT2_DRIVES {Buffer} CONFIG.CLKOUT3_DRIVES {Buffer} CONFIG.CLKOUT4_DRIVES {Buffer} CONFIG.CLKOUT5_DRIVES {Buffer} CONFIG.CLKOUT6_DRIVES {Buffer} CONFIG.CLKOUT7_DRIVES {Buffer} CONFIG.MMCM_CLKFBOUT_MULT_F {24.000} CONFIG.MMCM_CLKIN1_PERIOD {25.000} CONFIG.MMCM_CLKIN2_PERIOD {10.0} CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.000} CONFIG.MMCM_CLKOUT1_DIVIDE {12} CONFIG.MMCM_CLKOUT2_DIVIDE {24} CONFIG.MMCM_CLKOUT3_DIVIDE {48} CONFIG.MMCM_CLKOUT4_DIVIDE {96} CONFIG.NUM_OUT_CLKS {5} CONFIG.CLKOUT1_JITTER {169.111} CONFIG.CLKOUT1_PHASE_ERROR {196.976} CONFIG.CLKOUT2_JITTER {200.412} CONFIG.CLKOUT2_PHASE_ERROR {196.976} CONFIG.CLKOUT3_JITTER {247.096} CONFIG.CLKOUT3_PHASE_ERROR {196.976} CONFIG.CLKOUT4_JITTER {298.160} CONFIG.CLKOUT4_PHASE_ERROR {196.976} CONFIG.CLKOUT5_JITTER {342.201} CONFIG.CLKOUT5_PHASE_ERROR {196.976}] [get_ips clockManager]

  puts "\[Success\] Created ip for $FPGA_TYPE"
  close_project
}
