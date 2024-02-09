
  import uvm_pkg::*;
  `include "uvm_macros.svh"
 
  import test_pack::*;

module testbench;  
  bit clk;
  
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end
  
  reset_interface   rst_i(clk);
  memory_interface  mem_i(clk);
  control_interface ctrl_i(clk);
  port_interface port_0_i(clk), 
  				 port_1_i(clk),
  				 port_2_i(clk), 
  				 port_3_i(clk);
  
  
  switch DUT(
    .clk(clk),
    .reset(rst_i.reset),
    .data_status(ctrl_i.data_status),
    .data(ctrl_i.data),
    .port0(port_0_i.port),
    .port1(port_1_i.port),
    .port2(port_2_i.port),
    .port3(port_3_i.port),
    .ready_0(port_0_i.ready),
    .ready_1(port_1_i.ready),
    .ready_2(port_2_i.ready),
    .ready_3(port_3_i.ready),
    .read_0(port_0_i.read),
    .read_1(port_1_i.read),
    .read_2(port_2_i.read),
    .read_3(port_3_i.read),
    .mem_en(mem_i.mem_en),
    .mem_rd_wr(mem_i.mem_rd_wr),
    .mem_add(mem_i.mem_add),
    .mem_data(mem_i.mem_data)
  );
  
  initial begin
    uvm_config_db#(virtual reset_interface)::  set(null, "uvm_test_top.env.rst_agent*",  "reset_interface",   rst_i);
    uvm_config_db#(virtual memory_interface):: set(null, "uvm_test_top.env.mem_agent*",  "memory_interface",  mem_i);
    uvm_config_db#(virtual control_interface)::set(null, "uvm_test_top.env.ctrl_agent*", "control_interface", ctrl_i);
    
    uvm_config_db#(virtual port_interface)::set(null, "uvm_test_top.env.port_0_agent*", "port_interface", port_0_i);
    uvm_config_db#(virtual port_interface)::set(null, "uvm_test_top.env.port_1_agent*", "port_interface", port_1_i);
    uvm_config_db#(virtual port_interface)::set(null, "uvm_test_top.env.port_2_agent*", "port_interface", port_2_i);
    uvm_config_db#(virtual port_interface)::set(null, "uvm_test_top.env.port_3_agent*", "port_interface", port_3_i);
  end
  
  initial begin
    run_test();
  end
  
  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
  end
endmodule : testbench