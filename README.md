# 3FoundersServer

Contains everything found on my account.

Content:
- UVM Training : The UVM training using the Simple Switch Design.
- terminal info : Shortcuts and information about useful terminal commands.
- vsim info : Commands and information about vsim.

</br>

UVM Training content:
- scr : source files including: packages, testbench, tests, environment, agents, scoreboard, coverage. [sv, svh]
- coverage reports : contains the individual and the combined reports of the tests. [txt]
- log : contains the transcript file of each individual test. [log]
- wave : contains the waveform data of the simulation of each individual test. [wlf]
- files : the compilation order of the simulation. [f]
- script : the script for running the tests. [tcl]

To run the simulation you need the scr folder, the script.tcl and files.f files and the design.
The design can be found at: ... .

To run the script use: ./scipt.tcl UVM_VERBOSITY TESTCASE1 TESTCASE2 TESTCASE3 (ex. ./scipt.tcl LOW test_no_4 test)

To view the waveform open the GUI, open the wlf file and add the required items in the waveform. To save an image of the waveform, zoom full and export as png/bmp.