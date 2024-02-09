class memory_sequence extends uvm_sequence #(memory_item);
  `uvm_object_utils(memory_sequence)
  
  memory_item item;
  
  int nr_items = 4, addr = 3, no_random = 0;
  
  function new (string name = "memory_sequence");
    super.new(name);
  endfunction : new

  extern function void set_parameters(int nr_items = 4, int addr = 3, int no_random = 0);
    
  extern task body();
endclass : memory_sequence

    
    
function void memory_sequence::set_parameters(int nr_items = 4, int addr = 3, int no_random = 0);
  this.nr_items  = nr_items;
  this.addr      = addr;
  this.no_random = no_random;
endfunction : set_parameters

task memory_sequence::body();
  repeat(nr_items) begin : loop
    item = memory_item::type_id::create("item");
    start_item(item);
    if(no_random !== 0) begin
      assert(item.randomize());
    end
    else begin
      item.set_address(addr);
      item.set_enable();
    end
    finish_item(item);
    
    item = memory_item::type_id::create("item_default");
    start_item(item);
    item.set_enable(0,0);
    finish_item(item);
  end : loop
endtask : body
