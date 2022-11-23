.model small
.data
vett dd 10, 10, 100000, 100, 100, 100, 100, 100, 100, 100
buffer dw 10 dup(0)
sum dd 0
.stack
.code

;somma di valori unsigned su 32 bit in un sommatore da 32
;tenendo conto dell'overflow nel caso della somma delle singole word (adc)


.startup
xor ax, ax
xor bx, bx
xor si, si
xor cx, cx
xor di, di
xor dx, dx
clc
ciclo:
mov ax, word ptr vett[si]
mov dx, word ptr vett[si+2]
add word ptr sum, ax
adc word ptr sum+2, dx
add si, 4
cmp si, 40
jb ciclo
mov ax, word ptr sum
mov dx, word ptr sum+2 

.exit
end