# In the source directory run the below command
# vivado -nojournal -nolog -mode batch -source tb_project_generator.tcl

# Environment variables
set FPGA_TYPE xcku035-ffva1156-1-c

# Generate ip
set argv $FPGA_TYPE
set argc 1
source ip_generator.tcl

# Create project
create_project baseline_project ../baseline_project -part $FPGA_TYPE -force
set_property target_language VHDL [current_project]
set_property target_simulator XSim [current_project]

# Add files
add_files -norecurse "odmb7_ucsb_dev.vhd"
add_files "utils/"
add_files "odmb_ctrl/"
add_files "odmb_vme/"
add_files -fileset constrs_1 -norecurse "constraints_odmb7_ucsb_dev.xdc"
add_files -norecurse "../ip/$FPGA_TYPE/ila/ila.xci ../ip/$FPGA_TYPE/clockManager/clockManager.xci"

# Add tcl for simulation
set_property -name {xsim.simulate.custom_tcl} -value {Firmware_tb.tcl} -objects [get_filesets sim_1]

# add_files -norecurse "../tb_project/cfebjtag_tb_behav.wcfg"
set_property SOURCE_SET sources_1 [get_filesets sim_1]
# set_property xsim.view {my_tb_behav.wcfg my_tb_behav_1.wcfg my_tb_behav_2.wcfg} [get_filesets sim_1]

# Set test bench as top module
set_property top ODMB7_UCSB_DEV [get_filesets sources_1]
set_property top ODMB7_UCSB_DEV [get_filesets sim_1]

# Set ip as global
set_property generate_synth_checkpoint false [get_files  ../ip/$FPGA_TYPE/clockManager/clockManager.xci]
set_property generate_synth_checkpoint false [get_files  ../ip/$FPGA_TYPE/ila/ila.xci]
#set_property generate_synth_checkpoint false [get_files  ../ip/$FPGA_TYPE/lut_input1/lut_input1.xci]
#set_property generate_synth_checkpoint false [get_files  ../ip/$FPGA_TYPE/lut_input2/lut_input2.xci]

puts "\[Success\] Created tb_project"
close_project
