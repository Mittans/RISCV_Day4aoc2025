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
## Contributing
- Write neato solutions to other AOC problems and send them to me 😎
