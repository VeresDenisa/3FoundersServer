covergroup event_covergroup (ref port_item port_itm_1, ref port_item port_itm_2, ref port_item port_itm_3, ref port_item port_itm_4, ref control_item control_itm, ref memory_item memory_itm);
  ready_1_cvp : coverpoint port_itm_1.ready { bins value_binary[] = {0, 1}; option.weight = 0; }
  ready_2_cvp : coverpoint port_itm_2.ready { bins value_binary[] = {0, 1}; option.weight = 0; }
  ready_3_cvp : coverpoint port_itm_3.ready { bins value_binary[] = {0, 1}; option.weight = 0; }
  ready_4_cvp : coverpoint port_itm_4.ready { bins value_binary[] = {0, 1}; option.weight = 0; }
  
  read_1_cvp  : coverpoint port_itm_1.read  { bins value_binary[] = {0, 1}; option.weight = 0; }
  read_2_cvp  : coverpoint port_itm_2.read  { bins value_binary[] = {0, 1}; option.weight = 0; }
  read_3_cvp  : coverpoint port_itm_3.read  { bins value_binary[] = {0, 1}; option.weight = 0; }
  read_4_cvp  : coverpoint port_itm_4.read  { bins value_binary[] = {0, 1}; option.weight = 0; }
  
  data_status_cvp : coverpoint control_itm.data_status { bins value_binary[] = {0, 1}; option.weight = 0; }
  
  mem_en_cvp :    coverpoint memory_itm.mem_en    { bins value_binary[] = {0, 1}; option.weight = 0; }
  mem_rd_wr_cvp : coverpoint memory_itm.mem_rd_wr { bins value_binary[] = {0, 1}; option.weight = 0; }
  
  control_memory_cross : cross mem_en_cvp, mem_rd_wr_cvp, data_status_cvp { option.weight = 1; }
  
  ports_cross : cross read_1_cvp, read_2_cvp, read_3_cvp, read_4_cvp, ready_1_cvp, ready_2_cvp, ready_3_cvp, ready_4_cvp { option.weight = 1; }
  
  port_1_memory_cross  : cross read_1_cvp, ready_1_cvp, mem_en_cvp, mem_rd_wr_cvp { option.weight = 1; }
  port_2_memory_cross  : cross read_2_cvp, ready_2_cvp, mem_en_cvp, mem_rd_wr_cvp { option.weight = 1; }
  port_3_memory_cross  : cross read_3_cvp, ready_3_cvp, mem_en_cvp, mem_rd_wr_cvp { option.weight = 1; }
  port_4_memory_cross  : cross read_4_cvp, ready_4_cvp, mem_en_cvp, mem_rd_wr_cvp { option.weight = 1; }
  
  port_1_control_cross : cross read_1_cvp, ready_1_cvp, data_status_cvp { option.weight = 1; }
  port_2_control_cross : cross read_2_cvp, ready_2_cvp, data_status_cvp { option.weight = 1; }
  port_3_control_cross : cross read_3_cvp, ready_3_cvp, data_status_cvp { option.weight = 1; }
  port_4_control_cross : cross read_4_cvp, ready_4_cvp, data_status_cvp { option.weight = 1; }
endgroup : event_covergroup