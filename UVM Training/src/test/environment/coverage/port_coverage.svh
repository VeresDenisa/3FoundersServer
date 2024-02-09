
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
class port_coverage#(int port_nr = 0) extends uvm_subscriber #(port_item);
  `uvm_component_param_utils(port_coverage#(port_nr));
  
  port_item item;
  
  covergroup port_cvg;
    port_cvp :  coverpoint item.port  { bins value_0_FF[7]  = {0, 85, 170, 255, [1 : 84], [86 : 169], [171 : 254]}; }
    ready_cvp : coverpoint item.ready { bins value_binary[] = {0, 1}; }
    read_cvp :  coverpoint item.read  { bins value_binary[] = {0, 1}; }
    receive_cross : cross  ready_cvp, read_cvp {}
  endgroup : port_cvg

  function new(string name = "port_coverage", uvm_component parent = null);
    super.new(name, parent);
    
    port_cvg = new();
  endfunction : new
  
  extern function void write(port_item t);
endclass : port_coverage


function void port_coverage::write(port_item t);
  item = t;
  port_cvg.sample();
endfunction : write