OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)

PHDRS
{
    headers PT_PHDR PHDRS;
    text    PT_LOAD FILEHDR PHDRS FLAGS((1 << 0) | (1 << 2)); /* R-X */
    rodata  PT_LOAD FLAGS((1 << 2));                         /* R-- */
    data    PT_LOAD FLAGS((1 << 1) | (1 << 2));             /* RW- */
}

SECTIONS
{
    . = 1M;

    .text : {
        *(.text._start)
        *(.text*)
    } :text

    .rodata : {
        *(.rodata*)
    } :rodata

    .data : {
        *(.data*)
    } :data

    .bss : {
        *(COMMON)
        *(.bss*)
    } :data

    /DISCARD/ : {
        *(.note*)
        *(.comment*)
    }
}
