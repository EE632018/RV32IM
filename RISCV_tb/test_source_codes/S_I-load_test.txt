li a0, 0x04038101 # Smulator has a bug and loads 0x04039101 = 67342593
sw a0, 0(x0)#expected values
lw a1, 0(x0)#67342593
lh a2, 0(x0)#-28415
lh a3, 2(x0)#1027
lb a4, 0(x0)#1
lb a5, 1(x0)#-111
lb a6, 2(x0)#3
lb a7, 3(x0)#4
lhu a2, 0(x0)#37129
lhu a3, 2(x0)#1027
lbu a4, 0(x0)#1
lbu a5, 1(x0)#145
lbu a6, 2(x0)#3
lbu a7, 3(x0)#4
sh a2, 4(x0)
sh a3, 6(x0)# 2*sh =sw
sb a4, 8(x0)
sb a5, 9(x0)
sb a6, 10(x0)
sb a7, 11(x0)# 4*sb =sw
beq a0,a1, valid
jal error
valid: jal exit 
error: li a0 -1
exit: nop
