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
MyProg      SEGMENT
            assume CS:MyProg,DS:MyData
Main        PROC

Start:      ; This is where program execution begins:

            mov     AX, MyData      ; Set up data segment address in DS
            mov     DS, AX          ; Must load segment register from a general register (mov DS, MyData is illegal)

            lea     DX, Eatl        ; Load offset of Eatl message string into DX
            mov     AH, 09H         ; Select DOS service 09H: Print String
            int     21H             ; Call DOS interupt

            lea     DX, CRLF        ; Load offset of CRLF string into DX
            mov     AH, 09H
            int     21H

            mov     AH, 4CH         ; Stop the current process. Program hangs if missing this part
            int     21H

Main        ENDP

MyProg      ENDS

;------------------------|
; END CODE SEGMENT       |
;------------------------|

            END     Start