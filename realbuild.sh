#!/usr/bin/env bash
touch test.o
touch test
rm test.o
rm test
mv day4sample.txt _day4sample.txt
mv day4.txt day4sample.txt
riscv64-elf-as --gdwarf-5 -o test.o test.s
riscv64-elf-ld -o test test.o
qemu-riscv64 test day4sample.txt
echo $?
mv day4sample.txt day4.txt
mv _day4sample.txt day4sample.txt
