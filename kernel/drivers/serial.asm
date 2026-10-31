[bits 64]

%define PORT_COM1 0x3F8

global serial_init
global serial_putchar
global serial_print

; Inicializa a COM1 (38400 baud, 8 bits, sem paridade, 1 stop bit)
serial_init:
    ; 1. Desliga interrupções temporariamente
    mov dx, PORT_COM1 + 1
    mov al, 0x00
    out dx, al

    ; 2. Habilita DLAB (Divisor Latch Access Bit) para configurar a velocidade
    mov dx, PORT_COM1 + 3
    mov al, 0x80
    out dx, al

    ; 3. Configura o Baud Rate para 38400 (Divisor = 3)
    mov dx, PORT_COM1 + 0
    mov al, 0x03            ; Low byte
    out dx, al
    mov dx, PORT_COM1 + 1
    mov al, 0x00            ; High byte
    out dx, al

    ; 4. Configura 8 bits, sem paridade, 1 stop bit (8N1) e desliga DLAB
    mov dx, PORT_COM1 + 3
    mov al, 0x03
    out dx, al

    ; 5. Habilita e limpa as filas FIFO (14-byte threshold)
    mov dx, PORT_COM1 + 2
    mov al, 0xC7
    out dx, al

    ; 6. Configura o Modem Control (RTS/DTR ativos)
    mov dx, PORT_COM1 + 4
    mov al, 0x0B
    out dx, al
    ret

; Verifica se o buffer de transmissão está vazio (Bit 5 do LSR)
serial_is_transmit_empty:
    mov dx, PORT_COM1 + 5
    in al, dx
    and al, 0x20
    ret

; Envia um único caractere (Caractere recebido em AL)
serial_putchar:
    push rax
    push rdx
.wait_loop:
    call serial_is_transmit_empty
    cmp al, 0
    je .wait_loop

    mov dx, PORT_COM1
    pop rdx
    pop rax
    out dx, al
    ret

; Envia uma string completa (Ponteiro da string em RDI)
serial_print:
    push rsi
    push rax
    mov rsi, rdi
.loop:
    lodsb
    test al, al
    jz .done
    call serial_putchar
    jmp .loop
.done:
    pop rax
    pop rsi
    ret
