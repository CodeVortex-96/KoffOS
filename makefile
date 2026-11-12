AS = nasm
LD = ld
KOF = kof

CFLAGS_AS = -f elf64
LDFLAGS = -T linker/x86_64.ld -nostdlib

SRC_BOOT = boot/x86_64/entry.asm
SRC_SERIAL = kernel/drivers/serial.asm
SRC_SERIAL_READ = kernel/drivers/serial_read.asm

OBJ_ENTRY = build/entry.o
OBJ_SERIAL = build/serial.o
OBJ_SERIAL_READ = build/serial_read.o
OBJ_KOF = build/kof_object.o
OBJ_STUBS = build/stubs.o

TARGET = koffos_final.elf

all: directories kof_compile kernel iso

directories:
	mkdir -p build/Default

kof_compile:
	@echo "[*] Compilando payload KOF em modo freestanding..."
	# Aponte para o diretório que realmente contém os arquivos .kf do projeto (ex: kernel/core ou onde o main.kf mora)
	$(KOF) build kernel/core --target native --profile freestanding || true
	if [ -f build/Default/Main.s ]; then as build/Default/Main.s -o $(OBJ_KOF); fi

build/stubs.o: kernel/core/stubs.c
	gcc -ffreestanding -mno-red-zone -c kernel/core/stubs.c -o $@

kernel: $(OBJ_ENTRY) $(OBJ_SERIAL) $(OBJ_SERIAL_READ) $(OBJ_STUBS)
	@echo "[*] Linkando o KoffOS Kernel e resolvendo símbolos..."
	$(LD) $(LDFLAGS) -o build/$(TARGET) $(OBJ_ENTRY) $(OBJ_SERIAL) $(OBJ_SERIAL_READ) $(OBJ_STUBS) $(OBJ_KOF)
	cp build/$(TARGET) koffos_final.elf
	cp build/$(TARGET) koffos.elf

build/entry.o: $(SRC_BOOT)
	$(AS) $(CFLAGS_AS) $< -o $@

build/serial.o: $(SRC_SERIAL)
	$(AS) $(CFLAGS_AS) $< -o $@

build/serial_read.o: $(SRC_SERIAL_READ)
	$(AS) $(CFLAGS_AS) $< -o $@

iso: kernel
	mkdir -p build/iso_root/boot
	cp build/koffos_final.elf build/iso_root/boot/koffos.elf
	cp boot/x86_64/limine.cfg build/iso_root/boot/limine.conf

	# Copia os arquivos necessários do Limine (incluindo o Stage 3)
	cp /usr/share/limine/limine-bios.sys build/iso_root/boot/
	cp /usr/share/limine/limine-bios-cd.bin build/iso_root/boot/
	cp /usr/share/limine/limine-uefi-cd.bin build/iso_root/boot/
	cp /usr/share/limine/BOOTX64.EFI build/iso_root/boot/

	# Cria a imagem ISO bootável
	xorriso -as mkisofs -b boot/limine-bios-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		--efi-boot boot/limine-uefi-cd.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		build/iso_root -o build/koffos.iso

	# Instala o bootloader BIOS do Limine na imagem ISO gerada
	limine bios-install build/koffos.iso
	@echo "[*] ISO bootável gerada e assinada pelo Limine em build/koffos.iso!"

clean:
	rm -rf build/*.o build/*.elf koffos*.elf build/iso_root

.PHONY: all directories kof_compile kernel iso clean
