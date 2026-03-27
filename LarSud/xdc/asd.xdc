## =========================
## Basys3 XDC for task_scheduler_top_v2
## Ports:
## clk, rst, start, uart_rx_i, servo_sig, leds[15:0], seg[6:0], an[3:0]
## =========================

## ------------------------------------------------------------------
## Clock : 100 MHz onboard clock
## ------------------------------------------------------------------
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name sys_clk_pin -period 10.000 [get_ports clk]

## ------------------------------------------------------------------
## Buttons
## rst   -> BTNU
## start -> BTNC
## ------------------------------------------------------------------
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

set_property PACKAGE_PIN T18 [get_ports start]
set_property IOSTANDARD LVCMOS33 [get_ports start]

## ------------------------------------------------------------------
## LEDs
## ------------------------------------------------------------------
set_property PACKAGE_PIN U16 [get_ports {leds[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]

set_property PACKAGE_PIN E19 [get_ports {leds[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]

set_property PACKAGE_PIN U19 [get_ports {leds[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]

set_property PACKAGE_PIN V19 [get_ports {leds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[3]}]

set_property PACKAGE_PIN W18 [get_ports {leds[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[4]}]

set_property PACKAGE_PIN U15 [get_ports {leds[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[5]}]

set_property PACKAGE_PIN U14 [get_ports {leds[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[6]}]

set_property PACKAGE_PIN V14 [get_ports {leds[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[7]}]

set_property PACKAGE_PIN V13 [get_ports {leds[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[8]}]

set_property PACKAGE_PIN V3 [get_ports {leds[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[9]}]

set_property PACKAGE_PIN W3 [get_ports {leds[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[10]}]

set_property PACKAGE_PIN U3 [get_ports {leds[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[11]}]

set_property PACKAGE_PIN P3 [get_ports {leds[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[12]}]

set_property PACKAGE_PIN N3 [get_ports {leds[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[13]}]

set_property PACKAGE_PIN P1 [get_ports {leds[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[14]}]

set_property PACKAGE_PIN L1 [get_ports {leds[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[15]}]

## ------------------------------------------------------------------
## UART input from Raspberry Pi
## Pi TX -> Basys3 JA1 = J1 -> uart_rx_i
## IMPORTANT:
## - Pi GND must connect to Basys3 GND
## - Only connect Pi TX to this pin
## ------------------------------------------------------------------
set_property PACKAGE_PIN J1 [get_ports uart_rx_i]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx_i]

## ------------------------------------------------------------------
## Servo signal output
## Basys3 JA3 = J2 -> servo_sig
## IMPORTANT:
## - This is SIGNAL only
## - Servo power must come from external 5V
## - Servo GND must be shared with Basys3 GND
## ------------------------------------------------------------------
set_property PACKAGE_PIN J2 [get_ports servo_sig]
set_property IOSTANDARD LVCMOS33 [get_ports servo_sig]
set_property DRIVE 8 [get_ports servo_sig]
set_property SLEW SLOW [get_ports servo_sig]

## ------------------------------------------------------------------
## 7-Segment Display
## seg[6:0] = CA CB CC CD CE CF CG
## an[3:0]  = AN0 AN1 AN2 AN3
## ------------------------------------------------------------------
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

set_property PACKAGE_PIN V7 [get_ports {an[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]

set_property PACKAGE_PIN U2 [get_ports {an[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]

set_property PACKAGE_PIN U4 [get_ports {an[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]

set_property PACKAGE_PIN V4 [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

set_property PACKAGE_PIN A14 [get_ports ext_led]
set_property IOSTANDARD LVCMOS33 [get_ports ext_led]