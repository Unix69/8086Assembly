  
    .model small          
    .data     
occ db 256*dup(0)
buffer db 90*dup(0)
valore dw 0 
    .stack     
    .code   
    
    
    ; procedura di inizializzazione della interrupt vector table
INIT_IVT	PROC
		PUSH 	AX
		PUSH	BX
		PUSH	DX
		PUSH 	DS
		XOR	AX, 	AX
		MOV	DS, 	AX      
		      		      				
		; channel 4
		MOV	BX, 	36		
		SHL	BX, 	2		
		MOV AX, 	offset ISR_PB_OUT
		MOV	DS:[BX], 	AX
		MOV	AX,     seg ISR_PB_OUT
		MOV	DS:[BX+2], 	AX       		 					
		; channel 3
		MOV	BX, 	35		
		SHL	BX, 	2		
		MOV AX, 	offset ISR_COUNT0
		MOV	DS:[BX], 	AX
		MOV	AX,     seg ISR_COUNT0
		MOV	DS:[BX+2], 	AX					
										
		POP	DS
		POP	DX
		POP	BX
		POP	AX 		
		RET
INIT_IVT	ENDP

             
                                  
                           
            
                                          
; ISR for waiting a confirmation that the value written on PB is externally read                                           
ISR_PB_OUT  PROC  
            STI
            ;freno a mano
            cmp bx, 256 
            jg fine
               
               
             ciclo: 
               cmp occ[bx], 2
               jge trovato
               inc bx
             cmp bx, 256
             jl ciclo
                
            
           
            trovato:
            mov al, bl
            inc bx 
            out 81h, al
            
            fine:
            
            
            
               
            CLI                  
            IRET    
ISR_PB_OUT  ENDP  




; ISR executed when count2 ends                                 
ISR_COUNT0 PROC 
           
           ;mem
           in al, 80h
           mov ah, 0
           mov si, ax
           inc occ[si]
           inc cx
           cmp cx, 44
           je motorino
           jmp fine
           
           
           
           motorino:
           xor cx,cx   
           xor bx, bx
           ciclo: 
               cmp occ[bx], 2
               jge trovato
               inc bx
             cmp bx, 256
           jl ciclo
           jmp fine
           
           
           
           trovato:
             mov al, bl
             out 81h, al
           jmp fine_motorino 
           
           
           fine_motorino:
           ;cambio struttura dati per non confondere i dati nuovi con i vecchi
           
           
           fine:
            
            
            
            
           IRET    
ISR_COUNT0 ENDP                  
                 
INIT_8255   PROC
            ; init 8255    
            mov al, 10010100b;
            out 083h, al
            ; set PC2 to enable interrupt on PB in or PB out
            mov al, 00000101b 
            out 083h, al     
            RET            
INIT_8255   ENDP          

INIT_8253   PROC
            ;init 8253
             ;counter0 init
            mov al, 00110100b
            out 063h, al                       
            mov ax,  4499
            out 060h, al
            xchg al,  ah
            out 060h, al                             
            RET
INIT_8253   ENDP    

; init 8259      
INIT_8259   PROC
            PUSH DX
       	    PUSH AX
            MOV	AL, 00010011b  ; ICW1
            ; edge triggered
            ; single 8259
            ; IC4 = si
	        OUT	40h, AL
	        MOV	AL, 00100000b  ; ICW2
	        ; a partire da INTR 32
	        OUT	41h, AL
	        MOV AL, 00000011b  ; ICW4
	        ; fully nested mode
	        ; buf mode
	        ; master
	        ; Automatic End Of Interrupt
	        OUT 41h, AL
	        MOV AL, 11100111b  ; OCW1   
	        OUT 41h, AL
	        POP DX
	        POP AX
	        RET
INIT_8259   ENDP


;programma principale
            .startup    
            CLI         
            call INIT_IVT
	        call INIT_8259 
            call INIT_8253 
            call INIT_8255
            STI        
            xor si,si 
            xor di,di 
            xor cx,cx 
            xor dx,dx 
            xor ax,ax 
            xor bx,bx             
            
block:      ;hlt
            jmp  block
                      
            .exit

            end  ; set entry point and stop the assembler.

