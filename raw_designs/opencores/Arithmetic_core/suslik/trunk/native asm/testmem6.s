lc 0,r0 ;always zero
lc 0,r2 ;$monitor-ed register; small numbers=pass test, numbers>0x1000=error

; test #9 - write back test

lc cl3,r3 	; adress
lc 10,r4 	; loop counter
lc 1000,r5 	; value to store
loop9_w:
stl r3,0,r5
addi r5,11,r5
addi r3,0x1000,r3
subi r4,1,r4
cjuge r4,r0,loop9_w 
lc cl3,r3 	; adress
lc 10,r4 	; loop counter
lc 1000,r5 	; value to compare
		; r6 - load value
loop9_r:
ldl r3,0,r6
cjne r6,r5,error9_1
addi r5,11,r5
addi r3,0x1000,r3
subi r4,1,r4
cjuge r4,r0,loop9_r
cjeq r0,r0,skiperr9
error9_1:
lc 0x9000,r2
cjeq r0,r0,error9_1 
skiperr9:

lc 9,r2

; test #10 - more complete write back test

lc cl3,r3 	; adress
lc 10,r4 	; loop counter
lc 1000,r5 	; value to store
loop10_w_32:
lc 32,r7	; inner loop counter
and r3,r3,r8	; inner loop pointer
loop10_w_1:
stw r8,0,r5
addi r5,11,r5
addi r8,2,r8
subi r7,1,r7
cjuge r7,r0,loop10_w_1
addi r3,0x1000,r3
subi r4,1,r4
cjuge r4,r0,loop10_w_32 

lc cl3,r3 	; adress
lc 10,r4 	; loop counter
lc 1000,r5 	; value to compare
		; r6 - load value
loop10_r_32:
lc 32,r7	; inner loop counter
and r3,r3,r8	; inner loop pointer
loop10_r_1:
ldw r8,0,r6
cjne r6,r5,error10_1
addi r5,11,r5
addi r8,2,r8
subi r7,1,r7
cjuge r7,r0,loop10_r_1
addi r3,0x1000,r3
subi r4,1,r4
cjuge r4,r0,loop10_r_32
cjeq r0,r0,skiperr10
error10_1:
lc 0xa000,r2
cjeq r0,r0,error10_1 
skiperr10:

lc 10,r2


; test #1
lc cl1,r3 ;data base register
lc 0,r4 ;effective address
lc 0x1, r5 ; value to compare
; load data into r6
lc 8,r7 ; x1 loop counter
lc 8,r8 ; x8 loop counter

and r3,r3,r4

loop1_8:
lc 8,r7
loop1_1:
ldb r4,0,r6
cjne r6,r5,error1_1
addi r4,1,r4
addi r5,1,r5
subi r7,1,r7
cjuge r7,r0,loop1_1
addi r5,8,r5
subi r8,1,r8
cjuge r8,r0,loop1_8
cjeq r0,r0,skiperr1
error1_1:
lc 0x1000,r1 ;error code
or r1,r5,r2
cjeq r0,r0, error1_1
skiperr1: ;test 1 passed
lc 1,r2 

; test #2
lc cl1,r3 ;data base register
lc 0,r4 ;effective address
lc 0x0201, r5 ; value to compare
; load data into r6
lc 4,r7 ; x2 loop counter
lc 8,r8 ; x8 loop counter

and r3,r3,r4

loop2_8:
lc 4,r7
loop2_2:
ldw r4,0,r6
cjne r6,r5,error2_1
addi r4,2,r4
addi r5,0x0202,r5
subi r7,1,r7
cjuge r7,r0,loop2_2
addi r5,0x0808,r5
subi r8,1,r8
cjuge r8,r0,loop2_8
cjeq r0,r0,skiperr2
error2_1:
lc 0x2000,r1 ;error code
andi r5,0xff,r5
or r1,r5,r2
cjeq r0,r0, error2_1
skiperr2: ;test 2 passed

lc 2,r2

; test #3 read long
lc cl1,r3 ;data base register
lc 0,r4 ;effective address
lc 0x0201, r5 ; value to compare
lch r5,0x0403,r5
; load data into r6
lc 2,r7 ; x4 loop counter
lc 8,r8 ; x8 loop counter
lc 0x0404,r9 ; value to add to r5
lch r9,0x0404,r9
lc 0x0808,r10 ; add to r5 on loop3_8
lch r10,0x0808,r10

and r3,r3,r4

loop3_8:
lc 2,r7
loop3_4:
ldl r4,0,r6
cjne r6,r5,error3_1
addi r4,4,r4
add r5,r9,r5
subi r7,1,r7
cjuge r7,r0,loop3_4
add r5,r10,r5
subi r8,1,r8
cjuge r8,r0,loop3_8
cjeq r0,r0,skiperr3
error3_1:
lc 0x3000,r1 ;error code
andi r5,0xff,r5
or r1,r5,r2
cjeq r0,r0, error3_1
skiperr3: ;test 3 passed

lc 3,r2

;test #4 - write byte

lc cl1,r3 ; base of data
lc cl1,r4 ;adress of write
lc 64,r5 ; write loop counter
;r6 save data
lc 0xff,r7 ; value to store
loop4_w:
ldb r4,0,r6
stb r4,0,r7
and r3,r3,r8 ; adress for read loop
lc 64,r9 ; counter which gets =r5 for the written item
lc 0x01, r10 ; compare value
lc 8, r11 ; x8 loop counter
;r12 - read data

loop4_chk_8:
lc 8,r13 ; chk loop x1 counter
loop4_chk_1:
ldb r8,0,r12
cjeq r9,r5,test4_stored_val
cjne r12,r10,error4_1
test4_good:
addi r10,1,r10
subi r13,1,r13
addi r8,1,r8
subi r9,1,r9
cjuge r13,r0,loop4_chk_1
addi r10,8,r10
subi r11,1,r11
cjuge r11,r0,loop4_chk_8
stb r4,0,r6
addi r4,1,r4
subi r5,1,r5
cjuge r5,r0,loop4_w
cjeq r0,r0,test4_end

error4_1:
andi r10,0xff,r12
ori r12,0x4000,r2
cjeq r0,r0,error4_1 

test4_stored_val:
cjne r12,r7,error4_1
cjeq r0,r0,test4_good

test4_end:

lc 4,r2


;test #5 - write word

lc cl1,r3 ; base of data
lc cl1,r4 ;adress of write
lc 64,r5 ; write loop counter
;r6 save data
lc 0xffff,r7 ; value to store
loop5_w:
ldw r4,0,r6
stw r4,0,r7
and r3,r3,r8 ; adress for read loop
lc 64,r9 ; counter which gets =r5 for the written item
lc 0x0201, r10 ; compare value
lc 8, r11 ; x8 loop counter
;r12 - read data

loop5_chk_8:
lc 4,r13 ; chk loop x2 counter
loop5_chk_2:
ldw r8,0,r12
cjeq r9,r5,test5_stored_val
cjne r12,r10,error5_1
test5_good:
addi r10,0x0202,r10
subi r13,1,r13
addi r8,2,r8
subi r9,2,r9
cjuge r13,r0,loop5_chk_2
addi r10,0x0808,r10
subi r11,1,r11
cjuge r11,r0,loop5_chk_8
stw r4,0,r6
addi r4,2,r4
subi r5,2,r5
cjuge r5,r0,loop5_w
cjeq r0,r0,test5_end

error5_1:
andi r10,0xff,r12
ori r12,0x5000,r2
cjeq r0,r0,error5_1 

test5_stored_val:
cjne r12,r7,error5_1
cjeq r0,r0,test5_good

test5_end:

lc 5,r2


;test #6 - write longword

lc cl1,r3 ; base of data
lc cl1,r4 ;adress of write
lc 64,r5 ; write loop counter
;r6 save data
lc 0xffff,r7 ; value to store
lch r7,0xffff,r7
loop6_w:
ldl r4,0,r6
stl r4,0,r7
and r3,r3,r8 ; adress for read loop
lc 64,r9 ; counter which gets =r5 for the written item
lc 0x0201, r10 ; compare value
lch r10,0x0403,r10
lc 8, r11 ; x8 loop counter
;r12 - read data
lc 0x0404,r14 ; add value to r10
lch r14,0x0404,r14
lc 0x0808,r15 ; add value r10 - x8 loop
lch r15,0x0808,r15

loop6_chk_8:
lc 2,r13 ; chk loop x4 counter
loop6_chk_4:
ldl r8,0,r12
cjeq r9,r5,test6_stored_val
cjne r12,r10,error6_1
test6_good:
add r10,r14,r10
subi r13,1,r13
addi r8,4,r8
subi r9,4,r9
cjuge r13,r0,loop6_chk_4
add r10,r15,r10
subi r11,1,r11
cjuge r11,r0,loop6_chk_8
stl r4,0,r6
addi r4,4,r4
subi r5,4,r5
cjuge r5,r0,loop6_w
cjeq r0,r0,test6_end

error6_1:
andi r10,0xff,r12
ori r12,0x6000,r2
cjeq r0,r0,error6_1 

test6_stored_val:
cjne r12,r7,error6_1
cjeq r0,r0,test6_good

test6_end:

lc 6,r2

;test #7 - cacheline register forwarding
lc cl2,r3
lc 5,r4
lc cl2_6,r5
lc 0,r7
lc 15,r8
loop7:
ldl r3,0,r6
stl r5,0,r6
ldl r5,0,r6
add r7,r6,r7
addi r3,4,r3
subi r4,1,r4
cjuge r4,r0,loop7
cjeq r8,r7,skiperr7
error7_1:
lc 0x7000,r2
cjeq r0,r0,error7_1
skiperr7:

lc 7,r2

; test #8 - cache tag register forwarding
lc cl2,r3
lc 5,r4
;lc cl2_6,r5
lc 0,r7
lc 15,r8
lc 0,r9
loop8:
ldl r3,0,r6
stl r3,64,r6
ldl r3,64,r6
ldl r3,0,r5
add r7,r6,r7
add r9,r5,r9
addi r3,4,r3
subi r4,1,r4
cjuge r4,r0,loop8
cjne r9,r8,error8_1
cjeq r8,r7,skiperr8
error7_1:
lc 0x8000,r2
cjeq r0,r0,error8_1
skiperr8:

lc 8,r2


test_end_all:
cjeq r0,r0,test_end_all


section data
align 64
cl1:
DB 0x1  0x2  0x3  0x4  0x5  0x6  0x7  0x8
DB 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18
DB 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28
DB 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38
DB 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48
DB 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58
DB 0x61 0x62 0x63 0x64 0x65 0x66 0x67 0x68
DB 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78
cl2:
DL 1 2 3 4 5
cl2_6:
DL 0
section bss
align 64
cl3:


