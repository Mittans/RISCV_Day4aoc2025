cmake_minimum_required(VERSION 3.10)
project(RiscV_Test LANGUAGES NONE)

find_program(RISCV_AS NAMES riscv64-unknown-elf-as riscv64-linux-gnu-as riscv64-none-elf-as riscv64-elf-as)
find_program(RISCV_LD NAMES riscv64-unknown-elf-ld riscv64-linux-gnu-ld riscv64-none-elf-ld riscv64-elf-ld)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/test.o
    COMMAND ${RISCV_AS} -o ${CMAKE_CURRENT_BINARY_DIR}/test.o ${CMAKE_CURRENT_SOURCE_DIR}/test.s
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/test.s
)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/test
    COMMAND ${RISCV_LD} -o ${CMAKE_CURRENT_BINARY_DIR}/test ${CMAKE_CURRENT_BINARY_DIR}/test.o
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/test.o
)

add_custom_target(build_test ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/test)
