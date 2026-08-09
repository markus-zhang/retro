;------------------------|
; DEMONSTRSATE REP       |
;------------------------|

.8086
.model small
; .code

;------------------------|
; BEGIN STACK SEGMENT    |
;------------------------|
MyStack     SEGMENT STACK           ; STACK word ensures loading of SS by DOS
            DB 64 DUP ('STACK!!!')  ; This reserves 512 bytes for the stack (64 * 8 characters from "STACK!!!")
MyStack     ENDS
;------------------------|
;   END STACK SEGMENT    |
;------------------------|


;------------------------|
; BEGIN  DATA SEGMENT    |
;------------------------|
MyData      SEGMENT

Eatl        DB "Eat at Joe's...",'$'
CRLF        DB 0DH,0AH,'$'          ; Carriage Return + Line Feed

MyData      ENDS
;------------------------|
; END DATA SEGMENT       |
;------------------------|

;------------------------|
; BEGIN  CODE SEGMENT    |
;------------------------|

; MOVSB: Move byte from DS:SI to ES:DI
; We first copy SS into DS, as SS points to the stack.
; This is to "borrow" the contents on the stack (STACK!!!).
; Then we try to use REP MOVSB to move bytes to CGA base address.
; CGA text mode base address is 0B8000H,
; so it is B800H:0000H.
; This means we need to move B800H into ES before invoking MOVSB.
; We also need to set CX as it controls the number of bytes to MOVSB.

; Misc
; INT 10H with AH=0 sets a graphic mode through BISO, which clears the screen
; Set AL=03H for text mode 80x25 16 colours


MyProg      SEGMENT
            assume CS:MyProg,DS:MyData

CLS         PROC
            mov     AX, 0003H
            int     10H
            ret
CLS         ENDP

Main        PROC

Start:      ; This is where program execution begins:

            ; Clear screen
            call    CLS

            ; Save all registers that we are going to touch
            push    DS
            push    ES

            mov     AX, SS
            mov     DS, AX

            ; Note that this most likely will create display artifacts,
            ; because CGA text requires 8-bit for the char, and 8-bit for the format.
            ; Since we are simply putting whatever on the stack  (STACK!!!) into the display buffer,
            ; there is no consideration of format byte.
            ; But I think this experiment should clear the screen and show you some colorful texts!
            mov     AX, 0B800H
            mov     ES, AX

            ; Set SI and DI to 0 (not mandatory but I just want to copy from 0 to 0)
            mov     SI, 0
            mov     DI, 0

            ; Set CX as it is the counter, say 32 bytes
            mov     CX, 20H

            ; Repetitively MOVSB
            rep movsb

            pop     ES
            pop     DS

            ; mov     AX, MyData      ; Set up data segment address in DS
            ; mov     DS, AX          ; Must load segment register from a general register (mov DS, MyData is illegal)

            ; lea     DX, Eatl        ; Load offset of Eatl message string into DX
            ; mov     AH, 09H         ; Select DOS service 09H: Print String
            ; int     21H             ; Call DOS interupt

            ; lea     DX, CRLF        ; Load offset of CRLF string into DX
            ; mov     AH, 09H
            ; int     21H

            mov     AH, 4CH         ; Stop the current process. Program hangs if missing this part
            int     21H

Main        ENDP

MyProg      ENDS

;------------------------|
; END CODE SEGMENT       |
;------------------------|

            END     Start