
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
covergroup control_covergroup (ref control_item item);
  data_cvp :        coverpoint item.data        { bins value_0_FF[7]  = {0, 85, 170, 255, [1 : 84], [86 : 169], [171 : 254]}; }
  data_status_cvp : coverpoint item.data_status { bins value_binary[] = {0, 1}; }
endgroup : control_covergroup