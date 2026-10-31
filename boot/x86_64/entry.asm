[bits 64]
global _start
extern serial_init
extern serial_print
extern kof_main

section .text._start
_start:
    cli
    mov rsp, stack_top
    push 0
    popfq

    ; 1. Inicializa a porta serial COM1
    call serial_init

    ; 2. Envia mensagem de log inicial
    mov rdi, msg_boot
    call serial_print

    ; 3. Executa o cálculo dinâmico da tela e do framebuffer (se o ponteiro for passado)
    ; mov rdi, rsi ; Ponteiro da struct do framebuffer vinda do bootloader
    ; call detect_and_setup_display

    ; 4. Salta para a função principal da KOF via FFI nativa!
    call kof_main

.hang:
    cli
    hlt
    jmp .hang

; --- Rotina de Cálculo Dinâmico de Vídeo (Embutida no Entry) ---
global detect_and_setup_display
detect_and_setup_display:
    push rbx
    push rcx

    ; 1. Lê largura (Width) e altura (Height) da struct do framebuffer
    mov ecx, dword [rdi + 0]    ; Width (ex: 1600 no T440p)
    mov edx, dword [rdi + 4]    ; Height (ex: 900)
    movzx ebx, word [rdi + 8]   ; BPP - Bits por pixel (ex: 32 bits)

    ; 2. Calcula Bytes por Pixel (BPP / 8)
    shr ebx, 3                  ; ebx = 32 / 8 = 4 bytes por pixel (ARGB)

    ; 3. Calcula o Pitch Dinâmico (Bytes por linha = Largura * Bytes por Pixel)
    mov eax, ecx                ; Copia largura para EAX
    imul eax, ebx               ; EAX = Largura * 4 (Pitch real da linha)
    
    ; Salva o pitch calculado de volta na struct
    mov dword [rdi + 12], eax   

    ; 4. Calcula o Tamanho Total do Buffer (Tamanho = Pitch * Altura)
    imul eax, edx               ; EAX = Pitch * Altura (Tamanho total em bytes)

    pop rcx
    pop rbx
    ret

section .rodata
msg_boot: db "KoffOS [v0.1] - COM1 + Display Engine Online.", 13, 10, 0

section .bss
align 16
stack_bottom:
    resb 16384
stack_top:
