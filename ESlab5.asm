portaa equ 80h
portab equ 81h
portac equ 82h
portacntrl equ 83h
cw1 equ 10110100b
spc4 equ 00001001b
spc2 equ 00000101b 
   .MODEL SMALL
   .DATA
vet db 5*dup(0)
result db 0        
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
		
		MOV BX,     36
		SHL BX,     2
		MOV AX,     offset ISR2
		MOV DS:[BX],    AX
		MOV AX,     seg ISR2
		MOV DS:[BX+2],  AX
		
		      		
		POP	DS
		POP	DX
		POP	BX
		POP	AX
		RET
INIT_IVT	ENDP




ISR1 PROC
      CLI
        cmp si, 5
        je rewind
        continue1:
        push result
        call end_frame
        pop result
        mov cx, result
        cmp cx, 1
        je primo_out
        in al, portaa
        mov vet[si], al
        inc si
      inizio_out:
      STI     
    IRET 
        
 rewind:
 mov si, 0
 jmp continue1
 
 
 primo_out:        
 mov di, si        
 mov al, vet[di] 
 out portab, al
 inc di
 jmp inizio_out      

ISR1    ENDP                  

        




ISR2 PROC
      CLI
        cmp di, 5
        je rewind
        continue1:
        mov cx, si
        sub cx, 1
        cmp cx, di
        je fine_out
        mov al, vet[di]
        out portab, al     
        inc di
        fine_out:
      STI     
    IRET 
              
              
 rewind:
 mov di, 0
 jmp continue1
  

ISR2    ENDP      


end_frame PROC
          mov bp, sp
          mov bx, si
          mov dx, 0
          mov cx, 0
          
          do1:
          jmp decr
          continue1:
          mov cx, vet[bx]
          cmp cx, 00h
          je do2
          jmp fine
          
          do2:
          jmp decr
          continue1:
          mov cx, vet[bx]
          cmp cx, ffh
          je do3
          jmp fine
          
          do3:
          jmp decr
          continue1:
          mov cx, vet[bx]
          cmp cx, 00h
          je end_recieve
          jmp fine
  
          
          end_recieve
          mov dx, 1
          jmp fine
          
          
          decr:
          sub bx, 1
          cmp bx, -1
          je reverse_rewind
          jmp continue1
          
          
          reverse_rewind:
          mov bx, 4
          jmp continue1:
                 
          fine:  
          mov [bp+2], dx
          ret  
 
           
end_frame    ENDP



    
    .startup    
    CLI         
    call INIT_IVT
    STI
    mov dx, portacntrl
    mov al, cw1
    out dx, al
    mov al, spc4
    out dx, al
    mov al, spc2
    out dx, al
    xor dx, dx
    xor ax, ax
              
next:  
    
jmp next
    .exit
end
