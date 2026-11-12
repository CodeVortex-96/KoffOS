OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)

PHDRS
{
    headers PT_PHDR PHDRS;
    text    PT_LOAD FILEHDR PHDRS FLAGS((1 << 0) | (1 << 2)); /* R-X */
    rodata  PT_LOAD FLAGS((1 << 2));                         /* R-- */
    data    PT_LOAD FLAGS((1 << 1) | (1 << 2));              /* RW- */
}

SECTIONS
{
    /* Endereço virtual Higher-Half exigido pelo protocolo Limine */
    . = 0xffffffff80000000;

    . += SIZEOF_HEADERS;

    .text : ALIGN(0x1000) {
        *(.text._start)
        *(.text*)
    } :text

    .rodata : ALIGN(0x1000) {
        *(.rodata*)
    } :rodata

    .data : ALIGN(0x1000) {
        *(.data*)
    } :data

    .bss : ALIGN(0x1000) {
        *(COMMON)
        *(.bss*)
    } :data

    /DISCARD/ : {
        *(.note*)
        *(.comment*)
    }
}
