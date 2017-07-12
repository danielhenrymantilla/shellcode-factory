# Dummy and suboptimal example of shell invocation with #
# sys_execve ("/bin/sh", NULL, NULL) #
# /!\ Contains null bytes /!\ #

# Register aliases to make it both x86 and x86_64 compatible #
.if ARCH == 64
	.set EAX, %rax
	.set EBX, %rbx
	.set ECX, %rcx
	.set EDX, %rdx
.else
	.set EAX, %eax
	.set EBX, %ebx
	.set ECX, %ecx
	.set EDX, %edx
.endif

# Assembly code starts here #
.text
.globl _start
_start:
	call code		# -> push %eip + jmp code
	.string "/bin/sh"
code:
	pop EBX			# 2nd arg (EBX):	address of "/bin/sh"
	push $11		# 11		=	sys_execve
	pop EAX			# 1st arg (EAX):	sys_XXX
	cdq			# 4rd arg (EDX):	0 = NULL (env)
	mov EDX, ECX		# 3th arg (ECX):	0 = NULL (argv)
	int $0x80		# syscall


