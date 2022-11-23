.Model small
.stack
.data
vet dd 3,5,-4,-5,2
varp dd 0
varn dd 0
.code
.startup
mov ax,0
mov dx ,0
mov bx,0
lea si,vet
mov cx,5
ciclo:mov ax,[si]
mov dx,[si+2]
cmp dx,0
jge positivi
jl negativi
continue:
add si, 4
loop ciclo  
jmp fine

positivi:
cmp bl,1
je continue
add word ptr varp, ax
adc word ptr varp+2,dx
jno continue
mov varp,0
mov bl,1
jmp continue

negativi:
cmp bh,1
je continue
add word ptr varn, ax
adc word ptr varn+2,dx
jno continue
mov varn,0
mov bh,1
jmp continue
fine:
.exit
end