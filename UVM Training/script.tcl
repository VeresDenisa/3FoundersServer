#!/usr/bin/tclsh

# run from terminal with: ./script.tcl testcase1 testcase2 etc.

# set the testcases names to check
set testlist {test test_no_1 test_no_2 test_no_4 test_no_5 test_no_6 test_no_7 test_no_8 test_no_9 test_no_11 test_no_12}

puts "Number of testcases found: $argc" 

# variable to memorise the testcase number
set i 1

# go to throu each testcase given as argument
foreach {test} $argv {
 
     # check if the test exists in the list
     if { [lsearch $testlist $test] >= 0 } {

          # make a ran tests list if it is the first testcase or append to the ran tests list otherwise; use the path to the ucdb file
          if { [info exists runtests] } {
               lappend runtests "ucdb/ucdb_$test.ucdb"
          } else {
               set runtests "ucdb/ucdb_$test.ucdb"
          }

          puts "Start testing testcase $i..." 
          puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] $test: Testcase found. Executing..."  

          # compile in the order specified by files.f
          exec sh -c "vlog -work work -f files.f"

          puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] $test: Compilation success. Running ..."
          
          # create the specified directories if they don't exist
          if { ![file exists ucdb] } { file mkdir ucdb }
          if { ![file exists log] } { file mkdir log }
          if { ![file exists coverage_report] } { file mkdir coverage_report }

          # simulate the testcase and save the ucdb file
          exec sh -c "vsim -c -classdebug -voptargs=\"+acc\" +UVM_TESTNAME=$test +UVM_VERBOSITY=LOW work.testbench -do \"coverage save -onexit ucdb/ucdb_$test.ucdb; run -all; quit -f; exit\""        

          # copy the transcipt file which contains the entire simulation as a log file
          file copy -force transcript log/transcript_$test.log

          puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] $test: Transcript saved."

          # save the coverage report as a text file
          exec sh -c "vsim -c -viewcov ucdb/ucdb_$test.ucdb -do \"coverage report -file coverage_report/coverage_report_$test.txt -byfile -detail -noannotate -option -cvg; quit -f; exit\""

          puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] $test: Coverage saved."

          puts "Testcase $i done. Closing..." 

     } else { puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] Testcase $i $test not found! Testcase skipped!" }
     incr i 1
}

# check whether there were any ran testcases
if { [info exists runtests] } {
     puts "[llength $runtests] successful ran testcases."

     # if there is only one testcase there is no need to combine multiple coverage reports into one
     if { [llength $runtests] > 1 } {
          puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] Combine coverage reports..."

          # combine the coverage reports
          exec sh -c "vcover merge ucdb/ucdb_final.ucdb $runtests"
         
          puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] Finished coverage merge. Saving..."

          # save the coverage report as a txt file
          exec sh -c "vsim -c -viewcov ucdb/ucdb_final.ucdb -do \"coverage report -file coverage_report/coverage_report_final.txt -byfile -detail -noannotate -option -cvg; quit -f; exit\""

          puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] Saved final coverage report."

     } else { puts "One successfull testcase run. No coverage merge necessary." }
}