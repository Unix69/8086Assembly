.model small
.data
vett db 10, -10, 20, 100, 100, 100, 100, -100, 100, 100
buffer dw 10 dup(0)
sum dw 0
.stack
.code

;sommatoria di valori con segno su 8bit
;in una variabile da 16 bit


.startup
xor ax, ax
xor bx, bx
xor si, si
xor cx, cx
xor di, di
xor dx, dx

ciclo:
mov al, vett[si]
cbw
add sum, ax
inc si
cmp si, 10
jb ciclo 

fine:

.exit
end