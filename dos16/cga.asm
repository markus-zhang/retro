;------------------------------------------------------------------------------|
; Demonstrate CGA graphics 320x240 4-color mode functionalities:
; - Save current CGA mode register and restore them back before exit
; - Display color blocks on screen
; - Draw lines on screen
; - Load CGA graphics into memory and blit on screen
;------------------------------------------------------------------------------|

.8086
.model small

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

CGA_BASE    DW 0B800H

AX_MODE     DW 0004H
AH_CGA      DB 0BH
BX_WARM     DW 0100H
BX_COOL     DW 0101H

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

CLS         PROC
            mov     AX, 0003H
            int     10H
            ret
CLS         ENDP

; Delay 1 second
DELAY_SEC   PROC
            mov     CX, 0FH
            mov     DX, 04240H
            mov     AH, 86H
            int     15H
            ret
DELAY_SEC   ENDP

SET_CGA     PROC
            mov     AH, 0           ; Set CGA 320x200 4 volor mode
            mov     AL, 4
            int     10H
            ret
SET_CGA     ENDP

SET_WARM    PROC
            mov     AH, AH_CGA
            mov     BX, BX_WARM
            int     10H
            ret
SET_WARM    ENDP


SET_COOL    PROC
            mov     AH, AH_CGA
            mov     BX, BX_COOL
            int     10H
            ret
SET_COOL    ENDP

; Low intensity, call after cool/warm is set
SET_LOW     PROC
            mov     AH, AH_CGA
            mov     BH, 0
            mov     BL, 0
            int     10H
            ret
SET_LOW     ENDP

; Restore CGA 80x25 text mode
SET_TEXT    PROC
            mov     AX, 2           ; Set CGA 80x25 mode
            int     10H
            ret
SET_TEXT    ENDP



Main        PROC

Start:      ; This is where program execution begins:

            ; Clear screen
            call    CLS
            ; Set CGA 320x200
            call    SET_CGA
            ; Select cool palette
            call    SET_WARM
            ; Select low intensity
            call    SET_LOW

            ; Save all registers that we are going to touch
            push    DS
            push    ES

            mov     AX, SS
            mov     DS, AX

            ; Draw some pixels (03H) on screen
            ; 320x200 = 64,000 bytes < 1 page
            ; STOSB: Store byte in AL into ES:[DI]
            ; So we need to load CGA Base address to ES, and set DI to 0
            ; We use CX as REP counter, so CX = FA00H (64,000)
            ; For AL we pick 3, one of the colors
            mov     AX, CGA_BASE
            mov     ES, AX
            xor     DI, DI
            mov     CX, 04000H
            mov     AX, 0AAAAH

            ; Repetitively MOVSB
            rep stosb

            ; Delay a few second
            call    DELAY_SEC
            call    DELAY_SEC
            call    DELAY_SEC

            ; Restore segment registers
            pop     ES
            pop     DS

            ; Restore Text mode
            call SET_TEXT

            ; Exit
            mov     AH, 4CH         ; Stop the current process. Program hangs if missing this part
            int     21H

            ; mov ax, 4           ; set CGA 320x200
            ; int 10h

            ; mov ah, 0Bh         ; set the cool palette
            ; mov bx, 0101h       ; (cyan, magenta, white)
            ; int 10h

            ; xor bx, bx          ; low intensity, black background
            ; int 10h

            ; mov ax, 0B800h      ; draw some pixels in each colour
            ; mov es, ax
            ; mov di, 0
            ; mov bx, 320
            ; xor ax, ax
            ; mov cx, bx
            ; rep stosw
            ; inc ax
            ; mov cx, bx
            ; rep stosw
            ; inc ax
            ; mov cx, bx
            ; rep stosw
            ; inc ax
            ; mov cx, bx
            ; rep stosw

            ; mov ah, 1           ; wait for a character
            ; int 21h

            ; mov ah, 0Bh
            ; mov bx, 0010h       ; high intensity
            ; int 10h

            ; mov ah, 1           ; wait for a character
            ; int 21h

            ; mov ah, 0Bh         ; set the warm palette
            ; mov bx, 0100h       ; (red, green, brown)
            ; int 10h

            ; mov ah, 1           ; wait for a character
            ; int 21h

            ; mov ah, 0Bh
            ; xor bx, bx          ; low intensity
            ; int 10h

            ; mov ah, 1           ; wait for a character
            ; int 21h

            ; mov ax, 4C00h       ; exit
            ; int 21h

Main        ENDP

MyProg      ENDS

;------------------------|
; END CODE SEGMENT       |
;------------------------|

            END     Start