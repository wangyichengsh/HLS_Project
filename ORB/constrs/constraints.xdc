# 板载时钟 25MHz
set_property PACKAGE_PIN AH16 [get_ports clk_in1_0]
set_property IOSTANDARD LVCMOS33 [get_ports clk_in1_0]
create_clock -period 40.000 -name clk_in1_0 \
    [get_ports clk_in1_0]

# PCIe 参考时钟 sys_clk_0
set_property PACKAGE_PIN AF17 [get_ports sys_clk_0]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk_0]
create_clock -period 10.000 -name sys_clk_0 \
    [get_ports sys_clk_0]

# 复位按钮 reset_rtl_0 (低电平有效)
set_property PACKAGE_PIN Y19 [get_ports reset_rtl_0]
set_property IOSTANDARD LVCMOS33 [get_ports reset_rtl_0]
set_property PULLUP true [get_ports reset_rtl_0]
set_false_path -from [get_ports reset_rtl_0]

# 时钟组约束
set_clock_groups -asynchronous \
    -group [get_clocks clk_in1_0] \
    -group [get_clocks sys_clk_0]

# Bitstream 配置
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CONFIG_MODE SPIx4 [current_design]