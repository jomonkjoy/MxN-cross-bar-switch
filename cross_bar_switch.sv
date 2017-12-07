module cross_bar_switch #(
  parameter S_MSEL_WIDTH = 3,
  parameter M_MSEL_WIDTH = 1,
  parameter S_CHANNEL_NO = 2**S_MSEL_WIDTH,
  parameter M_CHANNEL_NO = 2**M_MSEL_WIDTH,
  parameter DATA_WIDTH = 32
) (
  input  logic                  aclk,
  input  logic                  areset,
  
  input  logic [DATA_WIDTH-1:0] s_axis_tdata [S_CHANNEL_NO],
  input  logic                  s_axis_tvalid[S_CHANNEL_NO],
  input  logic                  s_axis_tlast [S_CHANNEL_NO],
  output logic                  s_axis_tready[S_CHANNEL_NO],
  
  output logic [DATA_WIDTH-1:0] m_axis_tdata [M_CHANNEL_NO],
  output logic                  m_axis_tvalid[M_CHANNEL_NO],
  output logic                  m_axis_tlast [M_CHANNEL_NO],
  input  logic                  m_axis_tready[M_CHANNEL_NO]
);
  
  logic [DATA_WIDTH-1:0] s_fifo_tdata [M_CHANNEL_NO][S_CHANNEL_NO];
  logic                  s_fifo_tvalid[M_CHANNEL_NO][S_CHANNEL_NO];
  logic                  s_fifo_tlast [M_CHANNEL_NO][S_CHANNEL_NO];
  logic                  s_fifo_tready[M_CHANNEL_NO][S_CHANNEL_NO];
  logic [DATA_WIDTH-1:0] m_fifo_tdata [S_CHANNEL_NO][M_CHANNEL_NO];
  logic                  m_fifo_tvalid[S_CHANNEL_NO][M_CHANNEL_NO];
  logic                  m_fifo_tlast [S_CHANNEL_NO][M_CHANNEL_NO];
  logic                  m_fifo_tready[S_CHANNEL_NO][M_CHANNEL_NO];
  
endmodule
