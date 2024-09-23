# _entry should be the first function invoked when
# the QEMU CPU starts executing. It's location should
# according to the memory layout provided in param.h

.section .text
.global _entry
_entry:
        # task: setup a per-CPU stack for C and jump to start() function
        la sp, bl_stack  # load the base address of the bl_stack array
        li a0, 4096      # load the stack size(4kB) in the register a0
        csrr a1, mhartid # load the hart ID of the core into register a1
        addi a1, a1, 1   # if hard id starts from zero
        mul a0, a0, a1   # calculate the stack offset
        add sp, sp, a0   # set the stack pointer to the end of the selected core's stack
        call start

spin:
        j spin
