# /* both x86 & x64 - WRITE("/bin/sh", ["/bin/sh", 0], 0) - (27 bytes) */
# char shellcode32[] = "\x6a\x0b\x58\x99\x52\xeb\x08\x54\x59\x5b\x88\x53\x07\xcd\x80\xe8\xf3\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68"
# char shellcode64[] = "\x6a\x3b\x58\x99\x52\xeb\x08\x54\x5e\x5f\x88\x57\x07\x0f\x05\xe8\xf3\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68";

# Register aliases to make it both x86 and x86_64 compatible #
.if ARCH == 64
	.set SYS_WRITE, 1
	.set SYS_EXIT, 60
	.set EAX, %rax
	.set EBX, %rdi
	.set ECX, %rsi
	.set EDX, %rdx
	.set ESP, %rsp
	.macro _SYSCALL_
		syscall
	.endm
.else
	.set SYS_EXIT,	1
	.set SYS_WRITE, 4
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
# sys_write(stdout, buf="Hello world!\n", count=13)
	push	$1
	pop	EBX		# stdout
.if ARCH == 64
	mov	%edi, %eax	# sys_write
.else
	push	$SYS_WRITE
	pop	%eax		# sys_write
.endif
	push	$13
	pop	EDX		# count
	jmp	get_buf_addr
back:
	pop	ECX
	_SYSCALL_		# syscall

# sys_exit(EXIT_SUCCESS=0)
.if ARCH == 64
	push	$SYS_EXIT
	pop	%rax
	dec	%edi		# EXIT_SUCCESS
.else
	mov	%ebx, %eax	# sys_exit
	dec	%ebx		# EXIT_SUCCESS
.endif
	_SYSCALL_		# syscall

get_buf_addr:
	call back		# push buf; jmp back
buf:
	.ascii "Hello world!\n"
