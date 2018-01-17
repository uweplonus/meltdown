bits 64

section .bss
    scratch: resb 32

section .text
    global printqw
    global printdw
    global printw
    global printb
    global printhqw
    global printhdw
    global printhw
    global printhb

; Format the quad word in RAX decimal
; - in
; RAX: value to format
; RDI: address for the formatted string
; - out
; RDI - points to the first byte after the number
; RDX: number of bytes written (out)
printqw:
    pushfq
    cld
    push RCX         ; save RCX for restore
    push RAX         ; save RAX for restore
    push RDI         ; save RDI for later usage
    mov  RDI,scratch
    mov  RCX,10      ; move the divisor to RCX
next:
    xor  RDX,RDX     ; clear RDX
    cmp  RAX,0x00    ; test if we are done
    je   done
    div  RCX
    push RAX         ; save RAX temporarily
    mov  RAX,RDX     ; move the figure to print to RAX
    call printhn
    pop  RAX         ; restore RAX
    jmp  next        ; next round
done:
    cmp  RDI,scratch ; did we write any byte?
    jne  end_printqw ; if we wrote any byte go to end processing
    mov  AL,0x30     ; add a 0 to the scratch area
    stosb
end_printqw:
    mov  RCX,RDI
    sub  RCX,scratch ; calculate the number of characters written
    mov  RDX,RCX
    mov  RSI,RDI
    dec  RSI
    pop  RDI         ; get the address for output back again
reverse:
    mov  AL,[RSI]    ; move one byte from the source to the destination
    mov  [RDI],AL    ; movs does not work here because we inc RDI and dec RSI
    dec  RSI         ; adjust the pointers
    inc  RDI
    loop reverse
    pop  RAX         ; restore RAX
    pop  RCX         ; restore RCX
    popfq
    ret

; Format the double word in EAX decimal
; - in
; EAX: value to format
; RDI: address for the formatted string
; - out
; RDI - points to the first byte after the number
; RDX: number of bytes written (out)
printdw:
    push RCX         ; save RCX for restore
    push RAX         ; save RAX for restore
    xor  RCX,RCX     ; clear RCX
    mov  ECX,EAX     ; move the value to ECX to clear upper 32 bits
    mov  RAX,RCX
    call printqw
    pop  RAX         ; restore RAX
    pop  RCX         ; restore RCX
    ret

; Format the word in AX decimal
; - in
; AX: value to format
; RDI: address for the formatted string
; - out
; RDI - points to the first byte after the number
; RDX: number of bytes written (out)
printw:
    push RCX         ; save RCX for restore
    push RAX         ; save RAX for restore
    xor  RCX,RCX     ; clear RCX
    mov  CX,AX       ; move the value to CX to clear upper 48 bits
    mov  RAX,RCX
    call printqw
    pop  RAX         ; restore RAX
    pop  RCX         ; restore RCX
    ret

; Format the byte in AL decimal
; - in
; AL: value to format
; RDI: address for the formatted string
; - out
; RDI - points to the first byte after the number
; RDX: number of bytes written (out)
printb:
    push RCX         ; save RCX for restore
    push RAX         ; save RAX for restore
    xor  RCX,RCX     ; clear RCX
    mov  CL,AL       ; move the value to CL to clear upper 56 bits
    mov  RAX,RCX
    call printqw
    pop  RAX         ; restore RAX
    pop  RCX         ; restore RCX
    ret

; Format the quad_word in RAX in hex
; - in
; RAX: value to format
; RDI: address for the formatted string
; - out
; RDI - points to the first byte after the number
printhqw:
    push RAX          ; save RAX for the lower double word
    shr  RAX,32       ; get the higher double word
    call printhdw
    mov  RAX,[RSP]    ; get the value back
    call printhdw
    pop  RAX          ; restore RAX
    ret

; Format the word in EAX in hex
; - in
; EAX: value to format
; RDI: address for the formatted string
; - out
; RDI - points to the first byte after the number
printhdw:
    push RAX          ; save RAX for the lower word
    shr  EAX,16       ; get the higher word
    call printhw
    mov  RAX,[RSP]    ; get the value back
    call printhw
    pop  RAX          ; restore the value
    ret

; Format the word in AX in hex
; - in
; AX: value to format
; RDI: address for the formatted string
; - out
; RDI - points to the first byte after the number
printhw:
    push RAX          ; save RAX for the lower byte
    shr  AX,8         ; get the higher byte
    call printhb
    mov  RAX,[RSP]    ; get the value back
    call printhb
    pop  RAX          ; restore the value
    ret

; Format the byte in AL in hex
; - in
; AL: value to format
; RDI: address for the formatted string
; - out
; RDI - points to the first byte after the number
printhb:
    push RAX          ; save RAX for the lower nibble
    shr  AL,4         ; get the higher nibble
    call printhn
    mov  RAX,[RSP]    ; get the value back
    call printhn
    pop  RAX          ; restore the value
    ret

; Format the nibble in the lower half of AL in hex
; - in
; AL: value to format
; RDI: address for the formatted string
; - out
; RDI - points to the first byte after the number
; - modified
; AL
printhn:
    pushfq
    and  AL,0xf       ; mask the lower nibble
    cmp  AL,0xa       ; compare AL with 0xa, lower values need another handling
    jge  print_af     ; than 0xa or higher values
    add  AL,0x30      ; add 0x30 to get the ACSII character for the numbers 0-9
    jmp  store
print_af:
    add  AL,0x57      ; add 0x57 to get the ASCII character for the number a-f
store:
    cld
    stosb             ; store the character in the target
    popfq
    ret
