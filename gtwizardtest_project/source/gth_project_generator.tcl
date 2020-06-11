# In the source directory run the below command
# vivado -nojournal -nolog -mode batch -source gth_project_generator.tcl

# Environment variables
set FPGA_TYPE xcku040-ffva1156-2-e
#set FPGA_TYPE xcku035-ffva1156-1-c

# Generate ip
set argv $FPGA_TYPE
set argc 1
source ip_generator.tcl

# Create project
create_project gth_project ../gth_project -part $FPGA_TYPE -force
set_property target_language VHDL [current_project]
set_property target_simulator XSim [current_project]

# Add files
add_files -norecurse "Firmware.vhd Firmware_pkg.vhd Firmware_tb.vhd gtwizard_ultrascale_1_example_gtwiz_userclk_tx.v ../ip/$FPGA_TYPE/clockManager/clockManager.xci ../ip/$FPGA_TYPE/ila/ila.xci ../ip/$FPGA_TYPE/lut_input1/lut_input1.xci ../ip/$FPGA_TYPE/lut_input2/lut_input2.xci ../ip/$FPGA_TYPE/gtwizard_test/gtwizard_test.xci ../ip/$FPGA_TYPE/gtwizard_reset_vio/gtwizard_reset_vio.xci"
add_files -fileset constrs_1 -norecurse "Firmware_tb.xdc"

# Add tcl for simulation
set_property -name {xsim.simulate.custom_tcl} -value {../../../../source/Firmware_tb.tcl} -objects [get_filesets sim_1]

# Set ip as global
set_property generate_synth_checkpoint false [get_files  ../ip/$FPGA_TYPE/clockManager/clockManager.xci]
set_property generate_synth_checkpoint false [get_files  ../ip/$FPGA_TYPE/ila/ila.xci]
set_property generate_synth_checkpoint false [get_files  ../ip/$FPGA_TYPE/lut_input1/lut_input1.xci]
set_property generate_synth_checkpoint false [get_files  ../ip/$FPGA_TYPE/lut_input2/lut_input2.xci]
set_property generate_synth_checkpoint false [get_files  ../ip/$FPGA_TYPE/gtwizard_test/gtwizard_test.xci]
set_property generate_synth_checkpoint false [get_files  ../ip/$FPGA_TYPE/gtwizard_reset_vio/gtwizard_reset_vio.xci]

puts "\[Success\] Created gth_project"
close_project
