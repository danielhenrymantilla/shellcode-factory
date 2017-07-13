# Dummy and suboptimal example of shell invocation with #
# sys_execve ("/bin/sh", NULL, NULL) #
# /!\ Contains null bytes /!\ #

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

# Assembly code starts here #
.text
.globl _start
_start:
	call code		# -> push %eip + jmp code
	.string "/bin/sh"
code:
	pop EBX			# 2nd arg (EBX):	address of "/bin/sh"
	push $SYS_EXECVE	# sys_execve
	pop EAX			# 1st arg (EAX):	sys_XXX
	cdq			# 4rd arg (EDX):	0 = NULL (env)
	mov EDX, ECX		# 3th arg (ECX):	0 = NULL (argv)
	_SYSCALL_		# syscall

