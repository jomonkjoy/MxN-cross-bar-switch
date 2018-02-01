
module cross_bar_switch_top #(
  parameter RX_MSEL_WIDTH = 3,
  parameter TX_MSEL_WIDTH = 1,
  parameter RX_CHANNEL_NO = 2**RX_MSEL_WIDTH,
  parameter TX_CHANNEL_NO = 2**TX_MSEL_WIDTH,
  parameter DATA_WIDTH = 32
) (
  input  logic                  aclk,
  input  logic                  areset,
  
  input  logic [DATA_WIDTH-1:0] tx_s_axis_tdata [TX_CHANNEL_NO],
  input  logic                  tx_s_axis_tvalid[TX_CHANNEL_NO],
  input  logic                  tx_s_axis_tlast [TX_CHANNEL_NO],
  output logic                  tx_s_axis_tready[TX_CHANNEL_NO],
  output logic [DATA_WIDTH-1:0] tx_m_axis_tdata [TX_CHANNEL_NO],
  output logic                  tx_m_axis_tvalid[TX_CHANNEL_NO],
  output logic                  tx_m_axis_tlast [TX_CHANNEL_NO],
  input  logic                  tx_m_axis_tready[TX_CHANNEL_NO],
  
  input  logic [DATA_WIDTH-1:0] rx_s_axis_tdata [RX_CHANNEL_NO],
  input  logic                  rx_s_axis_tvalid[RX_CHANNEL_NO],
  input  logic                  rx_s_axis_tlast [RX_CHANNEL_NO],
  output logic                  rx_s_axis_tready[RX_CHANNEL_NO],
  output logic [DATA_WIDTH-1:0] rx_m_axis_tdata [RX_CHANNEL_NO],
  output logic                  rx_m_axis_tvalid[RX_CHANNEL_NO],
  output logic                  rx_m_axis_tlast [RX_CHANNEL_NO],
  input  logic                  rx_m_axis_tready[RX_CHANNEL_NO]
);
  
  cross_bar_switch #(
    .S_MSEL_WIDTH (RX_MSEL_WIDTH),
    .M_MSEL_WIDTH (TX_MSEL_WIDTH),
    .S_CHANNEL_NO (RX_CHANNEL_NO),
    .M_CHANNEL_NO (TX_CHANNEL_NO),
    .DATA_WIDTH   (DATA_WIDTH)
  ) cross_bar_switch_rx2tx_inst (
    .aclk          (aclk),
    .areset        (areset),
    .s_axis_tdata  (rx_s_axis_tdata ),
    .s_axis_tvalid (rx_s_axis_tvalid),
    .s_axis_tlast  (rx_s_axis_tlast ),
    .s_axis_tready (rx_s_axis_tready),
    .m_axis_tdata  (tx_m_axis_tdata ),
    .m_axis_tvalid (tx_m_axis_tvalid),
    .m_axis_tlast  (tx_m_axis_tlast ),
    .m_axis_tready (tx_m_axis_tready)
  );
  
  cross_bar_switch #(
    .S_MSEL_WIDTH (TX_MSEL_WIDTH),
    .M_MSEL_WIDTH (RX_MSEL_WIDTH),
    .S_CHANNEL_NO (TX_CHANNEL_NO),
    .M_CHANNEL_NO (RX_CHANNEL_NO),
    .DATA_WIDTH   (DATA_WIDTH)
  ) cross_bar_switch_tx2rx_inst (
    .aclk          (aclk),
    .areset        (areset),
    .s_axis_tdata  (tx_s_axis_tdata ),
    .s_axis_tvalid (tx_s_axis_tvalid),
    .s_axis_tlast  (tx_s_axis_tlast ),
    .s_axis_tready (tx_s_axis_tready),
    .m_axis_tdata  (rx_m_axis_tdata ),
    .m_axis_tvalid (rx_m_axis_tvalid),
    .m_axis_tlast  (rx_m_axis_tlast ),
    .m_axis_tready (rx_m_axis_tready)
  );
  
endmodule
