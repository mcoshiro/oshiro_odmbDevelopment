# In the source directory run the below command
# vivado -nojournal -nolog -mode batch -source ip_adder.tcl

# Set environment variable
set FPGA_TYPE xcku040-ffva1156-2-e

# Open ip project manager
open_project ../ip/$FPGA_TYPE/managed_ip_project/managed_ip_project.xpr

# remove old ila
remove_files ../ip/$FPGA_TYPE/ila/ila.xci
file delete -force ../ip/$FPGA_TYPE/ila

# Create new ila
create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila -dir ../ip/$FPGA_TYPE
set_property -dict [list CONFIG.C_PROBE0_WIDTH {32}] [get_ips ila]

# Close ip project manager
puts "\[Success\] Created ip for $FPGA_TYPE"
close_project
