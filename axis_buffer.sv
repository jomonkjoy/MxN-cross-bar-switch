module axis_buffer #(
  parameter ADDR_WIDTH = 4,
  parameter DATA_WIDTH = 8
  ) (
  input  logic                  aclk,
  input  logic                  areset,
  
  input  logic [DATA_WIDTH-1:0] s_axis_tdata,
  input  logic                  s_axis_tvalid,
  input  logic                  s_axis_tlast,
  output logic                  s_axis_tready,
  
  output logic [DATA_WIDTH-1:0] m_axis_tdata,
  output logic                  m_axis_tvalid,
  output logic                  m_axis_tlast,
  input  logic                  m_axis_tready
  );
  
  localparam DATA_DEPTH = 2**ADDR_WIDTH;
  logic [DATA_WIDTH:0] mem [0:DATA_DEPTH-1];
  
  logic [ADDR_WIDTH-0:0] rd_address;
  logic [ADDR_WIDTH-0:0] wr_address;
  // memory address generation
  always_ff @(posedge aclk) begin
    if (areset) begin
      wr_address <= {ADDR_WIDTH+1{1'b0}};
    end else if (s_axis_tvalid && s_axis_tready) begin
      wr_address <= wr_address + 1;
    end
  end
  always_ff @(posedge aclk) begin
    if (areset) begin
      rd_address <= {ADDR_WIDTH+1{1'b0}};
    end else if (m_axis_tvalid && m_axis_tready) begin
      rd_address <= rd_address + 1;
    end
  end
  // memory write logic
  always_ff @(posedge aclk) begin
    if (s_axis_tvalid && s_axis_tready) begin
      mem[wr_address] <= {s_axis_tlast,s_axis_tdata};
    end
  end
  // memory read logic
  assign m_axis_tdata = mem[rd_address][DATA_WIDTH-1:0];
  assing m_axis_tlast = mem[rd_address][DATA_WIDTH];
  // generate slave tready based on fifo-full
  always_ff @(posedge aclk) begin
    if (areset) begin
      s_axis_tready <= 1'b0;
    end else begin
      s_axis_tready <= !({~wr_address[ADDR_WIDTH],wr_address[ADDR_WIDTH-1:0]} == rd_address);
    end
  end
  // generate master tvalid based on fifo-empty
  assign m_axis_tvalid = !(wr_address == rd_address);
  
endmodule
