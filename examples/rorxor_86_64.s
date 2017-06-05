# /* Assembly source for XOR, both x86 & x64 compatible - Length: 28 & 34 bytes respectively */ #

.set LEN, 50
.if ARCH == 64
	.set RW, 0x7333ce667e9d73dc
.else
	.set RW, 0x194c3bfd
.endif

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
	xor Ecx, Ecx
.if LEN > 0xff				# LEN is 2 bytes long
	movw $LEN, %cx
.else					# LEN is 1 byte long
	movb $LEN, %cl
.endif					# We now have Ecx == $LEN
.endm

.text
.globl _start
_start:
	set_Ecx
	mov $RW, Eax

	jmp put_addr
in_stack:
	pop Esi

xorloop:
	xorb %al, -0x1(Esi, Ecx)
	ror Eax
	loop xorloop			# dec Ecx; jnz xorloop

	jmp xoredcode

put_addr:
	call in_stack

xoredcode:
	.ascii ""
