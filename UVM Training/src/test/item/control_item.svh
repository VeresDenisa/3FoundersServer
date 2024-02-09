
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
class control_item extends uvm_sequence_item;
  `uvm_object_utils(control_item);
  
  rand bit [7:0] data;
  rand bit       data_status;
       
  constraint non_random_data { data  dist {'h00:/10,'h55:/10,'hAA:/10,'hFF:/10,['h01:'h54]:/0,['h56:'hA9]:/0,['hA9:'hFE]:/0}; }
  
  function new(string name = "control_item");
    super.new(name);
  endfunction : new

  extern function string convert2string();
  extern function bit compare(control_item item);
  extern function void copy(control_item item);
endclass : control_item



function string control_item::convert2string();
  return $sformatf("data: 'h%0h  data_satus: 'h%0h", data, data_status);
endfunction : convert2string

function bit control_item::compare(control_item item);
  if(this.data_status !== item.data_status) return 1'b0;
  if(this.data        !== item.data)        return 1'b0;
  return 1'b1;
endfunction

function void control_item::copy(control_item item);
  this.data        = item.data;
  this.data_status = item.data_status;
endfunction
