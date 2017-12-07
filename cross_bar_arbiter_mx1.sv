module cross_bar_arbiter_mx1 #(
  parameter MSEL_WIDTH = 2,
  parameter CHANNEL_NO = 2**MSEL_WIDTH,
  parameter DATA_WIDTH = 32
) (
  input  logic                  aclk,
  input  logic                  areset,
  
  input  logic [DATA_WIDTH-1:0] s_axis_tdata [CHANNEL_NO],
  input  logic                  s_axis_tvalid[CHANNEL_NO],
  input  logic                  s_axis_tlast [CHANNEL_NO],
  output logic                  s_axis_tready[CHANNEL_NO],
  
  output logic [DATA_WIDTH-1:0] m_axis_tdata,
  output logic                  m_axis_tvalid,
  output logic                  m_axis_tlast,
  input  logic                  m_axis_tready
);
  
  typedef enum {IDLE,ACTIVE}state_type;
  state_type state;
  
  logic [MSEL_WIDTH-1:0] channel_bin;
  logic [CHANNEL_NO-1:0] channel_sel;
  logic [CHANNEL_NO-1:0] channel_sel_valid;
  
  always_ff @(posedge aclk) begin
    if (areset) begin
      state <= IDLE;
      channel_sel <= {{CHANNEL_NO-1{1'b0}},1'b1};
      channel_bin <= {MSEL_WIDTH{1'b0}};
    end else begin
      case (state)
        IDLE : begin
        end
        ACTIVE : begin
        end
        default : begin
          state <= IDLE;
          channel_sel <= {{CHANNEL_NO-1{1'b0}},1'b1};
          channel_bin <= {MSEL_WIDTH{1'b0}};
        end
      endcase
    end
  end
  
endmodule
