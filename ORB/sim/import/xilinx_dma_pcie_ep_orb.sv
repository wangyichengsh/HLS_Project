
//-----------------------------------------------------------------------------
// Based on xilinx_dma_pcie_ep.sv (XDMA v4.1 example design)
// Modified: Replace xdma_app with design_1_wrapper (ORB PCIe project)
//
// DUT: design_1_wrapper
//   Ports:
//     clk_in1_0   - 25MHz board clock (generated internally here)
//     sys_clk_0   - 100MHz PCIe ref clock (from IBUFDS_GTE2)
//     reset_rtl_0 - active-low reset (from sys_rst_n)
//     pcie_7x_mgt_rtl_0_rxp/rxn - PCIe RX serial
//     pcie_7x_mgt_rtl_0_txp/txn - PCIe TX serial
//
// NOTE: design_1_wrapper uses 7-series PCIe IP (xc7k420t) with
//       pcie2_to_pcie3_wrapper inside XDMA for PIPE simulation.
//       The serial TX/RX from the wrapper connect to the same
//       pci_exp_txp/txn ports as the original EP.
//-----------------------------------------------------------------------------
`timescale 1ps / 1ps

module xilinx_dma_pcie_ep_orb #
  (
   parameter PL_LINK_CAP_MAX_LINK_WIDTH = 1,
   parameter PL_SIM_FAST_LINK_TRAINING  = "FALSE",
   parameter PL_LINK_CAP_MAX_LINK_SPEED = 2,          // 2 = GEN2
   parameter C_DATA_WIDTH               = 64,
   parameter EXT_PIPE_SIM               = "FALSE",
   parameter C_ROOT_PORT                = "FALSE",
   parameter C_DEVICE_NUMBER            = 0,
   parameter AXIS_CCIX_RX_TDATA_WIDTH   = 256,
   parameter AXIS_CCIX_TX_TDATA_WIDTH   = 256,
   parameter AXIS_CCIX_RX_TUSER_WIDTH   = 46,
   parameter AXIS_CCIX_TX_TUSER_WIDTH   = 46
   )
   (
    output [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txp,
    output [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txn,
    input  [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_rxp,
    input  [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_rxn,

    // synthesis translate_off
    input  [25:0] common_commands_in,
    input  [83:0] pipe_rx_0_sigs,
    input  [83:0] pipe_rx_1_sigs,
    input  [83:0] pipe_rx_2_sigs,
    input  [83:0] pipe_rx_3_sigs,
    input  [83:0] pipe_rx_4_sigs,
    input  [83:0] pipe_rx_5_sigs,
    input  [83:0] pipe_rx_6_sigs,
    input  [83:0] pipe_rx_7_sigs,
    output [25:0] common_commands_out,
    output [83:0] pipe_tx_0_sigs,
    output [83:0] pipe_tx_1_sigs,
    output [83:0] pipe_tx_2_sigs,
    output [83:0] pipe_tx_3_sigs,
    output [83:0] pipe_tx_4_sigs,
    output [83:0] pipe_tx_5_sigs,
    output [83:0] pipe_tx_6_sigs,
    output [83:0] pipe_tx_7_sigs,
    // synthesis translate_on

    input  sys_clk_p,
    input  sys_clk_n,
    input  sys_rst_n
 );

  //--------------------------------------------------------------------------
  // Clock and reset
  //--------------------------------------------------------------------------
  wire sys_clk;        // 100MHz PCIe ref clock (single-ended, from IBUFDS_GTE2)
  wire sys_rst_n_c;

  // 7-series PCIe ref clock buffer
  IBUFDS_GTE2 refclk_ibuf (
    .O    (sys_clk),
    .ODIV2(),
    .I    (sys_clk_p),
    .CEB  (1'b0),
    .IB   (sys_clk_n)
  );

  IBUF sys_reset_n_ibuf (
    .O(sys_rst_n_c),
    .I(sys_rst_n)
  );

  //--------------------------------------------------------------------------
  // Generate 25MHz board clock for clk_in1_0
  // In simulation this toggles via always block; synthesis uses real source.
  //--------------------------------------------------------------------------
  // synthesis translate_off
  reg clk_25mhz_sim = 0;
  always #20000 clk_25mhz_sim = ~clk_25mhz_sim;  // 20ns half-period = 25MHz (timescale 1ps)
  // synthesis translate_on

  // synthesis translate_off
  wire clk_in1_0_w = clk_25mhz_sim;
  // synthesis translate_on

  //--------------------------------------------------------------------------
  // PIPE simulation signal passthrough
  // design_1_wrapper does NOT expose PIPE bundle ports directly.
  // The PIPE interface lives inside the XDMA IP (pcie2_to_pcie3_wrapper).
  // EXT_PIPE_SIM is set via defparam in board.v:
  //   defparam board.EP.xdma_1_i.inst.xdma_1_pcie2_to_pcie3_wrapper_i...EXT_PIPE_SIM="TRUE"
  // So we just pass through the PIPE signals to the ports for board.v to connect.
  //--------------------------------------------------------------------------
  wire [25:0] common_commands_in_i;
  wire [83:0] pipe_rx_0_sigs_i;
  wire [83:0] pipe_rx_1_sigs_i;
  wire [83:0] pipe_rx_2_sigs_i;
  wire [83:0] pipe_rx_3_sigs_i;
  wire [83:0] pipe_rx_4_sigs_i;
  wire [83:0] pipe_rx_5_sigs_i;
  wire [83:0] pipe_rx_6_sigs_i;
  wire [83:0] pipe_rx_7_sigs_i;
  wire [25:0] common_commands_out_i;
  wire [83:0] pipe_tx_0_sigs_i;
  wire [83:0] pipe_tx_1_sigs_i;
  wire [83:0] pipe_tx_2_sigs_i;
  wire [83:0] pipe_tx_3_sigs_i;
  wire [83:0] pipe_tx_4_sigs_i;
  wire [83:0] pipe_tx_5_sigs_i;
  wire [83:0] pipe_tx_6_sigs_i;
  wire [83:0] pipe_tx_7_sigs_i;

  // synthesis translate_off
  generate if (EXT_PIPE_SIM == "TRUE") begin
    assign common_commands_in_i  = common_commands_in;
    assign pipe_rx_0_sigs_i      = pipe_rx_0_sigs;
    assign pipe_rx_1_sigs_i      = pipe_rx_1_sigs;
    assign pipe_rx_2_sigs_i      = pipe_rx_2_sigs;
    assign pipe_rx_3_sigs_i      = pipe_rx_3_sigs;
    assign pipe_rx_4_sigs_i      = pipe_rx_4_sigs;
    assign pipe_rx_5_sigs_i      = pipe_rx_5_sigs;
    assign pipe_rx_6_sigs_i      = pipe_rx_6_sigs;
    assign pipe_rx_7_sigs_i      = pipe_rx_7_sigs;
    assign common_commands_out   = common_commands_out_i;
    assign pipe_tx_0_sigs        = pipe_tx_0_sigs_i;
    assign pipe_tx_1_sigs        = pipe_tx_1_sigs_i;
    assign pipe_tx_2_sigs        = pipe_tx_2_sigs_i;
    assign pipe_tx_3_sigs        = pipe_tx_3_sigs_i;
    assign pipe_tx_4_sigs        = pipe_tx_4_sigs_i;
    assign pipe_tx_5_sigs        = pipe_tx_5_sigs_i;
    assign pipe_tx_6_sigs        = pipe_tx_6_sigs_i;
    assign pipe_tx_7_sigs        = pipe_tx_7_sigs_i;
  end endgenerate
  // synthesis translate_on

  generate if (EXT_PIPE_SIM == "FALSE") begin
    assign common_commands_in_i  = 26'h0;
    assign pipe_rx_0_sigs_i      = 84'h0;
    assign pipe_rx_1_sigs_i      = 84'h0;
    assign pipe_rx_2_sigs_i      = 84'h0;
    assign pipe_rx_3_sigs_i      = 84'h0;
    assign pipe_rx_4_sigs_i      = 84'h0;
    assign pipe_rx_5_sigs_i      = 84'h0;
    assign pipe_rx_6_sigs_i      = 84'h0;
    assign pipe_rx_7_sigs_i      = 84'h0;
  end endgenerate

  //--------------------------------------------------------------------------
  // DUT: design_1_wrapper
  //   - sys_clk_0    : 100MHz PCIe ref clock
  //   - clk_in1_0    : 25MHz board clock
  //   - reset_rtl_0  : active-low (connected directly to sys_rst_n_c)
  //   - pcie serial  : connect to pci_exp_* ports of this module
  //--------------------------------------------------------------------------
design_1_wrapper dut (
    .clk_in1_0                        (clk_in1_0_w),
    .sys_clk_0                        (sys_clk),
    .reset_rtl_0                      (sys_rst_n_c),
    .pcie_7x_mgt_rtl_0_rxp            (pci_exp_rxp),
    .pcie_7x_mgt_rtl_0_rxn            (pci_exp_rxn),
    .pcie_7x_mgt_rtl_0_txp            (pci_exp_txp),
    .pcie_7x_mgt_rtl_0_txn            (pci_exp_txn),
    // PIPE 接口（注意方向：wrapper的output接EP的tx，wrapper的input接EP的rx）
    .pcie3_ext_pipe_ep_0_commands_in  (common_commands_out_i),  // wrapper output → RP rx
    .pcie3_ext_pipe_ep_0_commands_out (common_commands_in_i),   // wrapper input ← RP tx
    .pcie3_ext_pipe_ep_0_rx_0         (pipe_tx_0_sigs_i),       // wrapper output → RP
    .pcie3_ext_pipe_ep_0_rx_1         (pipe_tx_1_sigs_i),
    .pcie3_ext_pipe_ep_0_rx_2         (pipe_tx_2_sigs_i),
    .pcie3_ext_pipe_ep_0_rx_3         (pipe_tx_3_sigs_i),
    .pcie3_ext_pipe_ep_0_rx_4         (pipe_tx_4_sigs_i),
    .pcie3_ext_pipe_ep_0_rx_5         (pipe_tx_5_sigs_i),
    .pcie3_ext_pipe_ep_0_rx_6         (pipe_tx_6_sigs_i),
    .pcie3_ext_pipe_ep_0_rx_7         (pipe_tx_7_sigs_i),
    .pcie3_ext_pipe_ep_0_tx_0         (pipe_rx_0_sigs_i),       // wrapper input ← RP
    .pcie3_ext_pipe_ep_0_tx_1         (pipe_rx_1_sigs_i),
    .pcie3_ext_pipe_ep_0_tx_2         (pipe_rx_2_sigs_i),
    .pcie3_ext_pipe_ep_0_tx_3         (pipe_rx_3_sigs_i),
    .pcie3_ext_pipe_ep_0_tx_4         (pipe_rx_4_sigs_i),
    .pcie3_ext_pipe_ep_0_tx_5         (pipe_rx_5_sigs_i),
    .pcie3_ext_pipe_ep_0_tx_6         (pipe_rx_6_sigs_i),
    .pcie3_ext_pipe_ep_0_tx_7         (pipe_rx_7_sigs_i)
  );

  //--------------------------------------------------------------------------
  // Expose AXI signals for monitor tasks in pci_exp_usrapp_tx.v
  // (COMPARE_DATA_H2C samples board.EP.m_axi_wvalid etc.)
  // Since design_1_wrapper doesn't expose these, the monitor tasks in
  // pci_exp_usrapp_tx.v that reference board.EP.m_axi_* will not work.
  // Those tasks are only used in stream tests (dma_stream*), not needed
  // for our ORB AXI-MM test. See orb_tb_tests.vh for the actual test flow.
  //--------------------------------------------------------------------------

// ---------------------------------------------------------------
  // Dummy signals required by pci_exp_usrapp_tx.v and sample_tests.vh
  // These reference board.EP.xxx via hierarchical paths.
  // Not connected to anything - only needed for elaborate to pass.
  // ---------------------------------------------------------------
  wire                    user_clk    = 1'b0;
  wire                    user_resetn = 1'b0;
  wire                    user_lnk_up = 1'b0;

  // AXI MM signals (referenced in COMPARE_DATA_H2C task)
  wire [63:0]             m_axi_wdata  = 64'b0;
  wire [7:0]              m_axi_wstrb  = 8'b0;
  wire                    m_axi_wvalid = 1'b0;
  wire                    m_axi_wready = 1'b0;
  wire                    m_axi_wlast  = 1'b0;

  // USR IRQ signals (referenced in sample_tests.vh)
  localparam C_NUM_USR_IRQ = 1;
  reg  [C_NUM_USR_IRQ-1:0] usr_irq_req = 1'b0;
  wire [C_NUM_USR_IRQ-1:0] usr_irq_ack;

endmodule
