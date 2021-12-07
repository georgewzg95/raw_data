lc 0,r0
lc 3,r3
lc 1,r4
loop1:
call r0,outr2,r31
addi r4,1,r4
subi r3,1,r3
cjsge r3,r0,loop1
loopend:
cjeq r0,r0,loopend

outr2:
and r4,r4,r2
ret r31
