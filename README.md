# Hej

## Motivation

- I like RISC-V assembly
- Debugging with GDB is fun
- Advent of code is also fun

## Quick Start

- If you don't have RISC-V native system:
- To assemble: riscv64-elf-as -o test.o test.s
- To link: riscv64-elf-ld -o test test.o
- To run in QEMU: qemu-riscv64 test day4sample.txt
- If you do have RISC-V system, just as then ld
- No dependancies other than Linux syscalls

## Usage

- Check realbuild.sh to build & run
- If you want to debug, then you do build.sh to assemble, link, and run QEMU on port 1234
- Then you do debug.sh on a different terminal to connect to QEMU with GDB and start debugging

### Run via Nix & CMake

#### On Linux (Native Nix)

```bash
# Enter the development environment
nix develop

# Configure and build
cmake -B build
cmake --build build

# Run the program
qemu-riscv64 build/test day4sample.txt
```

#### On macOS (via Podman/Docker)

> **Note:** Spike-pk is quite outdated on Nixpkgs and QEMU user-mode (`qemu-riscv64`) requires a Linux host environment.

```sh
# Just use a Docker container.
podman run -it --rm -v "$(pwd)":/app -w /app docker.io/nixos/nix \
  nix --experimental-features 'nix-command flakes' develop
```

Then run the linux steps.

## Contributing

- Write neato solutions to other AOC problems and send them to me 😎
