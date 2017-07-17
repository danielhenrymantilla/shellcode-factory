from subprocess import call, check_output

debug = False

def system(cmd):
	n = call(cmd, shell = True) # /!\ This call is dangerous /!\ #
	if n:
		print "Error: command '" + cmd + "' returned " + str(n)
		exit(n)
	return

class Assembly(object):
	@staticmethod
	def to_bin(x):
		return "0b" + "".join(str((x / 2 ** k) % 2) for k in range(8))[::-1]

	@staticmethod
	def to_hex(x):
		return "0x" + chr(x).encode("hex")

	@staticmethod
	def to_hexbin(x):
		return Assembly.to_hex(x) + " (" + Assembly.to_bin(x) + ")"

	code = ""
	mnemonics = []
	bytess = []
	ascii = ""
	len = 0
	_m = {}
	autoassemble = True

	def __init__(self, *args):
		self._add(*args)

	def _append_instr(self, instr):
		self.code += "\t" + instr + "\n"

	def _trymacro(self, name):
		if not name in self._m:
			return lambda *args, **kwargs:\
				self._append_instr(name + " " + ",".join(args))
		return self._m[name]

	def _add(self, *args, **kwargs):
		if len(args):
			if isinstance(args[0], tuple):
				for arg in args:
					self._trymacro(arg[0])(*arg[1:])
			else:
				self._trymacro(args[0])(*args[1:], **kwargs)
			if self.autoassemble: self._assemble()
		return self

	def __call__(self, *instr, **kwargs):
		return self._add(*instr, **kwargs)

	def macro(self, name = ""):
		def macro(f):
			if name == "":
				self._m[f.__name__] = f
			else:
				self._m[name] = f
			return f
		return macro

	def _parse(self, ss):
		if debug: print ss
		self.mnemonics = []
		self.bytess = []
		self.ascii = ""
	        for s in ss:
		        s_hexchars = s.split("\t")[1]
		        l_hexchars = []
		        for x in s_hexchars.split(" "):
			        if x != "":
				        l_hexchars.append(ord(x.decode("hex")))
			self.ascii += "".join(chr(x) for x in l_hexchars)
			self.bytess.append(l_hexchars)
			if len(s.split("\t")) < 3:
				self.mnemonics.append("")
			else:
				self.mnemonics.append(s.split("\t")[2])
		self.len = len(self.ascii)
		return

	def _assemble(self):
		if debug: print "Asm(\"" + self.code + "\")"
		file_content = ".text\n.globl _start\n_start:\n" + self.code.replace(";", "\n\t") + "\n\tnop"
		system("echo '" + file_content + "' > ._tmp_.s")
		system("gcc -m32 -nostdlib -c ._tmp_.s")
		argv = check_output("objdump -d ._tmp_.o | grep -e \" ...:\" | cut -d: -f2", shell = True)
	        self._parse(argv.split("\n")[:-2])
		system("rm -f ._tmp_.*")

	def _mnemonics_to_string(self):
		return "[ " + "; ".join(self.mnemonics) + " ]"

	def _bytecode_to_string(self):
		return "\\x" + "\\x".join(c.encode("hex") for c in self.ascii)

	def __str__(self):
		s = ""
		if debug: s += self._mnemonics_to_string() + "\n\n"
		s += "\n".join(mnemonic + "\n> " + "\n> ".join(Assembly.to_hexbin(byte) for byte in bytes) + "\n" for mnemonic, bytes in zip(self.mnemonics, self.bytess)) + "\n"
		s += "=> bytecode = \"" + self._bytecode_to_string() + "\"\n"
		s += "(\"" + self.ascii + "\")\n"
		s += "Length: " + str(self.len) + " byte(s)"
		return s

	def __getattr__(self, name):
		def call(*args, **kwargs):
			self._add(name, *args, **kwargs)
		return call


def a(cmd): return Assembly(cmd).__str__()

def a_print(cmd): print Assembly(cmd)

if __name__ == "__main__":
        while True:
	        print input(">>> ")
