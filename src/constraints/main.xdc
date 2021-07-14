# Constraints for CLK
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
# create_clock -name external_clock -period 10.00 [get_ports clk]

# Constraints for RX
set_property PACKAGE_PIN B18 [get_ports rx]
set_property IOSTANDARD LVCMOS33 [get_ports rx]

# Constraints for TX
set_property PACKAGE_PIN A18 [get_ports tx]
set_property IOSTANDARD LVCMOS33 [get_ports tx]

# Constraints for VS and HS
set_property PACKAGE_PIN R19 [get_ports {vs}]
set_property IOSTANDARD LVCMOS33 [get_ports {vs}]
set_property PACKAGE_PIN P19 [get_ports {hs}]
set_property IOSTANDARD LVCMOS33 [get_ports {hs}]

# Constraints for RED
set_property PACKAGE_PIN G19 [get_ports {r[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {r[0]}]
set_property PACKAGE_PIN H19 [get_ports {r[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {r[1]}]
set_property PACKAGE_PIN J19 [get_ports {r[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {r[2]}]
set_property PACKAGE_PIN N19 [get_ports {r[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {r[3]}]

# Constraints for GRN
set_property PACKAGE_PIN J17 [get_ports {g[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {g[0]}]
set_property PACKAGE_PIN H17 [get_ports {g[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {g[1]}]
set_property PACKAGE_PIN G17 [get_ports {g[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {g[2]}]
set_property PACKAGE_PIN D17 [get_ports {g[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {g[3]}]

# Constraints for BLU
set_property PACKAGE_PIN N18 [get_ports {b[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {b[0]}]
set_property PACKAGE_PIN L18 [get_ports {b[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {b[1]}]
set_property PACKAGE_PIN K18 [get_ports {b[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {b[2]}]
set_property PACKAGE_PIN J18 [get_ports {b[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {b[3]}]

# Constraints for PCLK_MIRROR
#set_property PACKAGE_PIN J1 [get_ports {pclk_mirror}]
#set_property IOSTANDARD LVCMOS33 [get_ports {pclk_mirror}]

# Constraints for CFGBVS
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Buttons
#Bank = 14, Pin name = ,					Sch name = BTNC
set_property PACKAGE_PIN U18 [get_ports {rst}]
set_property IOSTANDARD LVCMOS33 [get_ports {rst}]

set_property PACKAGE_PIN T18 [get_ports game_button]						
	set_property IOSTANDARD LVCMOS33 [get_ports game_button]
set_property PACKAGE_PIN W19 [get_ports menu_button]						
    set_property IOSTANDARD LVCMOS33 [get_ports menu_button]
set_property PACKAGE_PIN T17 [get_ports victory_button]						
    set_property IOSTANDARD LVCMOS33 [get_ports victory_button]
set_property PACKAGE_PIN U17 [get_ports game_over]						
        set_property IOSTANDARD LVCMOS33 [get_ports game_over]
    
## Switches
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
set_property PACKAGE_PIN V16 [get_ports {sw[1]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
set_property PACKAGE_PIN W16 [get_ports {sw[2]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
set_property PACKAGE_PIN W17 [get_ports {sw[3]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]    
    

        
set_property PACKAGE_PIN C17 [get_ports {ps2_clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {ps2_clk}]
set_property PULLUP true [get_ports ps2_clk]

set_property PACKAGE_PIN B17 [get_ports {ps2_data}]
set_property IOSTANDARD LVCMOS33 [get_ports {ps2_data}]
set_property PULLUP true [get_ports ps2_data]

  ## LEDs
  set_property PACKAGE_PIN U16 [get_ports {led[0]}]                    
      set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
  set_property PACKAGE_PIN E19 [get_ports {led[1]}]                    
      set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
  set_property PACKAGE_PIN U19 [get_ports {led[2]}]                    
      set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
  set_property PACKAGE_PIN V19 [get_ports {led[3]}]                    
      set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
  set_property PACKAGE_PIN W18 [get_ports {led[4]}]                    
       set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
  set_property PACKAGE_PIN U15 [get_ports {led[5]}]                    
      set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]
  set_property PACKAGE_PIN U14 [get_ports {led[6]}]                    
      set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]
  set_property PACKAGE_PIN V14 [get_ports {led[7]}]                    
      set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]
  set_property PACKAGE_PIN V13 [get_ports {led[8]}]                    
      set_property IOSTANDARD LVCMOS33 [get_ports {led[8]}]
  set_property PACKAGE_PIN V3 [get_ports {led[9]}]                    
      set_property IOSTANDARD LVCMOS33 [get_ports {led[9]}]
  set_property PACKAGE_PIN W3 [get_ports {led[10]}]                    
      set_property IOSTANDARD LVCMOS33 [get_ports {led[10]}]
  set_property PACKAGE_PIN U3 [get_ports {led[11]}]                    
      set_property IOSTANDARD LVCMOS33 [get_ports {led[11]}]
  set_property PACKAGE_PIN P3 [get_ports {led[12]}]                    
      set_property IOSTANDARD LVCMOS33 [get_ports {led[12]}]
  set_property PACKAGE_PIN N3 [get_ports {led[13]}]                    
      set_property IOSTANDARD LVCMOS33 [get_ports {led[13]}]
  set_property PACKAGE_PIN P1 [get_ports {led[14]}]                    
      set_property IOSTANDARD LVCMOS33 [get_ports {led[14]}]
  set_property PACKAGE_PIN L1 [get_ports {led[15]}]                    
      set_property IOSTANDARD LVCMOS33 [get_ports {led[15]}]
      
##7 segment display
  set_property PACKAGE_PIN W7 [get_ports {seg[0]}]          
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
  set_property PACKAGE_PIN W6 [get_ports {seg[1]}]          
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
  set_property PACKAGE_PIN U8 [get_ports {seg[2]}]          
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
  set_property PACKAGE_PIN V8 [get_ports {seg[3]}]          
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
  set_property PACKAGE_PIN U5 [get_ports {seg[4]}]          
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
  set_property PACKAGE_PIN V5 [get_ports {seg[5]}]          
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
  set_property PACKAGE_PIN U7 [get_ports {seg[6]}]          
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
  set_property PACKAGE_PIN V7 [get_ports  {seg[7]}]							
      set_property IOSTANDARD LVCMOS33 [get_ports  {seg[7]}]

    
  set_property PACKAGE_PIN U2 [get_ports {an[0]}]					
      set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
  set_property PACKAGE_PIN U4 [get_ports {an[1]}]          
     set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
  set_property PACKAGE_PIN V4 [get_ports {an[2]}]          
     set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
  set_property PACKAGE_PIN W4 [get_ports {an[3]}]          
     set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]
     
