quit -sim 
vlog -f files.f
vsim -classdebug -voptargs="+acc" +UVM_TESTNAME=test_no_7 +UVM_VERBOSITY=HIGH work.testbench -do "add wave -r /*" -do "run -all" -do "coverage report"
