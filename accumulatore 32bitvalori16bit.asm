.model small
.data
vett dw 1000000000000000b,1000000000000000b,1111111111111111b,1000000000000000b
sum dd 0
.stack
.code


;accumulatore 32 bit
;singoli valori da 16 bit
;gestione overflow e carry

.startup
xor ax, ax
xor bx, bx
xor si, si
xor cx, cx
xor di, di
xor dx, dx
clc
ciclo:
mov ax, vett[si]
add word ptr sum, ax
adc word ptr sum+2, 0
add si, 2
cmp si, 8
jb ciclo
 
