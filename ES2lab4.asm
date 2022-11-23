portaa equ 80h
portab equ 81h
portac equ 82h
portacntrl equ 83h
cw1 equ 10110000b
spc4 equ 00001001b
   .MODEL SMALL
   .DATA
vet db 5*dup(0)        
   .STACK
   .CODE   
    
    

INIT_IVT	PROC
		PUSH 	AX
		PUSH	BX
		PUSH	DX
		PUSH 	DS
		XOR	AX, 	AX
		MOV	DS, 	AX      
		
	
		MOV	BX, 	39	
		SHL	BX, 	2		
		MOV AX, 	offset ISR1
		MOV	DS:[BX], 	AX
		MOV	AX,     seg ISR1
		MOV	DS:[BX+2], 	AX
		
		      		
		POP	DS
		POP	DX
		POP	BX
		POP	AX
		RET
INIT_IVT	ENDP




ISR1 PROC
      CLI
        cmp di, 5
        jae out_sig
        in al, portaa
        mov vet[di], al
        inc di
        cmp al, bl
        ja swap
        continue2:
      STI     
    IRET 
        
 swap:
 mov bl, al
 jmp continue2
 
 out_sig:
 
 mov al, bl
 out portab, al
 xor bx, bx
 xor di, di
 xor ax, ax
 jmp continue2      

ISR1    ENDP                  

        
            
    
    .startup    
    CLI         
    call INIT_IVT
    STI
    mov dx, portacntrl
    mov al, cw1
    out dx, al
    mov al, spc4
    out dx, al
    xor dx, dx
    xor ax, ax
    
        
              
next:  
    
jmp next
    .exit
end
