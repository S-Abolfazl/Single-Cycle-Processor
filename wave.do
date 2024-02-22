onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /mips_core_tb/uut/clk
add wave -noupdate -radix unsigned /mips_core_tb/uut/rst
add wave -noupdate -radix unsigned /mips_core_tb/uut/instruction_addr
add wave -noupdate -radix unsigned /mips_core_tb/uut/instruction_data
add wave -noupdate -radix unsigned /mips_core_tb/uut/mem_Address
add wave -noupdate -radix unsigned /mips_core_tb/uut/mem_readData
add wave -noupdate -radix unsigned /mips_core_tb/uut/mem_writeData
add wave -noupdate -radix unsigned /mips_core_tb/uut/PC
add wave -noupdate -radix binary /mips_core_tb/uut/IR
add wave -noupdate -radix unsigned /mips_core_tb/uut/read_data1
add wave -noupdate -radix unsigned /mips_core_tb/uut/read_data2
add wave -noupdate -radix unsigned /mips_core_tb/uut/write_back
add wave -noupdate -radix unsigned /mips_core_tb/uut/aluA
add wave -noupdate -radix unsigned /mips_core_tb/uut/aluA2
add wave -noupdate -radix unsigned /mips_core_tb/uut/aluB
add wave -noupdate -radix unsigned /mips_core_tb/uut/aluB2
add wave -noupdate -radix unsigned /mips_core_tb/uut/alu_result
add wave -noupdate -radix unsigned /mips_core_tb/uut/addr
add wave -noupdate -radix unsigned /mips_core_tb/uut/R2
add wave -noupdate -radix unsigned /mips_core_tb/uut/R1
add wave -noupdate -radix unsigned /mips_core_tb/uut/R1_A
add wave -noupdate -radix unsigned /mips_core_tb/uut/R1_B
add wave -noupdate -radix unsigned /mips_core_tb/uut/func
add wave -noupdate -radix unsigned /mips_core_tb/uut/AluSrc
add wave -noupdate -radix unsigned /mips_core_tb/uut/memtoreg
add wave -noupdate -radix unsigned /mips_core_tb/uut/op
add wave -noupdate -radix unsigned /mips_core_tb/uut/jump
add wave -noupdate -radix unsigned /mips_core_tb/uut/write_en
add wave -noupdate -radix unsigned /mips_core_tb/uut/memRead
add wave -noupdate -radix unsigned /mips_core_tb/uut/reg_write
add wave -noupdate -radix unsigned /mips_core_tb/uut/CF
add wave -noupdate -radix unsigned /mips_core_tb/uut/ZF
add wave -noupdate -radix unsigned /mips_core_tb/uut/SF
add wave -noupdate -radix unsigned /mips_core_tb/uut/OF
add wave -noupdate -radix unsigned /mips_core_tb/uut/MSB
add wave -noupdate -radix unsigned /mips_core_tb/uut/imm8
add wave -noupdate -radix unsigned /mips_core_tb/uut/instruction_mem_write_enable
add wave -noupdate -radix unsigned /mips_core_tb/uut/instruction_input_data
add wave -noupdate -radix unsigned /mips_core_tb/uut/index
add wave -noupdate -radix unsigned /mips_core_tb/uut/temp_1
add wave -noupdate -radix unsigned /mips_core_tb/uut/temp_2
add wave -noupdate -radix unsigned /mips_core_tb/uut/bits_to_rotate
add wave -noupdate -radix unsigned /mips_core_tb/uut/i
add wave -noupdate -radix unsigned /mips_core_tb/uut/rb/reg_write
add wave -noupdate -radix unsigned /mips_core_tb/uut/rb/clk
add wave -noupdate -radix unsigned /mips_core_tb/uut/rb/reg_write
add wave -noupdate -radix unsigned /mips_core_tb/uut/rb/R1
add wave -noupdate -radix unsigned /mips_core_tb/uut/rb/R2
add wave -noupdate -radix unsigned /mips_core_tb/uut/rb/write_back
add wave -noupdate -radix unsigned /mips_core_tb/uut/rb/read_data1
add wave -noupdate -radix unsigned /mips_core_tb/uut/rb/read_data2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8530 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 213
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {54280 ps}
