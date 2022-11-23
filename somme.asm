.model small
.data
var1 db 10000000b
var2 db 10000000b
var3 dw 1000000000000000b
var4 dw 1000000000000000b
sum dd 0 
.stack
.code
.startup
;somma tra byte
;carry gestito dalla somma dei registri su 16 bit
;overflow gestito dall'estensione dei registri
xor ax, ax
xor bx, bx
mov bl, var2
mov al, var1
add ax, bx
;somma tra word memorizzata in una dword 
;per evitare eventuale overflow
;con gestione del carry
xor dx, dx
xor ax, ax
mov ax, var3              
mov word ptr sum, ax  
mov ax, var4
add word ptr sum, ax
adc word ptr sum+2, 0
.exit
end