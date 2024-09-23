# Q1

### a) At what address is the Boot ROM loaded by QEMU?  
**Ans**: QEMU loads the Boot ROM at address location `0x1000`.

### b) At a high-level, what are the steps taken by the loaded Boot ROM?  
**Ans**: The Boot ROM is the first piece of code that is executed when the CPU starts. It initializes the CPU state and then loads the bootloader. The bootloader sets up the stack necessary for execution of C code and enters the start function.

### c) What address does our Boot ROM jump to at the end of its execution?  
**Ans**: The Boot ROM jumps to address `0x80000000` at the end of its execution.

# Q2

### a) What is the specified entry function of the bootloader in the linker descriptor?  
**Ans**: `_entry` is the specified entry function in the linker descriptor of the bootloader (`bootloader.ld`).

### b) Once your linker descriptor is correctly specified, how can you check that your bootloader’s entry function starts to execute after the Boot ROM code?  
**Ans**: The Boot ROM jumps to location `0x80000000`, where the first instruction of the bootloader is loaded. Since the `_entry` function is the first piece of code that the bootloader runs, it is loaded at location `0x80000000`. This can be verified using GDB:

```bash
(gdb) 
0x0000000080000000 in _entry ()
=> 0x0000000080000000 <_entry+0>:	17 11 00 00	auipc	sp,0x1
```

# Q3

### a) What happens if you jump to C code without setting up the stack and why?  
**Ans**: If the stack isn't set up, the Boot ROM loads the `_entry` function of the bootloader at `0x80000000` correctly but doesn't execute it. The CPU requires a stack to execute instructions, and without it, the CPU would just keep spinning without progressing.

### b) How would you set up the stack if your system had 2 CPU cores instead of 1?  
**Ans**: Each core would have its own stack pointer and register set. The `bl_stack` is an array with the size `NCPU * STSIZE`, where `NCPU` is the number of cores and `STSIZE` is the size of the stack. The hart ID of each core is stored in the core's corresponding register, and each stack pointer is set to an offset calculated as the product of the hart ID and the stack size. This way, multiple stack pointers point to different locations in the `bl_stack` array, dividing the array into different stacks for each core.

# Q4

### a) By looking at the start function, explain how privilege is being switched from M-mode to S-mode in the mstatus register. What fields in the register are being updated and why?  
**Ans**: The `start()` function manipulates the `mstatus` register to change the privilege mode from M-mode to S-mode. The `mstatus` register contains the `MPP` (Machine Previous Privilege) field, which specifies what privilege level to return to when handling an exception or interrupt.

In the `start()` function, this is how the switch happens:

```bash
unsigned long x = r_mstatus(); # reads the mstatus register
x &= ~MSTATUS_MPP_MASK;        # clears the MPP field
x |= MSTATUS_MPP_S;            # sets it to S-Mode by specifying the correct bit value
w_mstatus(x);                  # writes back the value to the mstatus register
```

# Q5

### a) How does `kernel_copy` work? Please document its steps.  
**Ans**: The `kernel_copy` function works by copying the kernel binary from the RAMDISK to a buffer in memory.

1. It first checks if the requested block number is valid.
2. It calculates the source address in the RAMDISK based on the requested block number.
3. It copies a block of memory of `BSIZE` bytes from the address in the RAMDISK to the buffer's `data` field.

The `kernel_copy` function is used to copy all blocks of data one by one using a loop.
