import item_pack::*;

interface memory_interface(input bit clock);
  logic [7:0] mem_data;
  bit   [1:0] mem_add;
  bit         mem_en;
  bit         mem_rd_wr;
  
  clocking driver@(posedge clock);
    output mem_data;
    output mem_add;
    output mem_en;
    output mem_rd_wr;
  endclocking
  
  clocking monitor@(posedge clock);
    input mem_data;
    input mem_add;
    input mem_en;
    input mem_rd_wr;
  endclocking
  
  task send(memory_item item);
    @(driver);
    driver.mem_rd_wr <= item.mem_rd_wr;
    driver.mem_en    <= item.mem_en;
    driver.mem_data  <= item.mem_data;
    driver.mem_add   <= item.mem_add;
  endtask : send
  
  function automatic void receive(ref memory_item item);
    item.mem_data  = monitor.mem_data;
    item.mem_add   = monitor.mem_add;
    item.mem_en    = monitor.mem_en;
    item.mem_rd_wr = monitor.mem_rd_wr;
  endfunction : receive
endinterface : memory_interface