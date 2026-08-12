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

; ASCIIZ string, must end with a zero byte.
Filename    DB "openfile.txt", 0
; Buffer      DB 64 DUP ('@')         ; Create an easy to identify buffer
Buffer      DW 0B800H

MyData      ENDS
;------------------------|
; END DATA SEGMENT       |
;------------------------|

;------------------------|
; BEGIN  CODE SEGMENT    |
;------------------------|
MyProg      SEGMENT
            assume CS:MyProg,DS:MyData

;           Clear screen routine
CLS         PROC
            mov     AX, 0003H
            int     10H
            ret
CLS         ENDP

Main        PROC

Start:      ; Please (T)race this program in DEBUG

            call CLS

            ; DS:DX = Segment:offset of ASCIIZ file specification
            mov     AX, MyData      ; Set up data segment address in DS
            mov     DS, AX          ; Must load segment register from a general register
            lea     DX, Filename    ; Load offset of Filename string into DX

            ; Invoke system call
            xor     AX, AX          ; This sets AL to 0, too, for read-only mode
            mov     AH, 3DH         ; Select DOS service 09H: Print String
            int     21H             ; Call DOS interupt

            ; Now, visually check CF -- CF is cleared if successful
            ; If successful, AX should now contains the file handle

            ; Now we read a few bytes from the file
            ; DS:DX = Segment:offset of buffer area
            mov     BX, AX          ; BX must contain the file handle
            xor     DX, DX          ; set offset to 0
            mov     AX, Buffer      ; Point DS to CGA Base Address
            mov     DS, AX
            mov     CX, 10H         ; Read 16 bytes

            ; Invoke system call
            xor     AX, AX          ; This sets AL to 0, too, for read-only mode
            mov     AH, 3FH         ; Select DOS service 09H: Print String
            int     21H             ; Call DOS interupt

            ; Now display AX
            ; lea     DX, Buffer


            ; Exit properly
            mov     AH, 4CH         ; Stop the current process. Program hangs if missing this part
            int     21H

Main        ENDP

MyProg      ENDS

;------------------------|
; END CODE SEGMENT       |
;------------------------|

            END     Start