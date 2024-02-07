package config_pack;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import base_pack::*;

  `include "environment_config.svh"
  
  `include "reset_agent_config.svh"
  `include "memory_agent_config.svh"
  `include "control_agent_config.svh"
  `include "port_agent_config.svh"
endpackage : config_pack;