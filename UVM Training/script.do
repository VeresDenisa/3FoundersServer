vlog -work work -f files.f
vsim -c -classdebug -voptargs="+acc" +UVM_TESTNAME=test_no_11 +UVM_VERBOSITY=LOW work.testbench -do "coverage save -onexit saved.ucdb; run -all; quit -f; exit"
vsim -c -viewcov saved.ucdb -do "coverage report -file coverage_report/coverage_report_test_no_11.txt -byfile -detail -noannotate -option -cvg; quit -f; exit"
