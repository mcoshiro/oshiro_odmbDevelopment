# In the source directory run the below command
# vivado -nojournal -nolog -mode batch -source project_generator.tcl

# Environment variables
set FPGA_TYPE xcku035-ffva1156-1-c

# Create project
create_project project ../project -part $FPGA_TYPE
set_property target_language VHDL [current_project]
set_property target_simulator XSim [current_project]

# Add files
add_files -norecurse {Firmware.vhd Firmware_pkg.vhd}
