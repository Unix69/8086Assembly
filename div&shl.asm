.model small
.data
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

mov bx, -2
mov ax, -10
cwd
idiv bx

xor dx, dx
mov bx, 2
mov ax, 10
cwd
div bx

xor ax, ax
mov al, 20
shl al, 2

xor ax, ax
mov al, 80 ;80*4 > 255
shl al, 2 ;unsigned overflow->da non fare
                    
xor ax, ax          
mov ax, 80
shl ax, 2;corretto

xor ax, ax
mov al, -20
shl al, 2
                   
xor ax, ax          
mov al, -40 ;-40*4 > -127
shl al, 2 ;signed overflow
                    
mov ax, -40
shl ax, 2 ;corretto

  

.exit
end