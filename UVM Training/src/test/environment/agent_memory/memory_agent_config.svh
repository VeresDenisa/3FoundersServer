
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
class memory_agent_config extends base_agent_config;
    function new ( uvm_active_passive_enum is_active );
      super.new(is_active);
    endfunction : new    
endclass : memory_agent_config