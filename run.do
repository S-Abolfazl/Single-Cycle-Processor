vlog -reportprogress 300 -work work mips_core.v 
vlog -reportprogress 300 -work work mips_core_tb.v 
vsim -gui -voptargs=+acc work.mips_core_tb
do wave.do
run 500ns 




