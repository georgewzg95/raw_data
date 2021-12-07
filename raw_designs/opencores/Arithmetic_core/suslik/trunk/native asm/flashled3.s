lc 0,r0
lc 159,r3

loop1:
lc string,r1
lc 8,r2
loop2:
ldb r1,0,r4
outb r3,r4
addi r1,1,r1
subi r2,1,r2
cjsgt r2,r0,loop2
cjeq r0,r0,loop1

section data
string:
DB 0xb 0xa 0xa 0xd 0xf 0x0 0x0 0xd
DB 0





