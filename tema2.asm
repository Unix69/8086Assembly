    .model small          
    .data     
sum dw 0
count dw 0
buffer dw 350*dup(0)
media dw 0
num_valori db 0
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
		
		; channel 7
		MOV	BX, 	39		
		SHL	BX, 	2		
		MOV AX, 	offset ISR_PA_IN
		MOV	DS:[BX], 	AX
		MOV	AX,     seg ISR_PA_IN
		MOV	DS:[BX+2], 	AX              						
		; channel 4
		MOV	BX, 	36		
		SHL	BX, 	2		
		MOV AX, 	offset ISR_PB_OUT
		MOV	DS:[BX], 	AX
		MOV	AX,     seg ISR_PB_OUT
		MOV	DS:[BX+2], 	AX       		
		; channel 2
		MOV	BX, 	34		
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

; ISR for reading the value received on PA            
ISR_PA_IN   PROC
          in al, 80h
          cmp cl, 0 ;msb o lsb?
          jne msb
          mov byte ptr buffer[si], al ;metto lsb in parte bassa del buffer
          inc cl ;aggiorno flag di stato
          jmp esci
          
          msb:
          xor cl, cl                    ;aggiorno flag
          mov byte ptr buffer[si+1], al ;metto msb in parte alta del buffer
          inc count                     ;incremento contatore dei valori
          mov ax, buffer[si]            
          add sum, ax                   ;aggiungo il valore nel sommatore
          add si, 2                     ;aggiorno buffer
          cmp si, 700                   ;nel caso di rewind azzero il puntatore di testa
          jl esci                       ;cmp 700 perche si incrementa di due ogni volta
          ;rewind
          xor si, si                    ;azzero si per fare il rewind del puntatore di testa
          esci:        
            IRET    
ISR_PA_IN   ENDP             
                                     
                                        
                                          
; ISR for waiting a confirmation that the value written on PB is externally read                                           
ISR_PB_OUT  PROC
            STI
            
            ;freno a mano
            cmp dl, 4
            jge azzera
            
            cmp dl, 1
            jne continue1
            mov al, byte ptr media
            out 81h, al
            inc dl
            jmp fine
            
            continue1:
            cmp dl, 2
            jne continue2
            mov al, byte ptr media+1
            out 81h, al
            inc dl
            jmp fine:
            
            continue2:
            mov al, 0
            out 81h, al
            inc dl
            jmp fine
            
            
            azzera:
            xor dx, dx
            
            
            
       fine:
                         
            IRET    
ISR_PB_OUT  ENDP         
                  


; ISR executed when count0 ends                                 
ISR_COUNT0 PROC
    STI
         ;copio dati usati da pa_in
         mov bx, di  ;copio la coda in bx
         ;aggiorno indice di coda cosi il buffer continua a lavorare correttamente
         mov di, si
         mov ax, sum ;copio la somma in ax
         mov cx, count ;copio il contatore in cx
         
         ;aggiorno i dati per far ripartire in maniera corretta la pa_in
         mov sum, 0 ;azzero il sommatore ed il contatore 
         mov count,0  
        
         
         ;calcolo media
         xor dx, dx
         idiv cx
         mov media, ax
         xor dx, dx
         ;loop per contare i valori sopra la media
         
         ciclo:
         mov ax, buffer[bx] ;sposto in ax il dato da confrontare
         cmp ax, media      ;confronto con media
         jg continue3       ;se media maggiore del valore allora continua
         inc num_valori     ;altrimenti incrementa il contatore dei valori
         continue3:
         add bx, 2          ;aggiorno indice di lettura
         cmp bx, 700        ;confronto con indice massimo
         jle continue4
         xor bx, bx         ;eventuale rewind
         continue4:
         loop ciclo
         
         
         
         ;motorino
         mov dl, 1          ;inizializzo flag di stato per la 
         mov al, num_valori
         out 81h, al  
            CLI     
            IRET    
ISR_COUNT0 ENDP

                 
INIT_8255   PROC
            ; init 8255
            mov al,  10111100b
            out 83h, al
            mov al, 00001001b
            out 83h, al
            mov al, 00000101b
            out 83h, al    
   
            RET            
INIT_8255   ENDP          

INIT_8253   PROC
            ;init 8253
            mov al, 00110100b
            out 63h, al
            mov ax, 39999
            out 60h, al
            xchg ah, al
            out 60h, al
            RET
INIT_8253   ENDP    

; init 8259      
INIT_8259   PROC
            PUSH DX
       	    PUSH AX
            MOV	DX, 40H
            MOV	AL, 00010011b  ; ICW1
            ; edge triggered
            ; single 8259
            ; IC4 = si
	        OUT	DX, AL
	        MOV	DX, 41H
	        MOV	AL, 00100000b  ; ICW2
	        ; a partire da INTR 32
	        OUT	DX, AL
	        ;MOV AL, 00000011b  ; ICW4
	        ; fully nested mode
	        ; buf mode
	        ; master
	        ; Automatic End Of Interrupt
	        MOV AL, 00000001b  ; ICW4
	        ; fully nested mode
	        ; buf mode
	        ; master
	        ; normal End Of Interrupt
	        OUT DX, AL
	        MOV AL, 01101011b  ; OCW1   
	        ;no channel enabled
	        MOV DX, 41H
	        OUT DX, AL
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
            xor di, di
            xor si, si
            xor ax, ax
            xor bx, bx
            xor cx, cx
            xor dx, dx            
            
block:      ;hlt
            jmp  block
                      
            .exit

            end  ; set entry point and stop the assembler.

