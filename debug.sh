#!/usr/bin/env bash
riscv64-elf-gdb -ex 'target remote :1234' -ex 'watch $t6' -ex 'condition 1 $t6==64'
