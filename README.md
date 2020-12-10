# oshiro_odmbDevelopment

This repository contains various firmware development projects for 
the ODMB7 (see http://hep.ucsb.edu/cms/odmb/; currently not up to date).
The project files can be generated using the (tb\_)project\_generator.tcl
files and implemented in Vivado (tested with 2017.2 and 2019.2).

##datafifo_project

This folder contains some firmware for testing the behavior of the the Vivado 
FIFO generator IP Core in various edge cases and strange situations. It is
targeted for the KCU 105 evaluation board.

##gtwizardtest_projecct

This contains some very simply firmware for testing the behavior of the the 
Vivado GT wizard IP Core. It is targeted for the KCU105 evaluation board.

##odmb7_vme_baseline

This folder contains firmware that can be used to perform basic tests of VME
communication and JTAG communication with (x)DCFEBs. It is targeted for the
ODMB7 pre-production board.

