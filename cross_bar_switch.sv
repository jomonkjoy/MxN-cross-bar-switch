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
  
  genvar i,j;
  generate for (i=0; i<S_CHANNEL_NO; i++) begin : s_loop
    for (j=0; j<M_CHANNEL_NO; j++) begin : m_loop
      assign s_fifo_tdata [j][i] = m_fifo_tdata [i][j];
      assign s_fifo_tlast [j][i] = m_fifo_tlast [i][j];
      assign s_fifo_tvalid[j][i] = m_fifo_tvalid[i][j];
      assign m_fifo_tready[i][j] = s_fifo_tready[j][i];
    end
  end endgenerate
  
  generate for (i=0; i<S_CHANNEL_NO; i++) begin : gen_demux
    cross_bar_demux_buffer #(
      .MSEL_WIDTH (M_MSEL_WIDTH),
      .CHANNEL_NO (M_CHANNEL_NO),
      .DATA_WIDTH (DATA_WIDTH)
    ) cross_bar_demux_buffer_inst (
      .aclk          (aclk),
      .areset        (areset),
      .s_axis_tdata  (s_axis_tdata [i]),
      .s_axis_tvalid (s_axis_tvalid[i]),
      .s_axis_tlast  (s_axis_tlast [i]),
      .s_axis_tready (s_axis_tready[i]),
      .m_axis_tdata  (m_fifo_tdata [i]),
      .m_axis_tvalid (m_fifo_tvalid[i]),
      .m_axis_tlast  (m_fifo_tlast [i]),
      .m_axis_tready (m_fifo_tready[i])
    );
  end endgenerate
  
  generate for (i=0; i<M_CHANNEL_NO; i++) begin : gen_arbiter
    cross_bar_arbiter_mx1 #(
      .MSEL_WIDTH (S_MSEL_WIDTH),
      .CHANNEL_NO (S_CHANNEL_NO),
      .DATA_WIDTH (DATA_WIDTH)
    ) cross_bar_arbiter_mx1_inst (
      .aclk          (aclk),
      .areset        (areset),
      .s_axis_tdata  (s_fifo_tdata [i]),
      .s_axis_tvalid (s_fifo_tvalid[i]),
      .s_axis_tlast  (s_fifo_tlast [i]),
      .s_axis_tready (s_fifo_tready[i]),
      .m_axis_tdata  (m_axis_tdata [i]),
      .m_axis_tvalid (m_axis_tvalid[i]),
      .m_axis_tlast  (m_axis_tlast [i]),
      .m_axis_tready (m_axis_tready[i])
    );
  end endgenerate
  
endmodule
