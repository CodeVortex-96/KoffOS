# ADR 0001 — KoffOS Kernel Architecture

## Status
Accepted

## Context

KoffOS is an independent operating system project.
Its first major milestone is the development of an original
bare-metal kernel.

The project must maintain architectural independence from
the host operating system and from compiler-specific boot
implementations.

## Decisions

### Kernel architecture
- Monolithic modular kernel.
- Internal subsystems communicate through explicit interfaces.
- Hardware-specific code is isolated from architecture-independent
  kernel logic.

### Initial target
- Architecture: x86_64.
- Execution environment: bare metal.
- Initial testing platform: QEMU.
- Primary implementation language: KOF.

### Boot architecture
- The boot process will be independently implemented.
- The bootloader and kernel will have a clearly defined contract.
- Boot protocol selection remains open.

### Engineering principles
- Explicit interfaces and responsibilities.
- Incremental implementation.
- Testable subsystems.
- Documented architectural decisions.
- No unnecessary dependencies on host operating systems.

## Initial milestone

A bootable kernel capable of:
- Initializing the execution environment.
- Producing serial diagnostic output.
- Receiving and validating memory map information.
- Initializing the hardware abstraction layer.
- Handling fatal errors and halting safely.

## Open decisions

- BIOS or UEFI boot support.
- Bootloader-to-kernel calling convention.
- Kernel binary format and linker strategy.
- KOF freestanding runtime requirements.
- Memory management architecture.
