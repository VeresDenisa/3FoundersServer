
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
typedef enum bit { MEMORY_WRITE  = 1'b1, MEMORY_IDLE  = 1'b0 } memory_write_idle_enum;

class memory_item extends uvm_sequence_item;
  `uvm_object_utils(memory_item);
  
  rand logic [7:0] mem_data;
  rand bit [1:0] mem_add;
       bit       mem_rd_wr;
       bit       mem_en;
  rand memory_write_idle_enum mem_wr_id;
       
  constraint mostly_inactive_mem_wr_id { mem_wr_id dist { 1 := 5, 0 := 95 }; }
  constraint pseudo_random_data        { mem_data  dist {'h00:/10,'h55:/10,'hAA:/10,'hFF:/10,['h01:'h54]:/10,['h56:'hA9]:/10,['hA9:'hFE]:/10}; }
  
  function new(string name = "memory_item");
    super.new(name);
  endfunction : new
  
  extern function void set_data(logic [7:0] mem_data);
  extern function void set_address(bit [1:0] mem_add);
  extern function void set_enable(bit mem_en = 1'b1, bit mem_rd_wr = 1'b1);
    
  extern function void set_item(logic [7:0] mem_data, bit [1:0] mem_add, bit mem_en = 1'b1, bit mem_rd_wr = 1'b1);

  extern function string convert2string();
  extern function bit compare(memory_item item);
  extern function void copy(memory_item item); 
  extern function void post_randomize();  
endclass : memory_item



function void memory_item::post_randomize();
  mem_en = mem_wr_id;
  mem_rd_wr = mem_wr_id;
endfunction : post_randomize
    
function void memory_item::set_data(logic [7:0] mem_data);
  this.mem_data = mem_data;
endfunction : set_data
    
function void memory_item::set_address(bit [1:0] mem_add);
  this.mem_add = mem_add;
endfunction : set_address

function void memory_item::set_enable(bit mem_en = 1'b1, bit mem_rd_wr = 1'b1);
  this.mem_en    = mem_en;
  this.mem_rd_wr = mem_rd_wr;
endfunction : set_enable

function void memory_item::set_item(logic [7:0] mem_data, bit [1:0] mem_add, bit mem_en = 1'b1, bit mem_rd_wr = 1'b1);
  this.set_data(mem_data);
  this.set_address(mem_add);
  this.set_enable(mem_en, mem_rd_wr);
endfunction : set_item

function string memory_item::convert2string();
  return $sformatf("memory_write_idle_enum : %s mem_data: 'h%0h  mem_add: 'h%0h mem_rd_wr: 'b%0h  mem_en: 'b%0h", mem_wr_id, mem_data, mem_add, mem_rd_wr, mem_en);
endfunction : convert2string

function bit memory_item::compare(memory_item item);
  if(this.mem_rd_wr !== item.mem_rd_wr) return 1'b0;
  if(this.mem_data  !== item.mem_data)  return 1'b0;
  if(this.mem_add   !== item.mem_add)   return 1'b0;
  if(this.mem_en    !== item.mem_en)    return 1'b0;
  return 1'b1;
endfunction

function void memory_item::copy(memory_item item);
  this.mem_rd_wr = item.mem_rd_wr;
  this.mem_data  = item.mem_data;
  this.mem_add   = item.mem_add;
  this.mem_en    = item.mem_en;
endfunction
