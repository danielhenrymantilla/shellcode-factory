from assembly import Assembly

# String of forbidden chars
forbidden_chars = ""

class Utils:
        verbose = False # Is debug printing activated?

        @staticmethod
        def none(*args): return None

        @staticmethod
        def debug(*ss):
                if Utils.verbose:
                        for s in ss: print s

        @staticmethod
        def offset_split_as_valids(offset):
                """
                Returns x, y, z verifying that y and z are valid bytes and that
                2 * (x * 0x100 + y) + z = offset + x + (x ? 4 : 0)
                """
	        hundreds = 0
                # 4 = Assembly()("inc %esp; pop %ecx; push %ecx; dec %esp").len
                incpoppushdec = 4
                for hundreds in range(0x100):
		        if hundreds == 1: offset += incpoppushdec
		        for once in Xor.valid_bytes:
			        for twice in Xor.valid_bytes:
				        if offset == \
                                           2*(hundreds * 0x100 + twice) + once:
					        return once, twice, hundreds
                        offset += 1
		assert(False)

        @staticmethod
        def to_hex_wordff(bytes, arch = 32):
                """
                Converts a series of bytes into its integer representation,
                but replacing the byte 0xff by a valid one
                """
                assert(len(bytes) <= arch / 8)
                rev_chars = \
                  ((chr(i) if i != 0xff else Xor.zero) for i in bytes[::-1])
                return "$0x" + "".join(c.encode("hex") for c in rev_chars)

class Xor:
        @staticmethod
        def of(*args):
                """ xor operator with arbitrary arity """
                acc = 0
                for arg in args: acc ^= arg
                return acc
        # from functools import reduce; from operator import xor; \
        # of = lambda *args: reduce(xor, args, 0)

        # String of valid chars
        import string;\
	valid_chars = \
         (string.digits + string.ascii_letters).translate(None, forbidden_chars)
        # One valid char will represent 0xff
        zero = valid_chars[0]
        # List of valid bytes
	valid_bytes = [ord(c) for c in valid_chars]
        # List of validff bytes (byte 0xff added for xor completude)
	valid_bytesff = [ord(c) for c in valid_chars.replace(zero, "\xff")]

        # Dictionary of: valid bytes split as tuples of valid bytes
        dups = {}
	for x in valid_bytes:
		for y in valid_bytes:
			if (x ^ y in valid_bytes):
				dups[x ^ y] = [x, y]

        # Dictionary of: bytes split as tuples of a validff byte and valid bytes
	splits = {}
	splits[0xff] = [0xff, valid_bytesff[1], valid_bytesff[1]]
	for z in valid_bytes: splits[z] = [z]
	splits[ord(zero)] = [valid_bytesff[1], valid_bytesff[1], ord(zero)]
	for x in valid_bytesff:
		for z in valid_bytes:
			if not (x ^ z in splits): splits[x ^ z] = [x, z]
	for x in valid_bytesff:
		for y in valid_bytes:
			for z in valid_bytes:
				if not (x ^ y ^ z in splits):
                                        splits[x ^ y ^ z] = [x, y, z]

        @staticmethod
	def display():
		for i in range(len(Xor.splits)):
			print hex(i) + " = " + \
                                " ^ ".join(hex(x) for x in Xor.splits[i])

        @staticmethod
	def split(word):
	        """
	        Input  = word  :     byte     array
	        Output = words : (byte array) array, verifying that
	        for j in range(len(word)):
                        word[j] == Xor.of(words[i][j] for i in range(words_nb))
	        """
                Utils.debug("Debug(split)", "got " + \
                            Utils.to_hex_wordff(word), word)
                words_nb = max(len(Xor.splits[x]) for x in word)
	        words = [[] for i in range(words_nb)]
                for byte in word:
		        i = 0
		        for x in Xor.splits[byte]:
			        words[i].append(x)
			        i += 1
			while (i < words_nb):
				x1, x2 = Xor.dups[words[i - 1][-1]]
				words[i - 1][-1] = x1
				words[i].append(x2)
				i += 1
		Utils.debug("Debug(split)", "returning", words)
                return words


class Alphanumeric(Assembly):
	eax, ecx, edx, ebx, esp, ebp, esi, edi = "", "", "", "", "", "", "", ""
	word_size = 2
	dword_size = 4
	qword_size = 8
	int_size = 0

	def prologue(self):
	        self.macro \
                ("pmov")(lambda src, dst: \
                Utils.none(self.push(src), \
                           self.popl(dst)  ))
	        @self.macro()
                def zero_eax():
                        word = "$0x" + Xor.zero.encode("hex") * 4
		        self.pmov(word, "%eax")
		        self.xorl(word, "%eax")
	        @self.macro()
	        def set_regs(eax="%eax", ecx="%ecx", edx="%edx", ebx="%ebx",\
		             ebp="%ebp", esi="%esi", edi="%edi", buried="%eax"):
		        self.push(eax)
		        self.push(ecx)
		        self.push(edx)
		        self.push(ebx)
		        self.push(buried)
		        self.push(ebp)
		        self.push(esi)
		        self.push(edi)
		        self.popa()
	        @self.macro()
                def rep_add(n, reg):
                        for i in range(abs(n)):
                                self("inc" if n >= 0 else "dec", reg)
	        @self.macro()
	        def pop_eip(reg):
		        self.rep_add(-4, "%esp")
		        self.popl(reg)
	        @self.macro()
	        def init_regs():
		        self.pop_eip("%ecx")
		        self.zero_eax()
		        self.decl("%eax")
		        self.pmov("%eax", "%edx")
		        self.xorb("$0x33", "%al")
		        self.set_regs(	eax = "%edx", ebx = "%edx",	\
					ecx = "%edx", edx = "%eax",	\
					esi = "%eax", edi = "%eax",	\
					ebp = "%ecx"			)
		        self.incl("%ebx")
		        self.rep_add(3, "%edx")
                @self.macro()
                def popl_esp (aux_reg = "%eax"):
                        self.pmov("%esp", aux_reg)
                        self.xorl("0x34(%esp, %esi)", aux_reg)
                        self.pmov(aux_reg, aux_reg)
                        self.xorl("0x30(%esp, %esi)", "%esp")
	        self.init_regs()
                self.pushl("%esp")
                self.incl("%esp")
                self.popl("%ecx")
                self.rep_add(2, "%ecx")
                self.pushl("%ecx")
                self.decl("%esp")
                self.popl_esp(aux_reg = "%ecx")
	        self.pmov("%eax", "%ecx")

        def push_sc(self, sc):
                @self.macro()
                def pushff(word):
                        """
                        Pushes the 4-bytes word using alphanumeric opcodes only
                        (Requires %esi = -0x34, %dl = 0x30 ^ 0xff = 0xcf
			and	%ecx = 0xffffffff)
                        """
                        assert(len(word) == self.dword_size)
                        is_validff = True
                        for i in word:
                                is_validff = is_validff and \
                                             (i in Xor.valid_bytesff)
                        assert(is_validff)
        	        ff_nb = sum(int(i == 0xff) for i in word)
        	        if ff_nb == 4:
        		        self.pushl("%ecx")
        		        return
        	        if word[2:4] == [0xff, 0xff]:
        		        self.pushw("%cx")
        		        self.pushw("$0x" + Utils.to_hex_wordff(word)[7:])
        		        for i in range(2):
        			        if word[i] == 0xff:
        				        self.xorb("%dl", \
                                                  "0x" + str(34 + i) + \
                                                          "(%esp, %esi)")
        		        return
        	        self.pushl(Utils.to_hex_wordff(word))
        	        for i in range(4):
        		        if word[i] == 0xff:
        			        self.xorb("%dl", \
                                          "0x" + str(34 + i) + "(%esp, %esi)")
        	        return
	        sc += (-len(sc) % 4) * "G" # "G" -> "inc %edi"
	        Utils.debug(sc + " : " + str(len(sc)) + " bytes.")
                all_words = []
                for k in range(len(sc) / 4):
                        all_words.append( \
                          Xor.split([ord(c) for c in sc[4 * k:4 * (k + 1)]]))
		Utils.debug(all_words)
	        for words in all_words[::-1]:
		        Utils.debug([Utils.to_hex_wordff(word) \
                                     for word in words])
		        self.pushff(words[0])
		        self.popl("%eax")
		        for i in range(1, len(words)):
			        self.xorl(Utils.to_hex_wordff(words[i]), "%eax")
		        self.pushl("%eax")

        def epilogue (self, offset=ord(Xor.zero), edx=ord(Xor.zero), hundreds=0):
                @self.macro()
                def set_edx (edx, hundreds):
                        self.push("$" + hex(edx))
                        if hundreds:
                                self.incl("%esp")
                                self.popl("%edx")
                                self.rep_add(hundreds, "%edx")
                                self.pushl("%edx")
                                self.decl("%esp")
                        self.popl("%edx")
                self.push("%esp")
                self.set_edx(edx, hundreds)
                self.pmov("%ecx", "%eax")
                self.xorb("$0x64", "%al")
                self.xorb("%al", hex(offset) + "(%ebp, %edx, 2)")
                self(".byte", "0x58")

        def __init__(self, sc, arch):
                self.autoassemble = False
                if arch == 64:
			self.eax, self.ecx, self.edx, self.ebx,	\
			self.esp, self.ebp, self.esi, self.edi = \
			"%rax", "%rbx", "%rcx", "%rdx",\
			"%rsp", "%rbp", "%rsi", "%rdi"
			self.int_size = 8
                        print "'" + argv[0] + \
                                "' error: 64 bits support not implemented yet"
                        exit(1)
		else:
			self.eax, self.ecx, self.edx, self.ebx,	\
			self.esp, self.ebp, self.esi, self.edi = \
			"%eax", "%ebx", "%ecx", "%edx",\
			"%esp", "%ebp", "%esi", "%edi"
			self.int_size = 4
                self.prologue()
                self.push_sc(sc)
                base_code = self.code
                self.epilogue()
                self._assemble()
                code_offset = self.len - 1
		if Utils.verbose: print self
                self.code = base_code
                self.epilogue(*Utils.offset_split_as_valids(code_offset))
	        self._assemble()


if __name__ == "__main__":
        if Utils.verbose: Xor.display()
        from sys import argv
	if len(argv) < 2 or len(argv) > 3:
		print "Usage:\n\tpython", argv[0], "shellcode", "[arch]"
		exit(1)
        sc = "".join(c if c != "\\" and c != "x" else "" \
                                    for c in argv[1]).decode("hex")
        arch = int(argv[2]) if len(argv) == 3 else 32
        code = Alphanumeric(sc, arch)
        if Utils.verbose: print code
        print "alphanumeric_shellcode ="
        print code.ascii
        print "Total: " + str(code.len) + " bytes."
