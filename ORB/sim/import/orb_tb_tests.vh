//-----------------------------------------------------------------------------
// orb_tb_tests.vh  (updated)
//
// BAR 布局：
//   BAR0 (xdma_bar=0, M_AXI_LITE):
//     0x0030_0000  AXI DMA 寄存器
//     0x0031_0000  AXI GPIO
//     0x0032_0000  ORB s_axi_control
//
//   BAR2 (索引2, M_AXI_BYPASS):
//     0x0000_0000  BRAM0 图像帧
//     0x0010_0000  BRAM1 Keypoints
//     0x0020_0000  BRAM2 Descriptors
//
// TSK_XDMA_REG_WRITE/READ 使用 xdma_bar (BAR0) 访问控制寄存器
// TSK_TX_MEMORY_WRITE/READ 使用 BAR_INIT_P_BAR[2] 访问 BRAM
//-----------------------------------------------------------------------------

else if (testname == "orb_test") begin

  $display("\n========================================");
  $display("  ORB PCIe 系统仿真开始");
  $display("  图像: 128x128 = 16384 bytes");
  $display("========================================\n");

  $display("[%t] Step1: PCIe 链路已建立 ✓", $realtime);
  $display("  XDMA BAR (控制寄存器): BAR%0d  base=0x%08X",
           board.RP.tx_usrapp.xdma_bar,
           board.RP.tx_usrapp.BAR_INIT_P_BAR[board.RP.tx_usrapp.xdma_bar][31:0]);
  $display("  Bypass BAR (BRAM):     BAR2   base=0x%08X",
           board.RP.tx_usrapp.BAR_INIT_P_BAR[2][31:0]);

  //--------------------------------------------------------------------------
  // Step 2: 写入测试图像到 BRAM0（通过 Bypass BAR2）
  //--------------------------------------------------------------------------
  $display("\n[%t] Step2: 写入测试图像到 BRAM0 (via Bypass BAR2)...", $realtime);

  for (img_i = 0; img_i < 16384; img_i = img_i + 4) begin
    img_r = img_i / 128;
    img_c = img_i % 128;
    board.RP.tx_usrapp.DATA_STORE[0] = (((img_r/32)+((img_c  )/32))%2==0) ? 8'hFF : 8'h00;
    board.RP.tx_usrapp.DATA_STORE[1] = (((img_r/32)+((img_c+1)/32))%2==0) ? 8'hFF : 8'h00;
    board.RP.tx_usrapp.DATA_STORE[2] = (((img_r/32)+((img_c+2)/32))%2==0) ? 8'hFF : 8'h00;
    board.RP.tx_usrapp.DATA_STORE[3] = (((img_r/32)+((img_c+3)/32))%2==0) ? 8'hFF : 8'h00;

    if (board.RP.tx_usrapp.BAR_INIT_P_BAR_ENABLED[2] == 2'b10)
      board.RP.tx_usrapp.TSK_TX_MEMORY_WRITE_32(
        board.RP.tx_usrapp.DEFAULT_TAG, board.RP.tx_usrapp.DEFAULT_TC, 11'd1,
        board.RP.tx_usrapp.BAR_INIT_P_BAR[2][31:0] + img_i,
        4'h0, 4'hF, 1'b0);
    else
      board.RP.tx_usrapp.TSK_TX_MEMORY_WRITE_64(
        board.RP.tx_usrapp.DEFAULT_TAG, board.RP.tx_usrapp.DEFAULT_TC, 11'd1,
        {board.RP.tx_usrapp.BAR_INIT_P_BAR[3][31:0],
         board.RP.tx_usrapp.BAR_INIT_P_BAR[2][31:0] + img_i},
        4'h0, 4'hF, 1'b0);

    board.RP.tx_usrapp.DEFAULT_TAG = board.RP.tx_usrapp.DEFAULT_TAG + 1;
    if ((img_i % (128*4)) == 0)
      $display("  [%t] 写入进度: %0d/16384 ", $realtime, img_i);
  end
  board.RP.tx_usrapp.TSK_TX_CLK_EAT(200);
  $display("[%t] 图像写入完成 ✓", $realtime);

  //--------------------------------------------------------------------------
  // Step 3: 配置 ORB 参数（通过 BAR0 控制寄存器）
  //--------------------------------------------------------------------------
  $display("\n[%t] Step3: 配置 ORB 参数...", $realtime);
  board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(32'h0032_0010, 32'd128, 4'hF); // rows
  board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(32'h0032_0018, 32'd128, 4'hF); // cols
  board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(32'h0032_0020, 32'h0010_0000, 4'hF); // kp addr lo
  board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(32'h0032_0024, 32'h0,         4'hF); // kp addr hi
  board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(32'h0032_002C, 32'h0020_0000, 4'hF); // desc addr lo
  board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(32'h0032_0030, 32'h0,         4'hF); // desc addr hi
  $display("[%t] ORB 参数配置完成 ✓", $realtime);

  //--------------------------------------------------------------------------
  // Step 4: 先启动 ORB，再启动 DMA
  //--------------------------------------------------------------------------
  board.RP.tx_usrapp.TSK_XDMA_REG_READ(32'h0032_0000);
  $display("[%t] Step4: ORB ap_ctrl=0x%08X，写 ap_start...",
           $realtime, board.RP.tx_usrapp.P_READ_DATA);
  board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(32'h0032_0000, 32'h0001, 4'hF);

  //--------------------------------------------------------------------------
  // Step 5: 启动 AXI DMA
  //--------------------------------------------------------------------------
  $display("\n[%t] Step5: 启动 AXI DMA...", $realtime);
  // 1. 先复位 DMA
  board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(32'h0030_0000, 32'h0004, 4'hF); // Reset=1
  board.RP.tx_usrapp.TSK_TX_CLK_EAT(1000); // 等待复位完成
  // 2. 启动 MM2S 引擎
  board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(32'h0030_0000, 32'h0001,      4'hF); // RS=1
  board.RP.tx_usrapp.TSK_TX_CLK_EAT(100);
  board.RP.tx_usrapp.TSK_XDMA_REG_READ(32'h0030_0004);
  $display("DMA MM2S_SR after start = 0x%08X", board.RP.tx_usrapp.P_READ_DATA);
  
  board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(32'h0030_0018, 32'h0000_0000, 4'hF); // SA lo
  board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(32'h0030_001C, 32'h0,         4'hF); // SA hi
  board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(32'h0030_0028, 32'd16384, 4'hF); // LENGTH
  $display("[%t] DMA 已启动 ✓", $realtime);
  
  board.RP.tx_usrapp.TSK_TX_CLK_EAT(50000); // 等 500µs
  board.RP.tx_usrapp.TSK_XDMA_REG_READ(32'h0030_0004);
  $display("MM2S_SR after transfer = 0x%08X", 
         board.RP.tx_usrapp.P_READ_DATA);
  
  //--------------------------------------------------------------------------
  // Step 6: 轮询 ORB ap_done
  //--------------------------------------------------------------------------
  $display("\n[%t] Step6: 等待 ORB 完成...", $realtime);
  orb_timeout = 0;
  orb_status  = 32'h0;
  while (!(orb_status & 32'h4)) begin
    board.RP.tx_usrapp.TSK_TX_CLK_EAT(500000);
    board.RP.tx_usrapp.TSK_XDMA_REG_READ(32'h0032_0000);
    orb_status = board.RP.tx_usrapp.P_READ_DATA;
    orb_timeout = orb_timeout + 1;
    if (orb_timeout % 50 == 0)
      $display("  [%t] 等待中... ap_ctrl=0x%08X (timeout=%0d)",
               $realtime, orb_status, orb_timeout);
    if (orb_timeout > 20) begin
      $display("ERROR: ORB 超时！ap_ctrl=0x%08X", orb_status);
      testError = 1'b1;
      $finish;
    end
  end
  $display("[%t] ORB 完成 ✓ ap_ctrl=0x%08X", $realtime, orb_status);

  //--------------------------------------------------------------------------
  // Step 7: 读特征点数量
  //--------------------------------------------------------------------------
  board.RP.tx_usrapp.TSK_XDMA_REG_READ(32'h0032_0038);
  orb_nkp = board.RP.tx_usrapp.P_READ_DATA;
  $display("[%t] 检测到特征点: %0d", $realtime, orb_nkp);
  if (orb_nkp == 0) begin
    $display("WARNING: 没有检测到特征点");
    testError = 1'b1;
  end else if (orb_nkp > 500) begin
    $display("WARNING: 特征点数量 %0d 超出 MAX_KEYPOINTS(500)", orb_nkp);
    testError = 1'b1;
  end else begin
    $display("  特征点数量正常 ✓");
  end

  //--------------------------------------------------------------------------
  // Step 8: 读前5个 Keypoint（Bypass BAR2 → BRAM1）
  //--------------------------------------------------------------------------
  $display("\n[%t] Step8: 读取前5个特征点...", $realtime);
  for (kp_idx = 0; kp_idx < 5 && kp_idx < orb_nkp; kp_idx = kp_idx + 1) begin

    board.RP.tx_usrapp.P_READ_DATA = 32'hFFFF_FFFF;
    fork
      board.RP.tx_usrapp.TSK_TX_MEMORY_READ_32(
        board.RP.tx_usrapp.DEFAULT_TAG, board.RP.tx_usrapp.DEFAULT_TC, 11'd1,
        board.RP.tx_usrapp.BAR_INIT_P_BAR[2][31:0]
          + 32'h0010_0000 + (kp_idx * 8),
        4'h0, 4'hF);
      board.RP.tx_usrapp.TSK_WAIT_FOR_READ_DATA;
    join
    board.RP.tx_usrapp.DEFAULT_TAG = board.RP.tx_usrapp.DEFAULT_TAG + 1;
    kp_raw[31:0] = board.RP.tx_usrapp.P_READ_DATA;

    board.RP.tx_usrapp.P_READ_DATA = 32'hFFFF_FFFF;
    fork
      board.RP.tx_usrapp.TSK_TX_MEMORY_READ_32(
        board.RP.tx_usrapp.DEFAULT_TAG, board.RP.tx_usrapp.DEFAULT_TC, 11'd1,
        board.RP.tx_usrapp.BAR_INIT_P_BAR[2][31:0]
          + 32'h0010_0000 + (kp_idx * 8) + 4,
        4'h0, 4'hF);
      board.RP.tx_usrapp.TSK_WAIT_FOR_READ_DATA;
    join
    board.RP.tx_usrapp.DEFAULT_TAG = board.RP.tx_usrapp.DEFAULT_TAG + 1;
    kp_raw[63:32] = board.RP.tx_usrapp.P_READ_DATA;

    kp_x     = kp_raw[15:0];
    kp_y     = kp_raw[31:16];
    kp_angle = kp_raw[47:32];
    kp_score = kp_raw[55:48];
    $display("  KP[%0d]: x=%0d y=%0d angle=%0d score=%0d raw=0x%016X",
             kp_idx, kp_x, kp_y, kp_angle, kp_score, kp_raw);
    if (kp_x >= 128 || kp_y >= 128) begin
      $display("  ERROR: KP[%0d] 坐标越界！", kp_idx);
      testError = 1'b1;
    end
  end

  //--------------------------------------------------------------------------
  // Step 9: 验证第一个描述子（Bypass BAR2 → BRAM2）
  //--------------------------------------------------------------------------
  $display("\n[%t] Step9: 验证描述子 (256-bit)...", $realtime);
  nonzero_desc = 0;
  for (desc_idx = 0; desc_idx < 8; desc_idx = desc_idx + 1) begin
    board.RP.tx_usrapp.P_READ_DATA = 32'hFFFF_FFFF;
    fork
      board.RP.tx_usrapp.TSK_TX_MEMORY_READ_32(
        board.RP.tx_usrapp.DEFAULT_TAG, board.RP.tx_usrapp.DEFAULT_TC, 11'd1,
        board.RP.tx_usrapp.BAR_INIT_P_BAR[2][31:0]
          + 32'h0020_0000 + (desc_idx * 4),
        4'h0, 4'hF);
      board.RP.tx_usrapp.TSK_WAIT_FOR_READ_DATA;
    join
    board.RP.tx_usrapp.DEFAULT_TAG = board.RP.tx_usrapp.DEFAULT_TAG + 1;
    desc_word = board.RP.tx_usrapp.P_READ_DATA;
    if (desc_word != 0) nonzero_desc = nonzero_desc + 1;
    $display("  DESC[%0d]: 0x%08X", desc_idx, desc_word);
  end
  if (nonzero_desc == 0 && orb_nkp > 0) begin
    $display("WARNING: 描述子全零");
    testError = 1'b1;
  end else begin
    $display("  描述子非零字段: %0d/8 ✓", nonzero_desc);
  end

  //--------------------------------------------------------------------------
  // 汇总
  //--------------------------------------------------------------------------
  $display("\n========================================");
  $display("  仿真结果汇总");
  $display("========================================");
  $display("  PCIe 链路建立:    ✓");
  $display("  图像写入 BRAM0:   ✓ (16384  bytes)");
  $display("  ORB 处理完成:     ✓");
  $display("  检测特征点数量:   %0d", orb_nkp);
  $display("  描述子非零字段:   %0d/8", nonzero_desc);
  if (testError == 1'b0)
    $display("  总体结果:         PASSED ✓");
  else
    $display("  总体结果:         FAILED ✗");
  $display("  仿真时间:         %0t ps", $realtime);
  $display("========================================\n");

  #10000;
  $finish;

end // orb_test
