package seq_pack;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import item_pack::*;

  `include "control_sequence.svh"
  `include "memory_sequence.svh"
  `include "reset_sequence.svh"
  `include "port_sequence.svh"
endpackage : seq_pack;