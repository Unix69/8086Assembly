    .model small          
    .data     
fine_seq db 0
buffer db 60 dup(0)
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
		; channel 1
		MOV	BX, 	33		
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


;la logica del programma si basa sul fatto di non salvare dati consecutivi uguali
;poiche' inutili al fine del corretto invio della sequenza filtrata.
;Questo viene fatto sia per risparmiare spazio, sia per ottenere un primo filtraggio dei dati
;a livello di input, evitando cosi operazioni di preinvio che rendono la routine di output
;piu' leggera e meno complessa.
;Oltre a tale operazione, viene eseguito il calcolo del massimo, sempre per gli stessi motivi,
;durante l'arrivo dei dati in input.
;Cosi facendo la routine di output esegue soltanto un confronto tra registri
;e banali controlli e aggiornamenti di indici.
;per differenziare lo stato di invio e lo stato di non invio dei dati viene usato
;un flag che viene settato dalla routine di input nel caso di sequenza completata
;e resettato dalla routine di output a fine sequenza (causa modo 2 del 8253 che scatta
;scatta forzatamente ogni 200ms anche quando non vi e' alcun dato da inviare)
;i registri condivisi sono bx e cl che non vengono pushati e poppati
;l'unico registro non condiviso usato da entrambe le routine e' ax che viene pushato
;e poppato solo dalla routine piu prioritaria 




; ISR for reading the value received on PA            
ISR_PA_IN   PROC
            push ax
            in al, 80h
            
            cmp al, 0
            je fine_sequenza
            
            cmp al, dh ;precedente = nuovo
            je fine    ;se si non memorizzare e non salvare
            mov buffer[si], al  ;se no salva il valore
            mov dh, al ; precedente = nuovo
            cmp al, dl ; massimo < al
            jbe continue1 ; se no aggiorna solo l'indice di testa
            mov dl, al ; se si massimo = al
           
            continue1:
            inc si
            cmp si, 60
            jne fine
            xor si, si  ;rewind buffer
            jmp fine
            
         
           fine_sequenza:
           mov buffer[si], al ;mem lo zero per indice di fine sequenza
           inc si             ;evitando di copiare testa e coda del buffer
           cmp si, 60         ;incremento si per evitare operazioni superflue per aggiornare di
           jne continue2      ;eventuale rewind per non aggiornare di in maniera errata
           xor si, si
           continue2:
           mov bx, di ;copio coda in bx registro condiviso delle routine
           mov di, si ;aggiorno coda (semplice operazione di copia)
           mov cl, dl ;copio dei registri
           shr cl, 1  ;divido per 2
           xor dx, dx ;azzero massimo e precedente con un colpo di clock
           mov fine_seq, 1 ;alzo flag di fine sequenza
        
            pop ax
            fine:
            IRET    
ISR_PA_IN   ENDP             
              
  


; ISR executed when count2 ends                                 
ISR_COUNT12 PROC 
            STI     
            cmp fine_seq, 1 ;se e' un ciclo di invio dati allora invia
            jne fine        ;altrimenti non inviare nulla
      
            
            cmp buffer[bx],0  ;se e' fine sequenza il dato sara' zero
            je fine_invio     ;vai a fine invio
            
            
            cmp cl, buffer[bx]  ;altrimenti confronta il dato in memoriacon il massimo/2
            jb continue1        ;se maggiore invia il dato
            mov al, buffer[bx]
            out 81h, al
            continue1:
            inc bx              ;aggiorna l'indice in ogni caso per passare al dato successivo
            cmp bx, 60          ;allo scadere dei 200ms
            jne fine            ;eventuale rewind del puntatore
            xor bx, bx
            
            
            
            fine_invio:
            mov fine_seq, 0     ;se fine sequenza aggiorna il flag di stato
                                ;della routine di invio per aspettare la prossima sequenza completa


            fine:
            CLI
            IRET    
ISR_COUNT12 ENDP                  
                 
INIT_8255   PROC
            ;cwd
            mov al, 10110000b
            out 83h, al
            ;setPC4 porta A input
            mov al, 00001001b
            out 83h, al 
            RET            
INIT_8255   ENDP          

INIT_8253   PROC
            ;init 8253
            
            mov al, 01110100b
            out 63h, al
            mov al, 10110100b
            out 63h, al
            
            mov ax, 999
            out 61h, al
            xchg ah, al
            out 61h, al
            
            mov ax, 399
            out 62h, al
            xchg ah, al
            out 62h, al
   
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
	        MOV AL, 01111101b  ; OCW1   
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
                        
            
block:      ;hlt
            jmp  block
                      
            .exit

            end  ; set entry point and stop the assembler.

