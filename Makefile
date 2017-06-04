## DEFINES ##

# Architecture: 32 bits or 64 bits.
ARCH=32

# Assembly source file #
S=shellcode.s

# Change to DISABLED to remove optional objdump requirement
OBJDUMP=ENABLED

# Language to display the shellcode with (C/python) #
LANG=python

# Assembly binary filename (for debugging purposes) #
ASSEMBLY=assembly

# Rule to debug the assembly binary #
DEBUG=debug

# Input shellcode #
SC=""

# List of forbidden chars (xor command) #
NO=[0x00, 0x20, 0xa, 0x9] # No null chars nor whitespaces

# Entry point name: for instance, 'main' #
# (Change this to prevent a warning when compiling
# an assembly program without '_start'...)
E=_start

# Name of the given C file to test the shellcode with (no .c extension).
TESTER=tester

# Name of the automatically-generated C file and binary (no .c extension).
AUTO=auto

# Program to edit files with
EDITOR=@nano

# Compiler flags for a smashable-and-executable stack #
VULNFLAGS=-fno-stack-protector -z execstack

# Assembly source file (stripped) #
ifeq ($(SC), "")
SOURCE:=$(S)
else
SOURCE:=._raw_.s
endif
BIN:=$(basename $(notdir $(SOURCE)))
EXT:=$(suffix $(SOURCE))

## COMMANDS ##
.PHONY: all help usage p print hexdump xxd help put c distr_clean clean a $(AUTO)\
	$(ASSEMBLY) $(DEBUG) $(DEBUG)_sc sc_$(DEBUG) $(BIN).o install xor neg

# Default rule is usage #
all: usage

help: usage # an alias #

usage:
	@less README.md

install: xor.py neg.py

set: $(SOURCE)
	$(EDITOR) $<

put: $(TESTER).c
	$(EDITOR) $<

test: $(TESTER)
	./$<

$(TESTER): $(TESTER).c
	$(CC) -m$(ARCH) -g $(VULNFLAGS) -o $@ $<


# Compile the assembly as an object file (to extract its hex data) #
$(BIN).o: $(SOURCE)
ifneq ($(EXT), .asm)
	$(CC) -m$(ARCH) -nostdlib -Wa,--defsym,ARCH=$(ARCH) -o $@ -c $<
else
ifeq ($(ARCH), 64)
	nasm -f elf64 -o $@ $<
else
	nasm -f elf -o $@ $<
endif
endif

## DEBUGGING THE ASSEMBLY ##
# Compile the assembly as an executable program #
$(ASSEMBLY): $(BIN).o
	$(CC) -m$(ARCH) -nostdlib -o $@ $< -e$(E)

# Debug it #
$(DEBUG): $(ASSEMBLY)
	gdb -ex "start" $<

# Debug the shellcode (smashed stack situation) #
sc_$(DEBUG): $(AUTO).c
	$(CC) -g -m$(ARCH) $(VULNFLAGS) -o $(AUTO) $<
	gdb -ex "b *&shellcode" -ex "disas &shellcode" -ex "run" $(AUTO)

$(DEBUG)_sc: sc_$(DEBUG) # an alias #

# Dirty one-liner hacks to get start address and length of assembly code, #
# to then be able to get the right hex bytes #
$(BIN).hex: $(BIN).o
ifeq ($(OBJDUMP), ENABLED)
	@objdump -d $< # optional
else
	@gdb -n -batch -ex "x/1500i _start" $<
endif
	@gdb -n -batch -ex "info file" $< | grep .text | cut -d "i" -f 1 > /tmp/_infofile_
	@gdb -n -batch -ex "p `cat /tmp/_infofile_`" | cut -d "-" -f 2 > /tmp/_len_
	@gdb -n -batch -ex "x/`cat /tmp/_len_`bx `cat /tmp/_infofile_ | cut -d "-" -f 1 && rm -f /tmp/_infofile_`" $< | cut -d ":" -f 2 > $@
	@echo "Total: `cat /tmp/_len_` bytes" > /tmp/_len_

$(BIN).xxd: $(BIN).hex
	@python -c 'import sys; print "" + "".join([sys.argv[1][k], "\\", ""][2 * int(sys.argv[1][k] == " " or sys.argv[1][k] == "\t" or sys.argv[1][k] == "\n" or sys.argv[1][k] == ",") + int(sys.argv[1][k] == "0" and sys.argv[1][(k+1) % len(sys.argv[1])] == "x")] for k in range(len(sys.argv[1]))) + ""' "`cat $<`" > $@

# Compile a vulnerable C program with the generated shellcode #
# that gets executed when the program auto-smashes its saved IP #
$(AUTO).c : $(BIN).xxd
ifeq ($(ARCH), 64)
	@echo '#define WORD long /* 64 bits */\n' > $@
else
	@echo '#define WORD int /* 32 bits */\n' > $@
endif
# The escaped-characters syntax is favoured for python copy-paste compatibility
	@echo "char shellcode[] =\n \"`cat $<`\";" >> $@
	@echo '\nint main() {\n  WORD* ret;\n  ret = (WORD *) &ret + 2; /* Saved IP */\n  *ret = (WORD) shellcode;\n  return 0;\n}' >> $@

$(AUTO): $(AUTO).c
	$(CC) -g -m$(ARCH) $(VULNFLAGS) -o $@ $<
	@echo "\nC program compiled successfully.\nRunning it:"
	@./$(AUTO)
	@echo "\nThe source file of this program is '$(AUTO).c'\n"

a: $(AUTO) # an alias #

hexdump: $(BIN).xxd
	@echo " "
	@cat /tmp/_len_ || true
	@echo " "
ifeq ($(LANG), C)
	@echo "char shellcode[] = {"
	@python -c "import sys; sys.stdout.write(\"`cat $<`\")" | xxd -i
	@echo "};"
else
	@echo "shellcode =\n \"`cat $<`\""
endif
	@echo " "

p: print # an alias #

print: hexdump # an alias #

xxd: hexdump # an alias #


# Python script to negate a shellcode and prepend the decoder #
neg.py:
	@echo 'import sys' > $@
	@echo '\ndef decoder(arch):' >> $@
	@echo '\tif arch != 32:\n\t\tprint "mask: Error, not implemented yet"\n\t\tsys.exit(1)' >> $@
	@echo '\treturn "\x8b\x74\x24\xfc\x83\xc6\x0b\x46\xf6\x1e\x75\xfb"' >> $@
	@echo '\nargc = len(sys.argv) - 1\nif argc != 1 and argc != 2:\n\tprint "Usage:\\n\\tpython " + sys.argv[0] + " \\\\x..\\\\x... " + "ARCH"\n\tsys.exit(1)' >> $@
	@echo '\nsc = "".join(["", c][int(c != "\\\\" and c != "x")] for c in sys.argv[1]).decode("hex")' >> $@
	@echo 'ARCH = int(sys.argv[2])' >> $@
	@echo '\nnegated_code = ""' >> $@
	@echo 'for k in range(len(sc)):' >> $@
	@echo '\tif ord(sc[k]) == 0:\n\t\tnegated_code += sc[k:]\n\t\tbreak' >> $@
	@echo '\tnegated_code += chr(256 - ord(sc[k]))' >> $@
	@echo '\nneg_sc = decoder(ARCH) + negated_code' >> $@
	@echo 'print "masked_shellcode =\\n\"" + "".join("\\\\x" + c.encode("hex") for c in neg_sc) + "\""' >> $@
	@echo 'print "Total length: " + str(len(neg_sc)) + " bytes."' >> $@

neg: neg.py $(BIN).xxd
	@echo " "
	@python neg.py "`cat $(BIN).xxd`" $(ARCH)


# Python script to xor a shellcode (with a random byte) and preprend the decoder #
xor.py:
	@echo 'import os, sys' >> $@
	@echo '\ndef decoder(l, char, arch):' >> $@
	@echo '\tif l > 0x100:\n\t\tfrom struct import pack;set_ecx = ["", "\x48"][int(arch == 64)] + "\x31\xc9\x66\xb9" + pack("<H", l)\n\telse:\n\t\tset_ecx = "\x6a" + chr(l) + "\x59"' >> $@
	@echo '\treturn set_ecx + "\xeb\x0b\x90\x5e\x80\x74\x0e\xff" + char + "\xe2\xf9\xeb\x05\xe8\xf1\xff\xff\xff"\n' >> $@
	@echo '\nargc = len(sys.argv) - 1\nif argc != 1 and argc != 2:\n\tprint "Usage:\\n\\tpython " + sys.argv[0] + " \\\\x..\\\\x... " + "ARCH"\n\tsys.exit(1)' >> $@
	@echo '\nsc = "".join(["", c][int(c != "\\\\" and c != "x")] for c in sys.argv[1]).decode("hex")' >> $@
	@echo 'l = len(sc)' >> $@
	@echo 'ARCH = int(sys.argv[2])' >> $@
	@echo '\nforbidden_chars = []' >> $@
	@echo 'for c in $(NO):' >> $@
	@echo '\tif chr(c) in decoder(l, "", ARCH):' >> $@
	@echo '\t\tprint "xor: Warning, char " + hex(c) + " cannot be avoided since it is present in the prepended decoder"' >> $@
	@echo '\telse:' >> $@
	@echo '\t\tforbidden_chars.append(c)' >> $@
	@echo '\ni = 0\nloop = True\nwhile(loop and i < 100000):' >> $@
	@echo '\ti += 1\n\tloop = False\n\trb = ord(os.urandom(1))' >> $@
	@echo '\tif rb in forbidden_chars:\n\t\tloop = True' >> $@
	@echo '\tfor c in forbidden_chars:' >> $@
	@echo '\t\tif chr(rb ^ c) in sc:\n\t\t\tloop = True' >> $@
	@echo 'if loop:\n\tprint "xor: Failed to satisfy forbidden chars constraint"' >> $@
	@echo '\nxor_sc = decoder(l, chr(rb), ARCH)' >> $@
	@echo 'xor_sc += "".join(chr(ord(c) ^ rb) for c in sc)' >> $@
	@echo 'print "xor-ed with byte " + hex(rb) + ":"' >> $@
	@echo 'print "\"" + "".join("\\\\x" + c.encode("hex") for c in xor_sc) + "\""' >> $@
	@echo 'print "Total length: " + str(len(xor_sc)) + " bytes."' >> $@

xor: xor.py $(BIN).xxd
	@echo " "
	@python xor.py "`cat $(BIN).xxd`" $(ARCH)


clean: c # an alias #
	@ls

c:
	@rm -f $(ASSEMBLY) $(TESTER)
	@rm -f $(AUTO)*
	@rm -f ._raw_.*
	@rm -f /tmp/_len_
	@rm -f /tmp/_infofile_
	@rm -f *.o
	@rm -f *~
	@rm -f *.hex
	@rm -f *.xxd

distr_clean: c
	@rm -f xor.py
	@rm -f neg.py
	@ls

._raw_.s:
	@echo ".text\n.globl _start\n_start:\n\t.ascii \"$(SC)\"" > $@

%:
	@echo "No rule to make target '$@'"
	@false
