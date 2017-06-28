# --------
# Hardware
# --------

# Opcode - operational code
# Assebly mnemonic - abbreviation for an operation

# Instruction Code Format (IA-32)
# - Optional instruction prefix
# - Operational code
# - Optional modifier(s)
# - Optional data element(s)

# Micro operations (micro-ops or μops) are detailed low-level instructions 
# used in some designs to implement complex machine instructions

# The main components in the processor are:

# - Control unit
# |__ Retrieve instructions from memory.
# |__ Decode instructions for operation.
# |__ Retrieve data from memory as needed.
# |__ Store the results as necessary.
# |__ Instruction prefetch and decoding
# |__ Branch prediction (Branch prediction unit)
# |__ Out-of-order execution (Out-of-order execution engine)
# |__ Retirement

# - Execution unit
# |__ Simple-integer operations (Low-latency integer execution unit: add, sub)
# |__ Complex-integer operations (Complex-integer execution unit: mult, rotat)
# |__ Floating-point operations (+ MMX, SSE (XMM registers))

# - Registers
# |__ General purpose (Eight 32-bit registers used for storing working data)
#     |__ EAX (RAX for 64-bit) Accumulator for operands and results data
#     |__ EBX Pointer to data in the data memory segment
#     |__ ECX Counter for string and loop operations
#     |__ EDX I/O pointer
#     |__ EDI Data pointer for destination of string operations
#     |__ ESI Data pointer for source of string operations
#     |__ ESP Stack pointer
#     |__ EBP Stack data pointer
#             ESP is the top of the stack.
#             EBP is usually set to esp at the start of the function.
#             Local variables are accessed by subtracting a constant 
#             offset from ebp. All x86 calling conventions define ebp 
#             as being preserved across function calls. ebp itself
#             actually points to the previous frame's base pointer,
#             which enables stack walking in a debugger and viewing 
#             other frames local variables to work

# |__ Segment (Six 16-bit registers used for handling memory access)
#     |__ Flat memory model
#     |__ Segmented memory model
#     |__ Real-address mode
#     |__ CS (Code segment)
#     |__ DS (Data segment)
#     |__ SS (Stack segment)
#     |__ ES (Extra segment pointer)
#     |__ FS (Extra segment pointer)
#     |__ GS (Extra segment pointer)

# |__ Instruction pointer (32-bit register pointing to next instruction code)
#      EIP register, sometimes called the program counter
#      In a flat memory model, the instruction pointer contain
#      the linear address of the memory location for the next
#      instruction code. If the application is using a segmented
#      memory model, the instruction pointer points to a logical
#      memory address, referenced by the contents of the CS register

# |__ Floating-point data (Eight 80-bit registers for floating-point data)

# |__ Control (Five 32-bit registers used to determine the operating mode)
#     |__ CR0 (System flags that control  mode and states of the processor)
#     |__ CR1 (Not currently used)
#     |__ CR2 (Memory page fault information)
#     |__ CR3 (Memory page directory information)
#     |__ CR4 (Flags enable processor features and indicate capabilities)

# |__Debug Eight (32-bit registers used to contain information when
#                 debugging the processor)

# - Flags
# |__Status flags
#    |__ CF 0 Carry flag
#    |__ PF 2 Parity flag
#    |__ AF 4 Adjust flag
#    |__ ZF 6 Zero flag
#    |__ SF 7 Sign flag
#    |__ OF 11 Overflow flag
#  
# |__Control flags
#    |__ DF flag, or direction flag (DF flag is set (set to one), string
#        instructions automatically decrement memory addresses to get
#        the next byte in the string. When the DF flag is cleared
#        (set to zero), string instructions automatically increment
#        memory addresses to get the next #  byte in the string
#
# |__System flags
#    |__ TF 8 Trap flag
#    |__ IF 9 Interrupt enable flag
#    |__ IOPL 12 and 13 I/O privilege level flag
#    |__ NT 14 Nested task flag
#    |__ RF 16 Resume flag
#    |__ VM 17 Virtual-8086 mode flag
#    |__ AC 18 Alignment check flag
#    |__ VIF 19 Virtual interrupt flag
#    |__ VIP 20 Virtual interrupt pending flag
#    |__ ID 21 Identification flag


# -----------
# Compilation
# -----------

# as cpuid.s -o cpuid.o && ld cpuid.o -o cpuid

# or rename "_start" to "main" and run
# gcc cpuid.s -o cpuid 

# "-gstabs" extra debug info to help gdb walk through the source code
# as -gstabs -o cpuid.o cpuid.s 

# -----------
# AT&T Syntax
# -----------

# - AT&T immediate operands use a $ to denote them, whereas Intel immediate 
#   operands are undelimited. Thus, when referencing the decimal value 4 in 
#   AT&T syntax, you would use $4 , and in Intel syntax you would just use 4.

# - AT&T prefaces register names with a % , while Intel does not. 
#   Thus, referencing the EAX register in AT&T syntax, you would use %eax .

# - AT&T syntax uses the opposite order for source and destination operands. 
#   To move the decimal value 4 to the EAX register, AT&T syntax would be 
#   movl $4, %eax , whereas for Intel it would be mov eax, 4 .

# - AT&T syntax uses a separate character at the end of mnemonics to reference 
#  the data size used in the operation, whereas in Intel syntax the size is 
#  declared as a separate operand. The AT&T instruction movl $test, %eax is 
#  equivalent to mov eax, dword ptr test in Intel syntax.

# - Long calls and jumps use a different syntax to define the segment and 
#   offset values. AT&T syntax uses ljmp $section, $offset , whereas Intel 
#   syntax uses jmp section:offset .


# Sections:
# A data section
# A bss section
# A text section
.section .data
output:
    .ascii "The processor Vendor ID is 'xxxxxxxxxxxx'\n"

.section .bss
    .lcomm buffer, 12

.section .text
.globl _start
_start:
    movl $0, %ebx
    int $0x80

# DATA
# ----
.ascii # Text string
.asciz # Null-terminated text string
.byte # Byte value
.double # Double-precision floating-point number
.float # Single-precision floating-point number
.int # 32-bit integer number
.long # 32-bit integer number (same as .int)
.octa # 16-byte integer number
.quad # 8-byte integer number
.short # 16-bit integer number
.single # Single-precision floating-point number (same as .float)

# Arrays-like
sizes:
.long 100,150,200,250,300

# Knowing that each long integer value is 4 bytes,
# you can reference the 200 value by accessing the memory location sizes+8

.equ LINUX_SYS_CALL, 0x80
# Once set, the data symbol value cannot be changed within the program.
# The .equ directive can appear anywhere in the data section

# There is another type of data section called 
.rodata
# Any data elements defined in this section can only be 
# accessed in read-only mode (thus the ro prefix).

.fill
# directive enables the assembler to automatically create the
# 10,000 data elements for you. The default is to create one byte per field, 
# and fill it with zeros. You could have declared a .byte data value,
# and listed 10,000 bytes yourself

# BSS
# ---
.comm Declares a common memory area for data that is not initialized
.lcomm Declares a local common memory area for data that is not initialized

.comm symbol, length

.section .bss
.lcomm buffer, 10000



# -----------
# Moving data
# -----------

movx source, destination

# The source and destination values can be memory addresses,
# data values stored in memory, data values defined
# in the instruction statement, or registers.

# where x can be the following:
# - l for a 32-bit long word value
# - w for a 16-bit word value
# - b for an 8-bit byte value
# - q for a 64-bit quad word value (64-bit systems)

# Combinations for a MOV instruction:
# - An immediate data element to a general-purpose register
# - An immediate data element to a memory location
# - A general-purpose register to another general-purpose register
# - A general-purpose register to a segment register
# - A segment register to a general-purpose register
# - A general-purpose register to a control register
# - A control register to a general-purpose register
# - A general-purpose register to a debug register
# - A debug register to a general-purpose register
# - A memory location to a general-purpose register
# - A memory location to a segment register
# - A general-purpose register to a memory location
# - A segment register to a memory location

movl $0, %eax # moves the value 0 to the EAX register
movl $0x80, %ebx # moves the hexadecimal value 80 to the EBX register
movl $100, height # moves the value 100 to the height memory location

# Note that each value must be preceded by a dollar sign to indicate 
# that it is an immediate value. The values can also be expressed in 
# several different formats, decimal (such as 10, 100, or 230) or 
# hexadecimal (such as 0x40, 0x3f, or 0xff). These values cannot be 
# changed after the program is assembled and linked into the 
# executable program file.

movl %eax, %ecx # move 32-bits of data from the EAX register to the ECX register
movw %ax, %cx # move 16-bits of data from the AX register to the CX register

# The eight general-purpose registers 
# ( EAX , EBX , ECX , EDX , EDI , ESI , EBP , and ESP ) 
# are the most common registers used for holding data. These registers can 
# be moved to any other type of register available. Unlike the general-purpose 
# registers, the special-purpose registers 
# (the control, debug, and segment registers) can only be moved to 
# or from a general-purpose register.

# An example of moving data from memory to a register
.section .data
value:
    .int 1
.section .text
.globl _start
_start:
    nop
    movl value, %ecx
    movl $1, %eax
    movl $0, %ebx
    int $0x80

# An example of moving register data to memory
.section .data
value:
    .int 1
.section .text
.globl _start
_start:
    nop
    movl $100, %eax
    movl %eax, value
    movl $1, %eax
    movl $0, %ebx
    int $0x80

# Indexed addressing
# -------------------
# The way this is done is called indexed memory mode. 
# The memory location is determined by the following:
# - A base address
# - An offset address to add to the base address
# - The size of the data element
# - An index to determine which data element to select
# The format of the expression is
# base_address(offset_address, index, size)
# The data value retrieved is located at
# base_address + offset_address + index * size

# If any of the values are zero, they can be omitted 
# (but the commas are still required as placeholders).

movl $2, %edi
movl values(, %edi, 4), %eax

# Indirect memory addressing
# --------------------------

# Is used to move the memory address the values label references to the 
# EDI register. Remember that in a flat memory model, 
# all memory addresses are represented by 32-bit numbers.

# The dollar sign ($) before the label name instructs the assembler 
# to use the memory address, and not the data value located at the address.

movl $values, %edi
movl %ebx, (%edi)

# Without the parentheses around the EDI register, the instruction would just 
# load the value in the EBX register to the EDI register. With the parentheses 
# around the EDI register, the instruction instead moves the value in the 
# EBX register to the memory location contained in the EDI register.

movl %edx, 4(%edi) # 4 bytes after location pointed to by the EDI register.
movl %edx, -4(&edi) # 4 bytes before

# The CMOV instructions
# The conditions are based on the current values in the EFLAGS register.
# CMOVA/CMOVNBE Above/not below or equal (CF or ZF) = 0
# CMOVAE/CMOVNB Above or equal/not below CF=0
# CMOVNC Not carry CF=0
# CMOVB/CMOVNAE Below/not above or equal CF=1
# CMOVC Carry CF=1
# CMOVBE/CMOVNA Below or equal/not above (CF or ZF) = 1
# CMOVE/CMOVZ Equal/zero ZF=1
# CMOVNE/CMOVNZ Not equal/not zero ZF=0
# CMOVP/CMOVPE Parity/parity even PF=1
# CMOVNP/CMOVPO

# CMOVGE/CMOVNL Greater or equal/not less (SF xor OF)=0
# CMOVL/CMOVNGE Less/not greater or equal (SF xor OF)=1
# CMOVLE/CMOVNG Less or equal/not greater ((SF xor OF) or ZF)=1
# CMOVO Overflow OF=1
# CMOVNO Not overflow OF=0
# CMOVS Sign (negative) SF=1
# CMOVNS Not sign (non-negative) SF=0

movl value, %ecx
cmp %ebx, %ecx
cmova %ecx, %ebx

# XCHG Exchanges the values of two registers, or a register and a memory location
# BSWAP Reverses the byte order in a 32-bit register
# XADD Exchanges two values and stores the sum in the destination operand
# CMPXCHG Compares a value with an external value and exchanges it with another
# CMPXCHG8B Compares two 64-bit values and exchanges it with another

# ------------------------------
# Stack. Pushing and Poping data 
# ------------------------------

pushx source
popx destination

# PUSHA/POPA Push or pop all of the 16-bit general-purpose registers
# PUSHAD/POPAD Push or pop all of the 32-bit general-purpose registers
# PUSHF/POPF Push or pop the lower 16 bits of the EFLAGS register
# PUSHFD/POPFD Push or pop the entire 32 bits of the EFLAGS register

# The PUSHA instruction pushes the 16-bit registers so they appear on the 
# stack in the following order: DI , SI , BP , BX , DX , CX , and finally, AX

# The PUSH and POP instructions are not the only way to get data onto and 
# off of the stack. You can also manually place data on the stack by utilizing 
# the ESP register as a memory pointer. Often, instead of using the 
# ESP register itself, you will see many programs copy the ESP register 
# value to the EBP register. It is common in assembly language functions 
# to use the EBP pointer to point to the base of the working stack space 
# for the function. Instructions that access parameters stored 
# on the stack reference them relative to the EBP value


# -------------------
# Branch instructions 
# -------------------

# Indirectly alter program couter (instruction pointer) 
# set value (address of next instruction).

# - Unconditional branches (Jumps, Calls, Interrupts)
#   (The instruction pointer is automatically routed to a different location)
# - Conditional branches


# Unconditional branches 
# ----------------------
jmp location

_start:
    jmp overhere
    movl $10, %ebx
overhere:
    movl $20, %ebx

# - Short jump
# - Near jump
# - Far jump

# The three jump types are determined by the distance between the current
# instruction’s memory location and the memory location of the destination 
# point (the "jump to" location). Depending on the number of bytes jumped, 
# the different jump types are used. A short jump is used when the jump 
# offset is less than 128 bytes. A far jump is used in segmented memory 
# models when the jump goes to an instruction in another segment. 
# The near jump is used for all other jumps.
# The next type of unconditional branch is the call. A call is similar 
# to the jump instruction, but it remembers where it jumped from and 
# has the capability to return there if needed. This is used when 
# implementing functions in assembly language programs.

call address

# When the CALL instruction is executed, it places the 
# EIP register onto the stack and then modifies the EIP register 
# to point to the called function address. The return instruction 
# has no operands, just the mnemonic RET . 
# It knows where to return to by looking at the stack.


# Conditional branches 
# --------------------

# Unlike unconditional branches, conditional branches are not always taken. 
# The result of the conditional branch depends on the state of the EFLAGS 
# register at the time the branch is executed.

# - Carry flag (CF) - bit 0 (lease significant bit)
# - Overflow flag (OF) - bit 11
# - Parity flag (PF) - bit 2
# - Sign flag (SF) - bit 7
# - Zero flag (ZF) - bit 6

jxx address

# Supports:
# - Short jumps
# - Near jumps

# JA - Jump if above CF=0 and ZF=0
# JAE - Jump if above or equal CF=0
# JB - Jump if below CF=1
# JBE - Jump if below or equal CF=1 or ZF=1
# JC - Jump if carry CF=1
# JCXZ - Jump if CX register is 0 JECXZ Jump if ECX register is 0 JE Jump if equal ZF=1
# JG - Jump if greater ZF=0 and SF=OF
# JGE - Jump if greater or equal SF=OF
# JL - Jump if less SF<>OF
# JLE - Jump if less or equal ZF=1 or SF<>OF
# JNA - Jump if not above CF=1 or ZF=1
# JNAE - Jump if not above or equal CF=1
# JNB - Jump if not below CF=0
# JNBE - Jump if not below or equal CF=0 and ZF=0
# JNC - Jump if not carry CF=0
# JNE - Jump if not equal ZF=0
# JNG - Jump if not greater ZF=1 or SF<>OF
# JNGE - Jump if not greater or equal SF<>OF
# JNL - Jump if not less SF=OF
# JNLE - Jump if not less or equal ZF=0 and SF=OF
# JNO - Jump if not overflow OF=0
# JNP - Jump if not parity PF=0
# JNS - Jump if not sign SF=0
# JNZ - Jump if not zero ZF=0
# JO - Jump if overflow OF=1
# JP - Jump if parity PF=1
# JPE - Jump if parity even PF=1
# JPO - Jump if parity odd PF=0
# JS - Jump if sign SF=1
# JZ - Jump if zero ZF=1

# The compare instruction is the most common way to evaluate two values for a 
# conditional jump. The compare instruction does just what its name says, 
# it compares two values and sets the EFLAGS registers accordingly.

cmp operand1, operand2

# Loops
# -----

# LOOP          - Loop until the ECX register is zero

# LOOPE/LOOPZ   - Loop until either the ECX register is zero,
#                 or the ZF flag is not set

# LOOPNE/LOOPNZ - Loop until either the ECX register is zero, 
#                 or the ZF flag is set

loop address

loop_addr:
    addl %ecx, %eax
    loop loop_addr

# Unfortunately, the loop instructions support only an 8-bit offset, 
# so only short jumps can be performed.

# --------
# Integers 
# --------

# - Byte: 8 bits
# - Word: 16 bits
# - Doubleword: 32 bits
# - Quadword: 64 bits

# Register: Big-endian format
# Memory: Little-endian format

# The signed magnitude method splits the bits that make up the signed 
# integer into two parts: a sign bit and the magnitude bits. The most 
# significant (leftmost) bit of the bytes is used to represent the 
# sign of the value

# Scientific notation presents numbers as a coefficient 
# (also called the mantissa) and an exponent, such as 3.6845 × 10^2


# ------------
# Integer math
# ------------

# Addition

add source, destination

addb $10, %al # adds the immediate value 10 to the 8-bit AL register
addw %bx, %cx # adds the 16-bit value of the BX register to the CX register
addl data, %eax # adds the 32-bit integer value at the data label to EAX
addl %eax, %eax # adds the value of the EAX register to itself

# The ADC instruction can be used to add two unsigned or signed integer 
# values, along with the value contained in the carry flag from a 
# previous ADD instruction.

adc source, destination

sub source, destination
sbb source, destination

# Incrementing and decrementing

dec destination
inc destination

# Multiplication

mul source

# For one thing, the destination location always uses some form 
# of the EAX register, depending on the size of the source operand. 
# Thus, one of the operands used in the multiplication must be placed 
# in the AL , AX , or EAX registers, depending on the size of the value.

# While the MUL instruction can only be used for unsigned integers, the 
# IMUL instruction can be used by both signed and unsigned integers

imul source

# Division

div divisor
idiv divisor

# The dividend must already be stored in the AX register (for a 16-bit value), 
# the DX:AX register pair (for a 32-bit value), or the EDX:EAX register pair 
# (for a 64-bit value) before the DIV instruction is performed.

# Shifting
# To multiply integers by a power of 2, you must shift the value to the left.

# SALX (shift arithmetic left) and SHL (shift logical left)

sal destination
sal %cl, destination
sal shifter, destination

# Dividing by shifting involves shifting the binary value to the right.

# The SHR instruction clears the bits emptied by the shift, which makes 
# it useful only for shifting unsigned integers. The SAR instruction 
# either clears or sets the bits emptied by the shift, depending on 
# the sign bit of the integer.

# Close relatives to the shift instructions are the rotate instructions.
# The rotate instructions perform just like the shift instructions, 
# except the overflow bits are pushed back into the other end of the value
# instead of being dropped.

# ROL Rotate value left
# ROR Rotate value right
# RCL Rotate left and include carry flag
# RCR Rotate right and include carry flag

# Boolean logic

# - AND
# - NOT
# - OR
# - XOR

and source, destination

# -------------------
# Floating point math
# -------------------

# The FPU register stack

# FPU is a self-contained unit that handles floating-point operations using
# a set of registers that are set apart from the standard processor registers. 
# The additional FPU registers include eight 80-bit data registers, 
# and three 16-bit registers called the control, status, and tag registers.

# The control register controls the floating-point functions within the FPU. 
# Defined here are settings such as the precision the FPU uses to calculate 
# floating-point values, and the method used to round the floating-point results.

# The tag register is used to identify the values within the eight 
# 80-bit FPU data registers. The tag register uses 16 bits 
# (2 bits per register) to identify the contents of each FPU data register.
# - A valid double-extended-precision value (code 00)
# - A zero value (code 01)
# - A special floating-point value (code 10)
# - Nothing (empty) (code 11)

FADD # Floating-point addition
FDIV # Floating-point division
FDIVR # Reverse floating-point division
FMUL # Floating-point multiplication
FSUB # Floating-point subtraction
FSUBR # Reverse floating-point subtraction

F2XM1 # Computes 2 to the power of the value in ST0, minus 1
FABS # Computes the absolute value of the value in ST0
FCHS # Changes the sign of the value in ST0
FCOS # Computes the cosine of the value in ST0
FPATAN # Computes the partial arctangent of the value in ST0
FPREM # Computes the partial remainders from dividing the value in ST0 by
      # the value in ST1
FPREM1 # Computes the IEEE partial remainders from dividing the value in
ST0 # by the value in ST1
FPTAN # Computes the partial tangent of the value in ST0
FRNDINT # Rounds the value in ST0 to the nearest integer
FSCALE # Computes ST0 to the ST1st power
FSIN # Computes the sine of the value in ST0
FSINCOS # Computes both the sine and cosine of the value in ST0
FSQRT # Computes the square root of the value in ST0
FYL2X # Computes the value ST1 * log ST0 (base 2 log)
FYL2XP1 # Computes the value ST1 * log (ST0 + 1) (base 2 log)

# The FCOM instruction family
# The FCOMI instruction family
# The FCMOV instruction family

# -------
# Strings
# -------

# The MOVS instruction was created to provide a simple way for programmers
# to move string data from one memory location to another.
# - MOVSB: Moves a single byte
# - MOVSW: Moves a word (2 bytes)
# - MOVSL: Moves a doubleword (4 bytes)

# With the GNU assembler, there are two ways to load the ESI and EDI values. 
# The first way is to use indirect addressing

movl $output, %edi

# Another method of specifying the memory locations is the LEA instruction. 
# The LEA instruction loads the effective address of an object.

leal output, %edi

# Each time a MOVS instruction is executed, when the data is moved, 
# the ESI and EDI registers are automatically changed in preparation 
# for another move. While this is usually a good thing, sometimes 
# it can be somewhat tricky. 

# One of the tricky parts of this operation is the direction 
# in which the registers are changed. The ESI and EDI registers 
# can be either automatically incremented or automatically decremented, 
# depending on the value of the DF flag in the EFLAGS register.

# If the DF flag is cleared, the ESI and EDI registers are incremented 
# after each MOVS instruction. If the DF flag is set, the ESI and EDI 
# registers are decremented after each MOVS instruction.

# - CLD to clear the DF flag
# - STD to set the DF flag


# The REP instruction is special in that it does nothing by itself.
# It is used to repeat a string instruction a specific number of times,
# controlled by the value in the ECX register, similar to using a loop,
# but without the extra LOOP instruction. The REP instruction repeats
# the string instruction immediately following it until the value in
# the ECX register is zero. That is why it is called a prefix.

# The MOVSB instruction can be used with the REP instruction to 
# move a string 1 byte at a time to another location.

# You are not limited to moving the strings byte by byte. You can also use
# the MOVSW and MOVSL instructions to move more than 1 byte per iteration.

# If you are using the MOVSW or MOVSL instructions, the ECX register
# should contain the number of iterations required to walk through the string. 
# For example, if you are moving an 8-byte string, you would need to set ECX 
# to 8 if you are using the MOVSB instruction, to 4 if you are using the 
# MOVSW instruction, or to 2 if you are using the MOVSL instruction.

REPE # Repeat while equal
REPNE # Repeat while not equal
REPNZ # Repeat while not zero
REPZ # Repeat while zero

# The LODS instruction is used to move a string value in memory 
# into the EAX register. As with the MOVS instruction, there are 
# three different formats of the LODS instruction:
# - LODSB: Loads a byte into the AL register
# - LODSW: Loads a word (2 bytes) into the AX register
# - LODSL: Loads a doubleword (4 bytes) into the EAX register

# After the LODS instruction is used to place a string value in the 
# EAX register, the STOS instruction can be used to place it 
# in another memory location.
# - STOSB: Stores a byte of data from the AL register
# - STOSW: Stores a word (2 bytes) of data from the AX register
# - STOSL: Stores a doubleword (4 bytes) of data from the EAX register

# The CMPS family of instructions is used to compare string values
# - CMPSB: Compares a byte value
# - CMPSW: Compares a word (2 bytes) value
# - CMPSL: Compares a doubleword (4 bytes) value

# The SCAS family of instructions is used to scan strings for one or more 
# search characters.
# - SCASB: Compares a byte in memory with the AL register value
# - SCASW: Compares a word in memory with the AX register value
# - SCASL: Compares a doubleword in memory with the EAX register value


# ---------
# Functions
# ---------

# Defining input values:
# - Using registers
# - Using global variables
# - Using the stack

.type funct, @function
funct:

# The end of the function is defined by a RET instruction. 
# When the RET instruction is reached, program control is returned 
# to the main program, at the instruction immediately following 
# where the function was called with the CALL instruction.

# Defining output values
# - Place the result in one or more registers.
# - Place the result in a global variable memory location.

.type area, @function
area:
    fldpi
    imull %ebx, %ebx
    movl %ebx, value
    filds value
    fmulp %st(0), %st(1)
    ret

# Command-line parameter values are placed onto the top of the stack at run.


# ------------------
# Linux system calls
# ------------------

# The integers listed next to the system call names in the unistd.h 
# file are the system call values. Each system call is assigned 
# a unique number to identify it. The desired value is moved into the 
# EAX register before the INT instruction is performed.

movl $1, %eax
int 0x80

# Input values are placed in the registers is important. The order in which
# the system calls expect input values is as follows:
# - EBX (first parameter)
# - ECX (second parameter)
# - EDX (third parameter)
# - ESI (fourth parameter)
# - EDI (fifth parameter)

# The return value from a system call is placed in the EAX register. 
# It is your job to check the value in the
# EAX register, especially for failure conditions.


# ---------------
# Inline Assembly
# ---------------

asm ( "movl $1, %eax\n\t"
      "movl $0, %ebx\n\t"
      "int $0x80" );

# The basic inline assembly code can utilize 
# global C variables defined in the application.

# The volatile modifier can be placed in the asm statement ito 
# indicate that no optimization is desired on that section of code.

asm volatile ("assembly code");

# The asm keyword used to identify the inline assembly code section 
# may be altered if necessary. The ANSI C specifications use the asm keyword 
# for something else, preventing you from using it for your inline assembly
# statements. If you are writing code using the ANSI C conventions, 
# you must use the __asm__ keyword instead of the normal asm keyword.

__asm__ ("pusha\n\t"
         "movl a, %eax\n\t"
         "movl b, %ebx\n\t"
         "imull %ebx, %eax\n\t"
         "movl %eax, result\n\t"
         "popa");

# Extended ASM format
# -------------------
asm ("assembly code" : output locations : input operands : changed registers);

# - Assembly code:     The inline assembly code using the same syntax 
#                      used for the basic asm format

# - Output locations:  A list of registers and memory locations that will 
#                      contain the output values from the inline assembly code

# - Input operands:    A list of registers and memory locations that contain 
#                      input values for the inline assembly code

# - Changed registers: A list of any additional registers that are 
#                      changed by the inline code

# The format of the input and output values list is
"constraint"(variable)

# a Use the %eax, %ax, or %al registers.
# b Use the %ebx, %bx, or %bl registers.
# c Use the %ecx, %cx, or %cl registers.
# d Use the %edx, %dx, or $dl registers.
# S Use the %esi or %si registers.
# D Use the %edi or %di registers.
# r Use any available general-purpose register.
# q Use either the %eax, %ebx, %ecx, or %edx register.
# A Use the %eax and the %edx registers for a 64-bit value.
# f Use a floating-point register.
# t Use the first (top) floating-point register.
# u Use the second floating-point register.
# m Use the variable’s memory location.
# o Use an offset memory location.
# V Use only a direct memory location.
# i Use an immediate integer value.
# n Use an immediate integer value with a known value.
# g Use any register or memory location available.

# The output modifiers:
# + The operand can be both read from and written to.
# = The operand can only be written to.
# % The operand can be switched with the next operand if necessary.
# & The operand can be deleted and reused before the inline functions
#   complete.

asm ("assembly code" : "=a"(result) : "d"(data1), "c"(data2));

# If the input and output variables are assigned to registers, the 
# registers can be used within the inline assembly code almost as normal. 
# In extended asm format, to reference a register in the assembly 
# code you must use two percent signs instead of just one.

int data1 = 10;
int data2 = 20;
int result;
asm ("imull %%edx, %%ecx\n\t"
     "movl %%ecx, %%eax"
     : "=a"(result)
     : "d"(data1), "c"(data2));

# Using placeholders
# ------------------

# For example, the following inline code:
asm ("assembly code"
     : "=r"(result)
     : "r"(data1), "r"(data2));

# Will produce the following placeholders:
# - %0 will represent the register containing the result variable value.
# - %1 will represent the register containing the data1 variable value.
# - %2 will represent the register containing the data2 variable value.

asm ("imull %1, %2\n\t"
     "movl %2, %0"
     : "=r"(result)
     : "r"(data1), "r"(data2));

# The alternative name is defined within the sections in which the 
# input and output values are declared.
# The format is as follows:

%[name]"constraint"(variable)

asm ("imull %[value1], %[value2]"
     : [value2] "=r"(data2)
     : [value1] "r"(data1), "0"(data2));


# Because of the way the FPU uses registers as a stack:
# - f references any available floating-point register
# - t references the top floating-point register
# - u references the second floating-point register

asm("fsincos"
    : "=t"(cosine), "=u"(sine)
    : "0"(radian));

# There are two restrictions when using labels in inline assembly code. 
# The first one is that you can only jump to a label within the same 
# asm section. You cannot jump from one asm section to a label 
# in another asm section.

# You cannot use the same labels again, or an error message will result 
# due to duplicate use of labels. In addition, if you try to 
# incorporate labels that use C keywords, such as function 
# names or global variables, you will also generate errors.

# An example of defining an inline assembly macro function:

#define GREATER(a, b, result) ({ \
    asm("cmp %1, %2\n\t" \
    "jge 0f\n\t" \
    "movl %1, %0\n\t" \
    "jmp 1f\n " \
    "0:\n\t" \
    "movl %2, %0\n " \
    "1:" \
    :"=r"(result) \
    :"r"(a), "r"(b)); })


# Assembly function as external file
# ----------------------------------

# gcc -o inttest inttest.c square.s

# The input value is read from the stack and placed in the EAX register. 
# The most basic of assembly language function calls return a 32-bit integer
# value in the EAX register. This value is retrieved by the calling function,
# which must assign the return value to a C variable defined as
# an integer:

int result = function();

# The assembly language code generated for the C program extracts the
# value placed in the EAX register and moves it to the memory location
# (usually a local variable on the stack) assigned to the C variable name.

# Functions that return strings return a pointer to the location
# where the string is stored. The C or C++ program that calls the
# function must use a pointer variable to hold the return value.

# Floating-point return values are a special case.
# Instead of using the EAX register, C style functions use the
# ST(0) FPU register to transfer floating-point values between functions.
# The function places the return value onto the FPU stack, and the calling
# program is responsible for popping it off of the stack and
# assigning the value to a variable.

float function1(float, float, int);
double function1(double, int);

# Using multiple input values
# Each of the input values is placed on the stack before the function is called
