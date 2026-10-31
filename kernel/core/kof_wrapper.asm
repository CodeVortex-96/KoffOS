[bits 64]
section .text
global kof_main
kof_main:
    incbin "build/kof_payload.bin"
