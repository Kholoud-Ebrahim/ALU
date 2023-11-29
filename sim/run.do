#***************************************************#
# Clean Work Library
#***************************************************#
if [file exists "work"] {vdel -all}
vlib work

#***************************************************#
# Compile RTL and TB files
#***************************************************#
vlog -f alu_dut.f
vlog -f alu_tb.f

#***************************************************#
# Optimizing Design with vopt
#***************************************************#
vopt top -o top_opt -debugdb  +acc +cover=sbecf+alu(rtl).

#***************************************************#
# Simulation of a Test
#***************************************************#
transcript file log/alu_log.log
vsim -voptargs=+acc top_opt -c -assertdebug -debugDB -fsmdebug -coverage
set NoQuitOnFinish 1
onbreak {resume}
log /* -r
add wave /top/vif/*
run -all

add wave sim:/top/vif/and_a_irq_ass1
add wave sim:/top/vif/nand_a_irq_ass2
add wave sim:/top/vif/or_a_irq_ass3
add wave sim:/top/vif/xor_a_irq_ass4
add wave sim:/top/vif/xnor_b_irq_ass5
add wave sim:/top/vif/and_b_irq_ass6
add wave sim:/top/vif/nor_b_irq_ass7
add wave sim:/top/vif/or_b_irq_ass8
add wave sim:/top/vif/irq_clr_out_ass9


coverage attribute -name TESTNAME -value alu_test
coverage save coverage/alu_test.ucdb

vcover report coverage/alu_test.ucdb  -cvg -details -output     coverage/functional_coverage.txt
vcover report coverage/alu_test.ucdb  -output                   coverage/code_coverage.txt
vcover report coverage/alu_test.ucdb  -details -assert  -output coverage/assertions.txt