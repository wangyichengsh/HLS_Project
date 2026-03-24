
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2024.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7k420tffg901-2L
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:xdma:4.1\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:axi_dma:7.1\
xilinx.com:hls:orb_extract:1.0\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:util_vector_logic:2.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set pcie_7x_mgt_rtl_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x_mgt_rtl_0 ]

  set pcie3_ext_pipe_ep_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_ext_pipe_rtl:1.0 pcie3_ext_pipe_ep_0 ]


  # Create ports
  set reset_rtl_0 [ create_bd_port -dir I -type rst reset_rtl_0 ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset_rtl_0
  set clk_in1_0 [ create_bd_port -dir I -type clk -freq_hz 25000000 clk_in1_0 ]
  set sys_clk_0 [ create_bd_port -dir I -type clk sys_clk_0 ]

  # Create instance: xdma_0, and set properties
  set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_0 ]
  set_property -dict [list \
    CONFIG.axi_data_width {64_bit} \
    CONFIG.axil_master_64bit_en {false} \
    CONFIG.axilite_master_en {true} \
    CONFIG.axilite_master_scale {Megabytes} \
    CONFIG.axilite_master_size {8} \
    CONFIG.axist_bypass_en {true} \
    CONFIG.axisten_freq {125} \
    CONFIG.pciebar2axibar_axil_master {0x00000000} \
    CONFIG.pipe_sim {true} \
    CONFIG.pl_link_cap_max_link_speed {5.0_GT/s} \
    CONFIG.xdma_axi_intf_mm {AXI_Memory_Mapped} \
  ] $xdma_0


  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {2} \
    CONFIG.NUM_MI {6} \
    CONFIG.NUM_SI {6} \
  ] $smartconnect_0


  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
  set_property CONFIG.SINGLE_PORT_BRAM {1} $axi_bram_ctrl_0


  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [list \
    CONFIG.Memory_Type {Single_Port_RAM} \
    CONFIG.Write_Width_A {32} \
    CONFIG.use_bram_block {BRAM_Controller} \
  ] $blk_mem_gen_0


  # Create instance: blk_mem_gen_1, and set properties
  set blk_mem_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_1 ]
  set_property -dict [list \
    CONFIG.Memory_Type {Single_Port_RAM} \
    CONFIG.Operating_Mode_A {WRITE_FIRST} \
    CONFIG.Read_Width_A {64} \
    CONFIG.Write_Width_A {64} \
    CONFIG.use_bram_block {BRAM_Controller} \
  ] $blk_mem_gen_1


  # Create instance: axi_bram_ctrl_1, and set properties
  set axi_bram_ctrl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_1 ]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {64} \
    CONFIG.SINGLE_PORT_BRAM {1} \
  ] $axi_bram_ctrl_1


  # Create instance: axi_bram_ctrl_2, and set properties
  set axi_bram_ctrl_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_2 ]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {256} \
    CONFIG.SINGLE_PORT_BRAM {1} \
  ] $axi_bram_ctrl_2


  # Create instance: blk_mem_gen_2, and set properties
  set blk_mem_gen_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_2 ]
  set_property -dict [list \
    CONFIG.Memory_Type {Single_Port_RAM} \
    CONFIG.Read_Width_A {256} \
    CONFIG.Write_Width_A {256} \
    CONFIG.use_bram_block {BRAM_Controller} \
  ] $blk_mem_gen_2


  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [list \
    CONFIG.c_addr_width {64} \
    CONFIG.c_include_s2mm {0} \
    CONFIG.c_include_sg {0} \
    CONFIG.c_m_axi_mm2s_data_width {64} \
    CONFIG.c_m_axis_mm2s_tdata_width {8} \
    CONFIG.c_mm2s_burst_size {256} \
    CONFIG.c_sg_length_width {23} \
  ] $axi_dma_0


  # Create instance: orb_extract_0, and set properties
  set orb_extract_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:orb_extract:1.0 orb_extract_0 ]

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS {1} \
    CONFIG.C_GPIO_WIDTH {2} \
    CONFIG.C_INTERRUPT_PRESENT {1} \
    CONFIG.C_IS_DUAL {0} \
  ] $axi_gpio_0


  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [list \
    CONFIG.CLKIN1_JITTER_PS {400.0} \
    CONFIG.CLKOUT1_JITTER {226.965} \
    CONFIG.CLKOUT1_PHASE_ERROR {237.727} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {40.000} \
    CONFIG.MMCM_CLKIN1_PERIOD {40.000} \
    CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
    CONFIG.PRIM_IN_FREQ {25.000} \
  ] $clk_wiz_0


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]

  # Create instance: inverter_0, and set properties
  set inverter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 inverter_0 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $inverter_0


  # Create instance: and_orb_rst, and set properties
  set and_orb_rst [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 and_orb_rst ]
  set_property -dict [list \
    CONFIG.C_OPERATION {and} \
    CONFIG.C_SIZE {1} \
  ] $and_orb_rst


  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_1_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_1/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_2_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_2/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_2/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins orb_extract_0/image_in]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins smartconnect_0/S03_AXI]
  connect_bd_intf_net -intf_net orb_extract_0_m_axi_DESC_BUS [get_bd_intf_pins orb_extract_0/m_axi_DESC_BUS] [get_bd_intf_pins smartconnect_0/S05_AXI]
  connect_bd_intf_net -intf_net orb_extract_0_m_axi_KP_BUS [get_bd_intf_pins orb_extract_0/m_axi_KP_BUS] [get_bd_intf_pins smartconnect_0/S02_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins axi_bram_ctrl_1/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins smartconnect_0/M02_AXI] [get_bd_intf_pins axi_bram_ctrl_2/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins smartconnect_0/M03_AXI] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net smartconnect_0_M04_AXI [get_bd_intf_pins smartconnect_0/M04_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M05_AXI [get_bd_intf_pins smartconnect_0/M05_AXI] [get_bd_intf_pins orb_extract_0/s_axi_control]
  connect_bd_intf_net -intf_net xdma_0_M_AXI [get_bd_intf_pins xdma_0/M_AXI] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_BYPASS [get_bd_intf_pins xdma_0/M_AXI_LITE] [get_bd_intf_pins smartconnect_0/S01_AXI]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_BYPASS1 [get_bd_intf_pins xdma_0/M_AXI_BYPASS] [get_bd_intf_pins smartconnect_0/S04_AXI]
  connect_bd_intf_net -intf_net xdma_0_pcie3_ext_pipe_ep [get_bd_intf_ports pcie3_ext_pipe_ep_0] [get_bd_intf_pins xdma_0/pcie3_ext_pipe_ep]
  connect_bd_intf_net -intf_net xdma_0_pcie_mgt [get_bd_intf_ports pcie_7x_mgt_rtl_0] [get_bd_intf_pins xdma_0/pcie_mgt]

  # Create port connections
  connect_bd_net -net and_orb_rst_Res  [get_bd_pins and_orb_rst/Res] \
  [get_bd_pins orb_extract_0/ap_rst_n]
  connect_bd_net -net axi_dma_0_mm2s_introut  [get_bd_pins axi_dma_0/mm2s_introut] \
  [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net axi_dma_0_mm2s_prmry_reset_out_n  [get_bd_pins axi_dma_0/mm2s_prmry_reset_out_n] \
  [get_bd_pins and_orb_rst/Op2]
  connect_bd_net -net clk_in1_0_1  [get_bd_ports clk_in1_0] \
  [get_bd_pins clk_wiz_0/clk_in1]
  connect_bd_net -net clk_wiz_0_clk_out1  [get_bd_pins clk_wiz_0/clk_out1] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] \
  [get_bd_pins smartconnect_0/aclk] \
  [get_bd_pins proc_sys_reset_0/slowest_sync_clk] \
  [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] \
  [get_bd_pins axi_bram_ctrl_2/s_axi_aclk] \
  [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] \
  [get_bd_pins axi_dma_0/s_axi_lite_aclk] \
  [get_bd_pins axi_gpio_0/s_axi_aclk] \
  [get_bd_pins orb_extract_0/ap_clk]
  connect_bd_net -net clk_wiz_0_locked  [get_bd_pins clk_wiz_0/locked] \
  [get_bd_pins proc_sys_reset_0/dcm_locked]
  connect_bd_net -net inverter_0_Res  [get_bd_pins inverter_0/Res] \
  [get_bd_pins clk_wiz_0/reset]
  connect_bd_net -net orb_extract_0_interrupt  [get_bd_pins orb_extract_0/interrupt] \
  [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins proc_sys_reset_0/peripheral_aresetn] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] \
  [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] \
  [get_bd_pins axi_bram_ctrl_2/s_axi_aresetn] \
  [get_bd_pins axi_dma_0/axi_resetn] \
  [get_bd_pins axi_gpio_0/s_axi_aresetn] \
  [get_bd_pins smartconnect_0/aresetn] \
  [get_bd_pins and_orb_rst/Op1]
  connect_bd_net -net reset_rtl_0_1  [get_bd_ports reset_rtl_0] \
  [get_bd_pins xdma_0/sys_rst_n] \
  [get_bd_pins inverter_0/Op1]
  connect_bd_net -net sys_clk_0_1  [get_bd_ports sys_clk_0] \
  [get_bd_pins xdma_0/sys_clk]
  connect_bd_net -net xdma_0_axi_aclk  [get_bd_pins xdma_0/axi_aclk] \
  [get_bd_pins smartconnect_0/aclk1]
  connect_bd_net -net xdma_0_axi_aresetn  [get_bd_pins xdma_0/axi_aresetn] \
  [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net xlconcat_0_dout  [get_bd_pins xlconcat_0/dout] \
  [get_bd_pins axi_gpio_0/gpio_io_i]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x00100000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_BYPASS] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_BYPASS] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_BYPASS] [get_bd_addr_segs axi_bram_ctrl_2/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x00310000 -range 0x00001000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x00320000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs orb_extract_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x00100000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces orb_extract_0/Data_m_axi_DESC_BUS] [get_bd_addr_segs axi_bram_ctrl_2/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces orb_extract_0/Data_m_axi_KP_BUS] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -offset 0x00100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0]
  exclude_bd_addr_seg -offset 0x00200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs axi_bram_ctrl_2/S_AXI/Mem0]
  exclude_bd_addr_seg -offset 0x00300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg]
  exclude_bd_addr_seg -offset 0x00310000 -range 0x00001000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x00320000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs orb_extract_0/s_axi_control/Reg]
  exclude_bd_addr_seg -offset 0x00000000 -range 0x00100000 -target_address_space [get_bd_addr_spaces orb_extract_0/Data_m_axi_DESC_BUS] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0]
  exclude_bd_addr_seg -offset 0x00100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces orb_extract_0/Data_m_axi_DESC_BUS] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0]
  exclude_bd_addr_seg -offset 0x00300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces orb_extract_0/Data_m_axi_DESC_BUS] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg]
  exclude_bd_addr_seg -offset 0x00310000 -range 0x00001000 -target_address_space [get_bd_addr_spaces orb_extract_0/Data_m_axi_DESC_BUS] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x00320000 -range 0x00010000 -target_address_space [get_bd_addr_spaces orb_extract_0/Data_m_axi_DESC_BUS] [get_bd_addr_segs orb_extract_0/s_axi_control/Reg]
  exclude_bd_addr_seg -offset 0x00000000 -range 0x00100000 -target_address_space [get_bd_addr_spaces orb_extract_0/Data_m_axi_KP_BUS] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0]
  exclude_bd_addr_seg -offset 0x00200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces orb_extract_0/Data_m_axi_KP_BUS] [get_bd_addr_segs axi_bram_ctrl_2/S_AXI/Mem0]
  exclude_bd_addr_seg -offset 0x00300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces orb_extract_0/Data_m_axi_KP_BUS] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg]
  exclude_bd_addr_seg -offset 0x00310000 -range 0x00001000 -target_address_space [get_bd_addr_spaces orb_extract_0/Data_m_axi_KP_BUS] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x00320000 -range 0x00010000 -target_address_space [get_bd_addr_spaces orb_extract_0/Data_m_axi_KP_BUS] [get_bd_addr_segs orb_extract_0/s_axi_control/Reg]
  exclude_bd_addr_seg -offset 0x00000000 -range 0x00100000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0]
  exclude_bd_addr_seg -offset 0x00100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0]
  exclude_bd_addr_seg -offset 0x00200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs axi_bram_ctrl_2/S_AXI/Mem0]
  exclude_bd_addr_seg -offset 0x00300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg]
  exclude_bd_addr_seg -offset 0x00310000 -range 0x00001000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x00320000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs orb_extract_0/s_axi_control/Reg]
  exclude_bd_addr_seg -offset 0x00300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_BYPASS] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg]
  exclude_bd_addr_seg -offset 0x00310000 -range 0x00001000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_BYPASS] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x00320000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_BYPASS] [get_bd_addr_segs orb_extract_0/s_axi_control/Reg]
  exclude_bd_addr_seg -offset 0x00000000 -range 0x00100000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0]
  exclude_bd_addr_seg -offset 0x00100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0]
  exclude_bd_addr_seg -offset 0x00200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs axi_bram_ctrl_2/S_AXI/Mem0]


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


