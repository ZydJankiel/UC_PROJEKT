set project UC_PROJEKT
set top_module main
set target xc7a35tcpg236-1
set bitstream_file build/${project}.runs/impl_1/${top_module}.bit

proc usage {} {
    puts "usage: vivado -mode tcl -source [info script] -tclargs \[simulation/bitstream/program/open\]"
    exit 1
}

if {($argc != 1) || ([lindex $argv 0] ni {"simulation" "bitstream" "program" "open" })} {
    usage
}

if {[lindex $argv 0] == "program"} {
    open_hw_manager
    connect_hw_server
    current_hw_target [get_hw_targets *]
    open_hw_target
    current_hw_device [lindex [get_hw_devices] 0]
    refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]

    set_property PROBES.FILE {} [lindex [get_hw_devices] 0]
    set_property FULL_PROBES.FILE {} [lindex [get_hw_devices] 0]
    set_property PROGRAM.FILE ${bitstream_file} [lindex [get_hw_devices] 0]

    program_hw_devices [lindex [get_hw_devices] 0]
    refresh_hw_device [lindex [get_hw_devices] 0]
    
    exit
} else {
    file mkdir vivado
    create_project ${project} vivado -part ${target} -force
}

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
    src/rtl/pillars_horizontal_obstacle.v
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
    src/rtl/top.v
    src/rtl/comparator.v
    src/rtl/obstacles_control.v
    src/rtl/lasers_obstacle.v
    src/rtl/horizontal_lasers_obstacle.v
    src/rtl/square_follow_obstacle.v
    src/rtl/mouse_follower_obstacle.v
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
    if {[lindex $argv 0] == "simulation"} {
        launch_simulation
        add_wave {{/draw_rect_ctl_test/my_draw_rect_ctl/ypos_nxt}} 
        add_wave {{/draw_rect_ctl_test/my_draw_rect_ctl/state}} 
        run 500 ms
        start_gui
    } else {
        start_gui
        synth_design -rtl -name rtl_1 
        show_schematic [concat [get_cells] [get_ports]]
        write_schematic -force -format pdf rtl_schematic.pdf -orientation landscape -scope visible


        launch_runs synth_1 -jobs 8
        wait_on_run synth_1

        launch_runs impl_1 -to_step write_bitstream -jobs 8
        wait_on_run impl_1
        exit
    }
}
