#!/usr/bin/tclsh

set testlist {test test_no_1 test_no_2 test_no_3 test_no_4 test_no_5 test_no_6 test_no_7 test_no_8 test_no_9 test_no_10 test_no_11 test_no_12}

puts "Number of testcases found: $argc" 

set i 1

foreach {test} $argv {

     if { [lsearch $testlist $test] >= 0 } {

          puts "Start testing testcase $i..." 

          puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] $test: Testcase found. Executing..."  


          set scriptfile [open "script.do" w+]

          puts $scriptfile "vlog -work work -f files.f"

          close $scriptfile

          exec "./script.do"

          puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] $test: Compilation success. Running ..."


          set scriptfile [open "script.do" w+]

          puts $scriptfile "vsim -c -classdebug -voptargs=\"+acc\" +UVM_TESTNAME=$test +UVM_VERBOSITY=LOW work.testbench -do \"coverage save -onexit saved.ucdb; run -all; quit -f; exit\""
          
          close $scriptfile

          exec "./script.do"


          file copy -force transcript log/transcript_$test.log

          puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] $test: Transcript saved."


          set scriptfile [open "script.do" w+]
          
          puts $scriptfile "vsim -c -viewcov saved.ucdb -do \"coverage report -file coverage_report/coverage_report_$test.txt -byfile -detail -noannotate -option -cvg; quit -f; exit\""
         
          close $scriptfile

          exec "./script.do"

          puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] $test: Coverage saved."


          puts "Testcase $i done. Closing..." 

     } else { puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] Testcase $i $test not found! Testcase skipped!" }
     incr i 1
}
