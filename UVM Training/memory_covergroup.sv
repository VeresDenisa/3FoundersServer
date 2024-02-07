
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
covergroup memory_covergroup (ref memory_item item);
  mem_data_cvp :  coverpoint item.mem_data  { bins value_0_FF[]   = {0, 85, 170, 255}; }
  mem_add_cvp :   coverpoint item.mem_add   { bins value_0_4[]    = {0, 1, 2, 3}; }
  mem_en_cvp :    coverpoint item.mem_en    { bins value_binary[] = {0, 1}; }
  mem_rd_wr_cvp : coverpoint item.mem_rd_wr { bins value_binary[] = {0, 1}; }
  data_cross :    cross      mem_data_cvp, mem_add_cvp {}
  save_cross :    cross      mem_en_cvp, mem_rd_wr_cvp {}
endgroup : memory_covergroup