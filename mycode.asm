nr equ 4
nc equ 4
.Model small
.stack
.data
matr dw 4,1,-6,5,0,5,2,3,0,0,2,3,0,0,0,1
matrt dw 16 dup(0)
var db 4
.code
.startup
mov si,0
mov di,0
mov bx,0
mov cx,0 
mov ax,0
lea di, matrt
indexing:lea si, matr
add si, bx
mov cx,nr
ciclo:mov ax,[si]
mov [di],ax
add di,2
add si,2*nr
loop ciclo
add bx,2
cmp bx,nc*2
jb indexing
.exit
end