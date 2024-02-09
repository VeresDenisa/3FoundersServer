`uvm_analysis_imp_decl(_control)
`uvm_analysis_imp_decl(_memory)
`uvm_analysis_imp_decl(_reset)
`uvm_analysis_imp_decl(_port_0)
`uvm_analysis_imp_decl(_port_1)
`uvm_analysis_imp_decl(_port_2)
`uvm_analysis_imp_decl(_port_3)

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard);
  
  uvm_analysis_imp_control #(control_item, scoreboard) an_port_control;
  uvm_analysis_imp_reset   #(reset_item,   scoreboard) an_port_reset;
  uvm_analysis_imp_memory  #(memory_item,  scoreboard) an_port_memory;
  
  uvm_analysis_imp_port_0#(port_item, scoreboard) an_port_port_0; 
  uvm_analysis_imp_port_1#(port_item, scoreboard) an_port_port_1; 
  uvm_analysis_imp_port_2#(port_item, scoreboard) an_port_port_2; 
  uvm_analysis_imp_port_3#(port_item, scoreboard) an_port_port_3; 
  
  data_packet data_pck_queue[5][$];
  data_packet data_pck[5];
  int position[5], finished[5];
  
  bit [7:0]port_queue[4][$];
  bit [7:0]  mem_data[4];
  
  int port_indexes[$];
  bit [7:0] port_item_compare;
  port_item port_prev[4];
  
  bit port_unknown;
  int port_current;
  
  int dropped_packet_nr;
  int packet_nr[9];
  int miss, match;
  
  function new (string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  extern function void build_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);
    
  extern function void write_control(control_item t);
  extern function void write_reset(reset_item t);
  extern function void write_memory(memory_item t);
    
  extern function void write_port_0(port_item t);
  extern function void write_port_1(port_item t);
  extern function void write_port_2(port_item t);
  extern function void write_port_3(port_item t);
  
  extern function void compare_port(port_item t, int i);
  extern function void make_packet(bit[7:0] data, int queue_nr);
    
endclass : scoreboard




function void scoreboard::build_phase(uvm_phase phase);
    `uvm_info(this.get_name(), $sformatf("<--- ENTER PHASE: --> BUILD <--"), UVM_DEBUG);
    super.build_phase(phase);
    
    an_port_control = new("an_port_control", this);
    an_port_reset   = new("an_port_reset",   this);
    an_port_memory  = new("an_port_memory",  this);
    
    an_port_port_0 = new("an_port_port_0", this);
    an_port_port_1 = new("an_port_port_1", this);
    an_port_port_2 = new("an_port_port_2", this);
    an_port_port_3 = new("an_port_port_3", this);
    
    foreach(mem_data[i]) begin
      mem_data[i] = 8'h00;
      port_prev[i] = new("port_prev");
      port_prev[i].read = 1'b0;
      port_prev[i].ready = 1'b0;      
    end
  
  for(int i=0;i<9;i++) packet_nr[i] = 0;
  
  foreach(data_pck[i]) begin
    data_pck[i] = new("data_packet");
    position[i] = 0;
    finished[i] = 0;
  end
    
    port_unknown = 1'b0;
    
    dropped_packet_nr = 0;
  
    miss  = 0;
    match = 0;
  
    `uvm_info(this.get_name(), $sformatf("---> EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
  endfunction : build_phase
    
    
  function void scoreboard::make_packet(bit[7:0] data, int queue_nr);
    case(position[queue_nr%5])
      0: data_pck[queue_nr%5].da     = data;
      1: data_pck[queue_nr%5].sa     = data;
      2: data_pck[queue_nr%5].length = data;
      default: data_pck[queue_nr%5].payload.push_back(data);
    endcase
    position[queue_nr]++;
    if(position[queue_nr%5] > 2) begin
      if(data_pck[queue_nr%5].length == data_pck[queue_nr%5].payload.size()) begin
        data_pck_queue[queue_nr%5].push_back(data_pck[queue_nr%5]);
        data_pck[queue_nr%5].payload.delete();
        position[queue_nr%5] = 0;
        finished[queue_nr%5] = 1;
        
        if(queue_nr >= 5)
          packet_nr[queue_nr]++;
        else begin
          packet_nr[port_current+1]++;
          packet_nr[queue_nr]++;
        end
        `uvm_info(this.get_name(), $sformatf("Finished receiving packet %Od for port %0d", packet_nr[queue_nr], queue_nr>=5?queue_nr%5:queue_nr-1), UVM_MEDIUM);
      end
    end
  endfunction : make_packet
    
  
  function void scoreboard::write_control(control_item t);
    `uvm_info(this.get_name(), $sformatf("Received item : %s ", t.convert2string()), UVM_FULL);
    
    if(t.data_status == 1'b1) begin : data_status_activated
      if(port_unknown !== 1'b0) begin : middle_of_transaction
        port_queue[port_current].push_back(t.data);
        make_packet(t.data, 0);
        if(finished[0] === 1) begin
          `uvm_info(this.get_name(), $sformatf("Finished receiving packet!"), UVM_MEDIUM);
          finished[0] = 0;
        end
      end : middle_of_transaction
      else if(port_unknown === 1'b0) begin : choose_port
        port_indexes = mem_data.find_index with (item == t.data);
        if(port_indexes.size() > 0) begin : DA_is_mem
          port_unknown = 1'b1; 
          port_current = port_indexes.pop_front(); 
          port_queue[port_current].push_back(t.data);
          make_packet(t.data, 0);
        end : DA_is_mem
        else dropped_packet_nr++;
      end : choose_port 
    end : data_status_activated
    else begin : data_status_deactivated
      port_unknown = 1'b0;
      position[0] = 0;
    end : data_status_deactivated
    
  endfunction : write_control
  
  function void scoreboard::write_memory(memory_item t);
    `uvm_info(this.get_name(), $sformatf("Received item : %s ", t.convert2string()), UVM_FULL);
    if(t.mem_en && t.mem_rd_wr) begin
      mem_data[t.mem_add] = t.mem_data;
    end
  endfunction : write_memory
  
  function void scoreboard::write_reset(reset_item t);
    `uvm_info(this.get_name(), $sformatf("Received reset : %s ", t.convert2string()), UVM_FULL);
    if(t.reset == 1'b0) begin : reset_all
      `uvm_info(this.get_name(), $sformatf("Reset acivated : %s ", t.convert2string()), UVM_FULL);
      port_unknown = 1'b0;
      foreach(port_queue[i])
        port_queue[i].delete();
      for(int i = 0; i < 5; i++) begin
        position[i] = 0;
        finished[i] = 0;
      end
    end : reset_all
    
  endfunction : write_reset
  
    
  function void scoreboard::compare_port(port_item t, int i);
    if(port_prev[i].read == 1'b1 && port_prev[i].ready == 1'b1 && t.ready == 1'b1) begin : read_port
      port_item_compare = port_queue[i].pop_front();
      make_packet(t.port, i+5);
      if(t.port == port_item_compare) begin : matched_read_port
        `uvm_info(this.get_name(), $sformatf("--- MATCH ---"), UVM_DEBUG);
        match++;
      end : matched_read_port
      else begin : missmatched_read_port
        `uvm_info(this.get_name(), $sformatf("--- MISS - PORT %0d ---", i), UVM_MEDIUM);
        miss++;
        port_queue[i].push_front(port_item_compare);
      end : missmatched_read_port
    end : read_port
    port_prev[i].copy(t);
    if(finished[i+1] == 1) begin end
    
  endfunction : compare_port
  
    
  function void scoreboard::write_port_0(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 0 : %s ", t.convert2string()), UVM_FULL);
    compare_port(t, 0);   
  endfunction : write_port_0
  
  function void scoreboard::write_port_1(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 1 : %s ", t.convert2string()), UVM_FULL);
    compare_port(t, 1);   
  endfunction : write_port_1
  
  function void scoreboard::write_port_2(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 2 : %s ", t.convert2string()), UVM_FULL);
    compare_port(t, 2);   
  endfunction : write_port_2
  
  function void scoreboard::write_port_3(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 3 : %s ", t.convert2string()), UVM_FULL);
    compare_port(t, 3);   
  endfunction : write_port_3
  
    
  function void scoreboard::report_phase(uvm_phase phase);
    `uvm_info(this.get_name(), $sformatf("---> EXIT PHASE: --> REPORT <--"), UVM_DEBUG);
    `uvm_info(this.get_name(), $sformatf("BYTE MATCH / TOTAL : %0d / %0d", match, (miss + match)), UVM_LOW);
    `uvm_info(this.get_name(), $sformatf("BYTE FAIL : %0d%%", (miss*100/(miss + match))), UVM_LOW);
    `uvm_info(this.get_name(), $sformatf("CORRECT PACKETS : %0d", packet_nr[0]), UVM_LOW);
    `uvm_info(this.get_name(), $sformatf("DROPPED PACKETS : %0d", dropped_packet_nr), UVM_LOW);
    for(int i = 0; i< 4; i++) begin
      `uvm_info(this.get_name(), $sformatf("PORT %0d: INPUT PACKETS: %0d ; OUTPUT PACKETS : %0d", i, packet_nr[i+1], packet_nr[i+5]), UVM_LOW);
    end
    `uvm_info(this.get_name(), $sformatf("<--- EXIT PHASE: --> REPORT <--"), UVM_DEBUG);
  endfunction : report_phase