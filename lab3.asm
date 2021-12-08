.model small
.stack 256

.data
    str1 db "Bad input.$",0
    str2 db 201 dup('$')
    str3 db 201 dup('$')
    str4 db 201 dup('$')
.code   

validation proc 
    mov cx, 0
    mov cl, bl
    add di, 2
check:
    mov al, [di]
    cmp al, 'A'
    jl error 
    cmp al, 'Z'
    jg lowReg
    jmp next
lowReg:
    cmp al, 'a'
    jl error
    cmp al, 'z'
    jg error
next:
    inc di
    loop check
    ret
error:
    call badInput
validation endp

badInput proc
    lea dx, str1
    push dx 
    mov dl, 10
    mov ah, 02h
    int 21h 
    pop dx
    mov ah, 09
    int 21h
    mov dl, 10
    mov ah, 02h
    int 21h
    mov ah, 4Ch
    int 21h
badInput endp

clearString proc 
    mov si, offset str3
    add si, 2
    push bx 
clear:
    mov al, [si]
    cmp al, '$'
    je endClear
    mov al, '$'
    inc si
    jmp clear
endClear:
    pop bx
    ret
endp clearString

mainTask proc 
    mov cx, 0
    mov cl, bl
    lea di, str2
    add di, 2
    lea si, str3
    xor bx, bx
    lea bx, str4 
    xor ax, ax
loops:
str3Input:
    mov al, [di]
    mov [si], al
    cmp cx, 1
    je loopend
    cmp al, [di+1]
    je cont
    sub al, 32 
    cmp al, [di+1]
    je cont
    add al, 64
    cmp al, [di+1]
    jne prepare
cont:
    inc di 
    inc si
    loop loops
prepare:
    dec cx
str4Input:
    inc di
    dec cx
    mov al, [di]
    mov [bx], al
    cmp cx, 0
    je loopend
    cmp al, [di+1]
    je str4Cont
    sub al, 32 
    cmp al, [di+1]
    je str4Cont
    add al, 64
    cmp al, [di+1]
    jne compare
str4Cont:
    inc bx
    jmp str4Input
compare:
    push cx
    push si
    push bx
    xor cx, cx 
    xor ax, ax 
    lea si, str3
    lea bx, str4
    mov ax, [si+1]
    mov cx, [bx+1]
    pop bx 
    pop si
    cmp ax, cx 
    jg str4Continue
    lea si, str3
    pop cx 
    inc di
    jmp str3Input

str4Continue:
    lea bx, str4
    pop cx 
    inc di
    jmp str4Input
loopend:
    ret
endp mainTask


lenStr proc
    mov si, offset str3
    mov di, offset str4
    mov bx, 0
    mov cx, 0
str3loop:
    mov al, [si]
    cmp al, '$'
    je str4loop
    inc si
    inc bx 
    jmp str3loop
str4loop:
    mov al, [di]
    cmp al, '$'
    je endLen
    inc di
    inc cx 
    jmp str4loop
endLen:
    cmp bx, cx 
    jg str3Output
    jl str4Output
str3Output:
    mov ax, offset str3
    ret 
str4Output:
    mov ax, offset str4
    ret
endp lenStr 

checker proc
    mov di, ax
    push di
    mov al, [di+1]
    cmp al, '$'
    jne check2
    xor ax, ax 
    lea di, str2 
    mov al, [di+2]
    push ax
    call clearString
    pop ax
    lea di, str3
    mov [di], al
    mov ax, di
    pop di
    ret
check2:
    mov al, [di]
    cmp al, '$'
    je hardcode 
    inc di
    jmp check2
hardcode:
    sub di, 3
    mov al, [di+1] 
    mov cl, [di+2]
    cmp al, cl 
    je hh
    sub al, 32
    cmp al, cl 
    je hh
    add al, 32 
    sub cl, 32
    cmp al, cl 
    je hh
    mov al, [di+1]
    mov [di+2], al
    mov ax, di
    pop di
    ret
hh:
    pop di
    mov ax, di
    ret
endp checker

main proc far 

    mov ax, @data
    mov ds, ax
    mov dx, offset str2
    mov ah, 0Ah
    int 21h
    mov di, dx
    mov bl, [di+1]
    call validation
    call mainTask
    mov dl, 10
    mov ah, 02h
    int 21h 
    call lenStr
    call checker
    xor dx, dx 
    mov dx, ax 
    mov ah, 09h
    int 21h 
    mov ah, 4ch
    int 21h
main endp 
end main