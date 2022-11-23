.model small
.data
vet db 20 dup(0)
var db 1
count db 0
sum dw 0
.stack
.code

.startup
xor si, si
xor di, di
xor ax, ax
xor cx, cx
xor bx, bx


ciclo:
mov al, var
mov vet[si], al

inc var
inc count
inc si
cmp si, 20
jne continue2
xor si, si
continue2:
cmp count, 5
je elabora
continue1:
         


jmp ciclo




elabora:
mov sum, 0
xor ax, ax
xor bx, bx
mov bx, di
mov ax, si
mov di, si
mov count, 0
ciclo_elab:
mov cl, vet[bx]
xor ch, ch
add sum, cx
inc bx
cmp bx, 20
jne continue3
xor bx, bx
continue3:
cmp bx, ax
je continue1
jmp ciclo_elab   




.exit
end