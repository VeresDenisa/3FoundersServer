import item_pack::*;

interface control_interface(input bit clock);
  bit [7:0] data;
  bit       data_status;  
  
  clocking driver@(posedge clock);
    output data;
    output data_status;
  endclocking
  
  clocking monitor@(posedge clock);
    input data;
    input data_status;
  endclocking
  
  task send(data_packet packet);
    @(driver);
    driver.data        <= packet.da;
    driver.data_status <= packet.data_status[0];
    
    @(driver);
    driver.data        <= packet.sa;
    driver.data_status <= packet.data_status[1];
    
    @(driver);
    driver.data        <= packet.length;
    driver.data_status <= packet.data_status[2];
    
    foreach(packet.payload[i]) begin
      @(driver);
      driver.data        <= packet.payload[i];
      driver.data_status <= packet.data_status[i+3];
    end
    
    @(driver) driver.data_status <= packet.data_status[packet.length+4];
    
    repeat(packet.delay) @(driver);
  endtask : send
  
  function automatic void receive(ref control_item item);
    item.data        = monitor.data;
    item.data_status = monitor.data_status;
  endfunction : receive
endinterface : control_interface