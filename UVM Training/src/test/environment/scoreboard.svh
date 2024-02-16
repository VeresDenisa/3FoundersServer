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

  data_packet packet_port_queue[4][$];
  data_packet packet_port_in[4];
  data_packet packet_port_out[4];

  int packet_port_in_position[4];
  int packet_port_out_position[4];
  
  data_packet data_packet_temp[4];
  port_item port_item_temp[4];

  bit [7:0] mem_data[4];
  int port_indexes[$];

  port_item port_prev[4];
  bit status_prev;

  bit port_unknown;
  int port_current;

  int dropped_packet_nr;
  int packet_input_nr[4], packet_output_nr[4], packet_control_nr;
  int packet_match[4], packet_miss[4];
  int miss[4], match[4];
  
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
  
  extern function void make_packet(bit[7:0] data, bit port_in_OR_port_out = 1'b0, int port_ind = 0);
  extern function void end_packet(bit port_in_OR_port_out = 1'b0, int port_ind = 0);
  extern function void make_port_packet(port_item t, int port_ind);
      
endclass : scoreboard




function void scoreboard::build_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("<--- ENTER PHASE: --> BUILD <--"), UVM_DEBUG);
    super.build_phase(phase);
    
    an_port_control = new("an_port_control", this);
    an_port_reset   = new("an_port_reset",   this);
    an_port_memory  = new("an_port_memory",  this);
    
    an_port_port_0 = new("an_port_port_0", this);
    an_port_port_1 = new("an_port_port_1", this);
    an_port_port_2 = new("an_port_port_2", this);
    an_port_port_3 = new("an_port_port_3", this);

    for(int i = 0; i < 4; i++) begin
      mem_data[i] = 8'h00;
      port_prev[i] = new("port_prev");
      port_prev[i].read = 1'b0;
      port_prev[i].ready = 1'b0;  
      packet_port_in[i] = new("packet_port_in");
      packet_port_out[i] = new("packet_port_out");
      port_item_temp[i] = new("port_item_temp");
      packet_port_in_position[i] = 0;
      packet_port_out_position[i] = 0;
      packet_input_nr[i] = 0;
      packet_output_nr[i] = 0;
      packet_control_nr[i] = 0; 
      miss[i] = 0;
      match[i] = 0;
      packet_match[i] = 0;
      packet_miss[i] = 0;
      data_packet_temp[i] = new("data_packet_temp");
    end
    
    port_unknown = 1'b0;
    dropped_packet_nr = 0;
    port_current = 0;
    status_prev = 1'b0; 
  
    `uvm_info(get_name(), $sformatf("---> EXIT PHASE: --> BUILD <--"), UVM_DEBUG);
  endfunction : build_phase
    
    

  function void scoreboard::make_packet(bit[7:0] data, bit port_in_OR_port_out = 1'b0, int port_ind = 0); // port_in = 0; port_out = 1
    if(port_in_OR_port_out === 1'b0) begin: write_input_packet
      case(packet_port_in_position[port_current])
        0: packet_port_in[port_current].da     = data;
        1: packet_port_in[port_current].sa     = data;
        2: packet_port_in[port_current].length = data;
        default: packet_port_in[port_current].payload.push_back(data);
      endcase
      packet_port_in_position[port_current]++;
    end: write_input_packet
    else begin : write_output_packet
      case(packet_port_out_position[port_ind])
        0: packet_port_out[port_ind].da     = data;
        1: packet_port_out[port_ind].sa     = data;
        2: packet_port_out[port_ind].length = data;
        default: packet_port_out[port_ind].payload.push_back(data);
      endcase
      packet_port_out_position[port_ind]++;
    end : write_output_packet
  endfunction : make_packet


  function void scoreboard::end_packet(bit port_in_OR_port_out = 1'b0, int port_ind = 0);
    if(port_in_OR_port_out === 1'b0) begin: write_input_packet
      packet_port_queue[port_current].push_back(packet_port_in[port_current]);
      packet_port_in[port_current].payload.delete();
      packet_port_in_position[port_current] = 0;
    end: write_input_packet
    else begin : write_output_packet
      packet_port_queue[port_current].pop_front();
      packet_port_out[port_ind].payload.delete();
      packet_port_out_position[port_ind] = 0;
    end : write_output_packet
  endfunction : end_packet
    
  
  function void scoreboard::write_control(control_item t);
    `uvm_info(get_name(), $sformatf("Received item : %s ", t.convert2string()), UVM_FULL);
    
    if(t.data_status == 1'b1) begin : data_status_activated
      `uvm_info(get_name(), $sformatf("Data status active."), UVM_DEBUG);
      if(port_unknown !== 1'b0) begin : middle_of_transaction
        `uvm_info(get_name(), $sformatf("Add item to input packet in middle of transaction."), UVM_DEBUG);
        make_packet(t.data);
      end : middle_of_transaction
      else if(port_unknown === 1'b0) begin : choose_port
        `uvm_info(get_name(), $sformatf("Add item to input packet at the beginning of transaction."), UVM_DEBUG);
        port_indexes = mem_data.find_index with (item == t.data);
        if(port_indexes.size() > 0) begin : DA_is_mem
          port_unknown = 1'b1; 
          port_current = port_indexes.pop_front(); 
          make_packet(t.data);
          `uvm_info(get_name(), $sformatf("Memory data and received item match at beginning of transaction."), UVM_DEBUG);
        end : DA_is_mem
        else begin
          dropped_packet_nr++;
          `uvm_info(get_name(), $sformatf("Memory data and received item don't match at beginning of transaction."), UVM_DEBUG);
        end
      end : choose_port 
    end : data_status_activated
    else begin : data_status_deactivated
    `uvm_info(get_name(), $sformatf("Data status inactive."), UVM_DEBUG);
      if(status_prev === 1'b1) begin : save_packet
        `uvm_info(get_name(), $sformatf("End of input transaction. Finish packet."), UVM_DEBUG);
        end_packet();
        port_unknown = 1'b0;
      end : save_packet
    end : data_status_deactivated
    
    status_prev = t.data_status;

  endfunction : write_control
  
  function void scoreboard::write_memory(memory_item t);
    `uvm_info(get_name(), $sformatf("Received item : %s ", t.convert2string()), UVM_FULL);
    if(t.mem_en && t.mem_rd_wr) begin
      `uvm_info(get_name(), $sformatf("Memory data changed."), UVM_DEBUG);
      mem_data[t.mem_add] = t.mem_data;
    end
  endfunction : write_memory
  
  function void scoreboard::write_reset(reset_item t);
    `uvm_info(get_name(), $sformatf("Received reset : %s ", t.convert2string()), UVM_FULL);
    if(t.reset == 1'b0) begin : reset_all
      `uvm_info(get_name(), $sformatf("Reset acivated : %s ", t.convert2string()), UVM_FULL);
      port_unknown = 1'b0;
      for(int i = 0; i < 4; i++) begin
        port_prev[i].read = 1'b0;
        port_prev[i].ready = 1'b0;
        status_prev = 1'b0;
        packet_port_in_position[i] = 0;
        packet_port_out_position[i] = 0;
        packet_port_queue[i].delete();
      end 
      port_current = 0;
    end: reset_all    
  endfunction : write_reset
  
  
  function void scoreboard::make_port_packet(port_item t, int port_ind);
    if(port_prev[port_ind].read == 1'b1 && port_prev[port_ind].ready == 1'b1 && t.ready == 1'b1) begin : read_port
      `uvm_info(get_name(), $sformatf("A valid read was made from port %0d.", port_ind), UVM_DEBUG);

      if(packet_port_queue[port_ind].size >= 0) begin : check_port_queue
        data_packet_temp[port_ind] = packet_port_queue[port_ind].pop_front();

        make_packet(t.port, 1'b1, port_ind);

        if(data_packet_temp[port_ind].payload.size() + 3 <= packet_port_out_position[port_ind]) begin : save_out_packet
          `uvm_info(get_name(), $sformatf("A packet from port %0d was finished.", port_ind), UVM_DEBUG);
          end_packet(1'b1, port_ind);
        end : save_out_packet

        packet_port_queue[port_ind].push_front(data_packet_temp[port_ind]);

      end : check_port_queue
    end : read_port
    port_prev[port_ind].copy(t);
  endfunction : make_port_packet

    
  function void scoreboard::write_port_0(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 0 : %s ", t.convert2string()), UVM_FULL);
    make_port_packet(t, 0);   
  endfunction : write_port_0
  
  function void scoreboard::write_port_1(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 1 : %s ", t.convert2string()), UVM_FULL);
    make_port_packet(t, 1);   
  endfunction : write_port_1
  
  function void scoreboard::write_port_2(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 2 : %s ", t.convert2string()), UVM_FULL);
    make_port_packet(t, 2);   
  endfunction : write_port_2
  
  function void scoreboard::write_port_3(port_item t);
    `uvm_info(this.get_name(), $sformatf("Received item from PORT 3 : %s ", t.convert2string()), UVM_FULL);
    make_port_packet(t, 3);   
  endfunction : write_port_3
  
    
  function void scoreboard::report_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("---> EXIT PHASE: --> REPORT <--"), UVM_MEDIUM);
    `uvm_info(get_name(), $sformatf("<--- EXIT PHASE: --> REPORT <--"), UVM_MEDIUM);
  endfunction : report_phase