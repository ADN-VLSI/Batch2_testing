
set tb [lindex $argv 0]
if {$tb == ""} {
    puts "Usage: vivado -mode batch -source run_sim.tcl <top_module>"
    exit 1
}
# Collect sources
set srcs [glob -nocomplain *.sv testbenches/*.sv]
if {[llength $srcs] == 0} {
    puts "No SystemVerilog sources found"
    exit 1
}
puts "Compiling sources: $srcs"
# Use xvlog/xelab/xsim for a simple batch flow
set cmd_xvlog [concat xvlog -sv $srcs]
puts "Running: $cmd_xvlog"
if {[catch {eval exec $cmd_xvlog} result]} {
    puts "xvlog failed:\n$result"
    exit 1
}
set cmd_xelab [list xelab $tb -debug typical -timescale 1ns/1ps -nolog]
puts "Running: $cmd_xelab"
if {[catch {eval exec $cmd_xelab} result]} {
    puts "xelab failed:\n$result"
    exit 1
}
set cmd_xsim [list xsim $tb -runall]
puts "Running: $cmd_xsim"
if {[catch {eval exec $cmd_xsim} result]} {
    puts "xsim failed:\n$result"
    exit 1
}
puts "Simulation finished for $tb"
