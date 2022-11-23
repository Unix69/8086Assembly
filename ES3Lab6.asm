cw8255 equ 10010000b  
    .model small          
    .data     
vet db 4 dup(0)
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
		MOV	BX, 	34		
		SHL	BX, 	2		
		MOV AX, 	offset ISR_COUNT12
		MOV	DS:[BX], 	AX
		MOV	AX,     seg ISR_COUNT12
		MOV	DS:[BX+2], 	AX 					
										
		POP	DS
		POP	DX
		POP	BX
		POP	AX 		
		RET
INIT_IVT	ENDP


; ISR executed when count2 ends                                 
ISR_COUNT12 PROC
    ;cl usato come contatore di sequenze 
    ;critiche consecutive-azzerato 
    ;ogni qual volta si interrompe
    ;una sequenza potenzialmente critica
   
    ;ch usato come indice di ABScicle ovvero
    ;il numero di cicli da 25ms mancanti alla 
    ;fine della fase di frenata controllata
    ;opportunamente inizializato a 4 all'avvio
    ;del sistema ABS-viene usato nella condizione
    ;di fine ABS (cmp ch, 0)
   
   
    ;bh viene usato come registro di stato
    ;bh=1 segnala al sistema che siamo in fase
    ;di frenata controllata bh=0 siamo in una
    ;situazione gradita
    
    ;il sistema dunque riesce a distinguere
    ;lo stato di frenata controllata o quiete
    ;mediante il registro bh,sa quanto manca in termini
    ;di cicli da 25ms affinche' un eventuale fase di 
    ;frenata termini mediante il registro ch
    ;e sa se al termine della fase di frenata se continuare 
    ;ad abilitare la frenata o meno mediante il controllo
    ;del registro cl (se la situazione e' ancora critica allora
    ;cl=4). La lettura della porta A dunque viene eseguita sempre:
    ;nel ciclo di ABS oltre che in un ciclo di quiete.
    
   
            ;lettura valore dallo SC
            in al, 80h
            mov vet[si], al
            jmp SCunit
            continue1:
            cmp cl, 4
            je ABSon
            jne decide
            continue4:
            inc si
            cmp si, 4
            je rewind
            continue5:
            jmp fine
            
            
            ;rewind del pointer circolare
            rewind:
            mov si, 0
            jmp continue5
            
                 
       
           decide:
           ;ABSflag
           cmp bh, 1
           jne continue4
           dec ch
           ;ABScycle
           cmp ch, 0
           je ABSoff
           jmp continue4
            
            
            SCunit:
            mov di, si
            dec di
            mov al, vet[di]
            sub al, vet[si]
            cmp al, -5
            jg continue2
            jle continue3
            continue2:
            mov cl, 0 ;sequenza potenzialmente critica interrotta -> cl = 0 (si riparte da capo)   
            jmp endif                          
            continue3:
            inc cl    ;nel caso critico invece dobbiamo incrementare cl contatore di sequenze critiche consecutive 
            endif:    
            jmp continue1
                        
            
            ;Avvio ABS
            ABSon:
            mov al, 0ffh
            out 81h, al
            mov cl, 0
            mov bh, 1
            mov ch, 4
            jmp continue4
            
            ;Chiusura ABS
            ABSoff:
            mov al, 00h
            out 81h, al
            mov ch, 0
            mov bh, 0
            jmp continue4
            
           fine:   
            
      IRET 
ISR_COUNT12 ENDP                  
         
       
                 
INIT_8255   PROC
            ; init 8255    
            mov al, cw8255
            out 83h, al  
            RET            
INIT_8255   ENDP          

INIT_8253   PROC
            ;init 8253
             ;counter1 init
            mov al, 01110100b
            out 063h, al  
             ;counter2 init    
            mov al, 10110000b
            out 063h, al 
            ;counter1 value                       
            mov ax,  9999
            out 061h, al
            xchg al,  ah
            out 061h, al
            ;counter2 value              
            mov ax,  2999
            out 062h, al
            xchg al,  ah
            out 062h, al
            RET
INIT_8253   ENDP    


;programma principale
            .startup    
            CLI         
            call INIT_IVT 
            call INIT_8253 
            call INIT_8255
            mov si, 0
            mov al, 0
            mov cx, 0
            mov bh, 0
            
            STI        
                        
            
block:      ;hlt
            jmp  block
                      
            .exit

            end  ; set entry point and stop the assembler.

