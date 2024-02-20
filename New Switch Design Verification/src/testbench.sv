parameter NUM_OF_PORTS = 4;
parameter FIFO_SIZE = 64;
parameter WORD_WIDTH = 8;

module testbench;  
  bit clk, rst_n;
  
  bit [WORD_WIDTH-1:0] data_in;
  bit sw_enable_in;

  bit [NUM_OF_PORTS-1:0] port_read;
  
  bit mem_sel_en, mem_wr_rd_s;
  bit [WORD_WIDTH-1:0] mem_addr;
  bit [WORD_WIDTH-1:0] mem_wr_data; 

  bit read_out;
  bit [(NUM_OF_PORTS*WORD_WIDTH)-1:0] port_out;
  bit [NUM_OF_PORTS-1:0] port_ready;
  bit [WORD_WIDTH-1:0] mem_rd_data;
  bit mem_ack;

  // CLOCK //
  initial begin
    clk = 1'b1;
    forever begin 
      #5 clk = ~clk;
      $display("Clock change!");
    end
  end
  
  // RESET //
  initial begin
    rst_n = 1'b1;
    #10 rst_n = 1'b0;
    $display("Reset activated!");
    #10 rst_n = 1'b1;
    $display("Reset deactivated!");
  end
  
  initial begin
    port_read[0] = 1'b0;
  end
  
  // INPUT //
  initial begin
    sw_enable_in = 1'b0;
    data_in      = 8'h00;
    
    #60 sw_enable_in = 1'b1;
    data_in = 8'h44;
    
    #10 port_read[0] = 1'b1;
    
    #10 sw_enable_in = 1'b0;
    data_in = 8'h00;
    
    #10 port_read[0] = 1'b0;
  end
  
  // MEMORY //
  initial begin
    mem_sel_en  = 1'b0;
    mem_wr_rd_s = 1'b0;
    
    mem_addr    = 8'h00;
    mem_wr_data = 8'h00;

    #30;
    mem_sel_en  = 1'b1;
    mem_wr_rd_s = 1'b1;
    
    mem_addr    = 8'h00;
    mem_wr_data = 8'h44;

    $display("Configure memory!");

    #10 mem_sel_en = 1'b0;
  end
  
  switch_top DUT(
    .clk(clk),
    .rst_n(rst_n),
    .sw_enable_in(sw_enable_in),
    .read_out(read_out),
    .data_in(data_in),
    .port_out(port_out),
    .port_ready(port_ready),
    .port_read(port_read),
    .mem_sel_en(mem_sel_en),
    .mem_wr_rd_s(mem_wr_rd_s),
    .mem_addr(mem_addr),
    .mem_wr_data(mem_wr_data),
    .mem_rd_data(mem_rd_data),
    .mem_ack(mem_ack)
  );

  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
  end
  
  initial begin
    #200 $finish();
  end
endmodule : testbench