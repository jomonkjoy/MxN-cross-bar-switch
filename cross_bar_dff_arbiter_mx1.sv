// ARBITER using deficit-Round-Robin sheduling algorithm
module cross_bar_dff_arbiter_mx1 #(
  parameter MSEL_WIDTH = 2,
  parameter CHANNEL_NO = 2**MSEL_WIDTH,
  parameter DATA_WIDTH = 32
) (
  input  logic                  aclk,
  input  logic                  areset,
  
  input  logic [DATA_WIDTH-1:0] s_axis_credit[CHANNEL_NO],
  input  logic [DATA_WIDTH-1:0] s_axis_tdata [CHANNEL_NO],
  input  logic                  s_axis_tvalid[CHANNEL_NO],
  input  logic                  s_axis_tlast [CHANNEL_NO],
  output logic                  s_axis_tready[CHANNEL_NO],
  
  output logic [DATA_WIDTH-1:0] m_axis_tdata,
  output logic                  m_axis_tvalid,
  output logic                  m_axis_tlast,
  input  logic                  m_axis_tready
);
  
  typedef enum logic[1:0] {INIT,IDLE,ACTIVE}state_type;
  state_type state;
  
  logic [MSEL_WIDTH-1:0] channel_bin;
  logic [CHANNEL_NO-1:0] channel_sel;
  logic [CHANNEL_NO-1:0] channel_sel_valid;
  logic [DATA_WIDTH-1:0] deficit_count[CHANNEL_NO];
  
  always_ff @(posedge aclk) begin
    if (areset) begin
      state <= INIT;
      channel_sel <= {{CHANNEL_NO-1{1'b0}},1'b1};
      channel_bin <= {MSEL_WIDTH{1'b0}};
    end else begin
      case (state)
        INIT : begin
          if (channel_bin >= CHANNEL_NO-1) begin
            channel_bin <= {MSEL_WIDTH{1'b0}};
            state <= IDLE;
          end else begin
            channel_bin <= channel_bin + 1;
            deficit_count[channel_bin] <= s_axis_credit[channel_bin];
          end
        end
        IDLE : begin
          if (|channel_sel_valid && deficit_count[channel_bin] >= s_axis_tdata[channel_bin]) begin
            state <= ACTIVE;
            deficit_count[channel_bin] <= deficit_count[channel_bin] - s_axis_tdata[channel_bin];
          end else if (|channel_sel_valid) begin
            channel_sel <= {channel_sel[CHANNEL_NO-2:0],channel_sel[CHANNEL_NO-1]};
            channel_bin <= channel_bin + 1;
          end else begin
            channel_sel <= {channel_sel[CHANNEL_NO-2:0],channel_sel[CHANNEL_NO-1]};
            channel_bin <= channel_bin + 1;
            deficit_count[channel_bin] <= {DATA_WIDTH{1'b0}};
          end
        end
        ACTIVE : begin
          if (m_axis_tvalid && m_axis_tlast && m_axis_tready) begin
            state <= IDLE;
            channel_sel <= {channel_sel[CHANNEL_NO-2:0],channel_sel[CHANNEL_NO-1]};
            channel_bin <= channel_bin + 1;
          end
        end
        default : begin
          state <= INIT;
          channel_sel <= {{CHANNEL_NO-1{1'b0}},1'b1};
          channel_bin <= {MSEL_WIDTH{1'b0}};
        end
      endcase
    end
  end
  
  genvar i;
  generate for (i=0; i<CHANNEL_NO; i++) begin : tready
    assign channel_sel_valid[i] = s_axis_tvalid[i] & channel_sel[i];
    assign s_axis_tready[i] = state == ACTIVE && channel_sel[i] ? m_axis_tready : 1'b0;
  end endgenerate
  
  assign m_axis_tdata  = s_axis_tdata[channel_bin];
  assign m_axis_tlast  = state == ACTIVE ? m_axis_tlast [channel_bin] : 1'b0;
  assign m_axis_tvalid = state == ACTIVE ? m_axis_tvalid[channel_bin] : 1'b0;
  
endmodule
