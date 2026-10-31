[bits 64]
%define PORT_COM1 0x3F8

global serial_getchar

; Lê um caractere da COM1 em modo polling
serial_getchar:
    push rdx
.wait_data:
    mov dx, PORT_COM1 + 5    ; Line Status Register (LSR)
    in al, dx
    and al, 0x01             ; Verifica se o bit 0 (Data Ready) está ativo
    jz .wait_data

    mov dx, PORT_COM1        ; Data Register (RBR)
    in al, dx
    pop rdx
    ret
