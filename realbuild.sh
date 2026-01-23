#!/usr/bin/env bash
touch test.o
touch test
rm test.o
rm test
riscv64-elf-as -o test.o test.s
riscv64-elf-ld -o test test.o
qemu-riscv64 test day4sample.txt
