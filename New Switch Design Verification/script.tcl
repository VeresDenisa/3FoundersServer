#!/usr/bin/tclsh

puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] Testbench found. Executing..."  

# compile in the order specified by files.f
exec sh -c "vlog -f files.f"

puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] Compilation success. Running ..."

# simulate the testcase and save the ucdb and wlf file
exec sh -c "vsim -c -classdebug -voptargs=\"+acc\" work.testbench -do \"run -all; quit -f; exit\""      

# copy the transcipt file which contains the entire simulation as a log file
file copy -force transcript transcript.log

puts "[clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"] Transcript saved."