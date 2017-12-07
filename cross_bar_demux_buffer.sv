module cross_bar_demux_buffer #(
  parameter MSEL_WIDTH = 2,
  parameter CHANNEL_NO = 2**MSEL_WIDTH,
  parameter DATA_WIDTH = 32
) (
  input  logic                  aclk,
  input  logic                  areset,
  
  input  logic [DATA_WIDTH-1:0] s_axis_tdata,
  input  logic                  s_axis_tvalid,
  input  logic                  s_axis_tlast,
  output logic                  s_axis_tready,
  
  output logic [DATA_WIDTH-1:0] m_axis_tdata [CHANNEL_NO],
  output logic                  m_axis_tvalid[CHANNEL_NO],
  output logic                  m_axis_tlast [CHANNEL_NO],
  input  logic                  m_axis_tready[CHANNEL_NO]
);
  
  typedef enum {IDLE,ACTIVE}state_type;
  state_type state;
  
  logic [DATA_WIDTH-1:0] s_fifo_tdata [CHANNEL_NO];
  logic                  s_fifo_tvalid[CHANNEL_NO];
  logic                  s_fifo_tlast [CHANNEL_NO];
  logic                  s_fifo_tready[CHANNEL_NO];
  
  logic [MSEL_WIDTH-1:0] channel_bin;
  logic [CHANNEL_NO-1:0] channel_sel;
  // constraint : first-byte of packet is destination port/channel
  always_ff @(posedge aclk) begin
    if (areset) begin
      state <= IDLE;
      channel_sel <= {CHANNEL_NO{1'b0}};
      channel_bin <= {MSEL_WIDTH{1'b0}};
    end else begin
      case (state)
        IDLE : begin
          if (s_axis_tvalid) begin
            state <= ACTIVE;
            channel_sel <= 1 << s_axis_tdata[MSEL_WIDTH-1:0];
            channel_bin <= s_axis_tdata[MSEL_WIDTH-1:0];
          end
        end
        ACTIVE : begin
          if (s_axis_tvalid && s_axis_tlast && s_axis_tready) begin
            state <= IDLE;
            channel_sel <= {CHANNEL_NO{1'b0}};
            channel_bin <= {MSEL_WIDTH{1'b0}};
          end
        end
        default : begin
          state <= IDLE;
          channel_sel <= {CHANNEL_NO{1'b0}};
          channel_bin <= {MSEL_WIDTH{1'b0}};
        end
      endcase
    end
  end
  
  genvar i;
  generate for (i=0; i<CHANNEL_NO; i++) begin : tready
    assign s_fifo_tdata [i] = s_axis_tdata;
    assign s_fifo_tlast [i] = channel_sel[i] ? s_axis_tlast  : 1'b0;
    assign s_fifo_tvalid[i] = channel_sel[i] ? s_axis_tvalid : 1'b0;
    
    axis_buffer #(
      .ADDR_WIDTH (5),
      .DATA_WIDTH (DATA_WIDTH)
    ) axis_buffer_inst (
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
  
  assign s_axis_tready = state == ACTIVE ? s_fifo_tready[channel_bin] : 1'b0;
  
endmodule
