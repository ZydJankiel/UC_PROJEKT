set project UC_PROJEKT
set top_module main
set target xc7a35tcpg236-1
set bitstream_file build/${project}.runs/impl_1/${top_module}.bit

proc usage {} {
    puts "usage: vivado -mode tcl -source [info script] -tclargs open"
    exit 1
}

if {($argc != 1) || ([lindex $argv 0] ni {"open" })} {
    usage
}

file mkdir vivado
create_project ${project} vivado -part ${target} -force


read_xdc {
    src/constraints/main.xdc
    src/constraints/clk_wiz_0.xdc
    src/constraints/clk_wiz_0_board.xdc
    src/constraints/clk_wiz_0_ooc.xdc
    src/constraints/clk_wiz_0_late.xdc
}

read_verilog {
    src/rtl/main.v
    src/rtl/clk_wiz_0.v
    src/rtl/clk_wiz_0_clk_wiz.v
    src/rtl/clk_locked_menager.v
    src/rtl/vga_timing.v
    src/rtl/draw_background.v
    src/rtl/pillars_obstacle.v
    src/rtl/obstacle1.v
    src/rtl/delay.v
    src/rtl/mouse_constrainer.v
    src/rtl/hp_control.v
    src/rtl/colision_detector.v
    src/rtl/obstacle_mux_16to1.v
    src/rtl/font_rom.v
    src/rtl/char_rom_16x16.v
    src/rtl/multi_char_rom_16x16.v
    src/rtl/menu_char_rom_16x16.v
    src/rtl/draw_rect_char.v
    src/rtl/list_ch04_11_mod_m_counter.v
    src/rtl/list_ch04_20_fifo.v
    src/rtl/list_ch08_01_uart_rx.v
    src/rtl/list_ch08_03_uart_tx.v
    src/rtl/list_ch08_04_uart.v
    src/rtl/list_ch04_15_disp_hex_mux.v
    src/rtl/uart_logic.v
    src/rtl/comparator.v
    src/rtl/obstacles_control.v
    src/rtl/lasers_obstacle.v
    src/rtl/horizontal_lasers_obstacle.v
    src/rtl/square_follow_obstacle.v
    src/rtl/mouse_follower_obstacle.v
    src/rtl/falling_spikes_obstacle.v
    src/rtl/obstacles_counter.v
    src/rtl/control_unit.v
    src/rtl/CORE.v
    src/rtl/UART.v
    src/rtl/MOUSE.v
    src/rtl/CLK.v
    src/rtl/BUTTONS.v
    src/rtl/OBSTACLES.v
}

read_vhdl {
    src/rtl/MouseCtl.vhd
    src/rtl/Ps2Interface.vhd
    src/rtl/MouseDisplay.vhd
}

#add_files -fileset sim_1 {
#
#}

set_property top ${top_module} [current_fileset]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

if  {[lindex $argv 0] == "open"} {
    start_gui
} else {
    exit
    }
}
