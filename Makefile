## DEFINES ##

# Use peda
GDBARGS=-ix ~/.pedainit

# Assembly syntax #
SYNTAX=GAS

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

# List of forbidden chars (xor commands) #
NO=[0x00, 0x20, 0xa, 0x9]	# No null chars nor whitespaces

# Entry point name: for instance, 'main' #
# (Change this to prevent a warning when compiling
# an assembly program without '_start'...)
E=_start

# Name of the given C file to test the shellcode with (no .c extension).
TESTER=tester

# Name of the automatically-generated C file and binary (no .c extension).
AUTO=auto

# Names of the python scripts / commands #
HELPERS=helpers
XOR=xor
XOR_BASIC=xor_byte
NEG=neg_short
ALPHA=alphanumeric

# PAUSE=NO will disable the pause-before-execution security #
ifneq ($(PAUSE), NO)
PAUSECMD:=@read -p "(press [enter] to continue, or [^C] to cancel)`echo \\\n\\\r`" foo
endif

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
.PHONY: help usage p print hexdump xxd help put c clean x a $(AUTO) \
	build $(ASSEMBLY) $(DEBUG) $(DEBUG)_sc sc_$(DEBUG) $(BIN).o \
	$(XOR) $(XOR_BASIC) $(NEG) $(ALPHA)

# Default rule is print #
all: print
	@echo 'Tip: use `make help` for the man page'

help: usage # an alias #

usage:
	@(pandoc README.md | lynx -stdin) || less README.md

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

build: $(ASSEMBLY) # an alias #

# Debug it #
$(DEBUG): $(ASSEMBLY)
	@echo "About to debug $<:"
	$(PAUSECMD)
	gdb $(GDBARGS) -ex "start" $<

# Debug the shellcode (smashed stack situation) #
sc_$(DEBUG): $(AUTO).c
	$(CC) -g -m$(ARCH) $(VULNFLAGS) -o $(AUTO) $<
	@echo "About to debug the shellcode:"
	$(PAUSECMD)
	gdb $(GDBARGS) -ex "b *&shellcode" -ex "disas &shellcode" -ex "run" $(AUTO)

$(DEBUG)_sc: sc_$(DEBUG) # an alias #

# Dirty one-liner hacks to get start address and length of assembly code, #
# to then be able to get the right hex bytes #
$(BIN).hex: $(BIN).o
ifneq ($(SYNTAX), INTEL)
ifeq ($(OBJDUMP), ENABLED)
	@objdump -d $< # optional
else
	@gdb $(GDBARGS) -n -batch -ex "x/1500i _start" $<
endif
endif
	@gdb $(GDBARGS) -n -batch -ex "info file" $< | grep .text | cut -d "i" -f 1 > /tmp/_infofile_
	@gdb $(GDBARGS) -n -batch -ex "p/d `cat /tmp/_infofile_`" | cut -d "-" -f 2 > /tmp/_len_
	@gdb $(GDBARGS) -n -batch -ex "x/`cat /tmp/_len_`bx `cat /tmp/_infofile_ | cut -d "-" -f 1 && rm -f /tmp/_infofile_`" $< | cut -d ":" -f 2 > $@
	@echo "Total: `cat /tmp/_len_` bytes" > /tmp/_len_

$(BIN).xxd: $(BIN).hex
	@python -c 'import sys; print "" + "".join([sys.argv[1][k], "\\", ""][2 * int(sys.argv[1][k] == " " or sys.argv[1][k] == "\t" or sys.argv[1][k] == "\n" or sys.argv[1][k] == ",") + int(sys.argv[1][k] == "0" and sys.argv[1][(k+1) % len(sys.argv[1])] == "x")] for k in range(len(sys.argv[1]))) + ""' "`cat $<`" > $@
ifeq ($(SYNTAX), INTEL)
	@python -c "import sys; sys.stdout.write(\"`cat $@`\")" > /tmp/._bytes_ && ndisasm -b $(ARCH) /tmp/._bytes_ && rm -f /tmp/._bytes_
endif

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
	@echo "C program compiled successfully. The source file of this program is '$<'"
	@echo "\nAbout to run the C program to test the shellcode:"
	@echo " /!\\ never run untrusted shellcode /!\\"
	$(PAUSECMD)
	@echo "Running it:"
	@./$(AUTO)

a: $(AUTO) # an alias #

x: $(AUTO) # an alias #

print: $(BIN).xxd
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

hexdump: print # an alias #

xxd: hexdump # an alias #


# Python script to negate a shellcode and prepend the decoder #
$(NEG): $(HELPERS)/$(NEG).py $(BIN).xxd
	@echo " "
	@python $(HELPERS)/$(NEG).py "`cat $(BIN).xxd`" $(ARCH)

# Python script to xor a shellcode (with a random byte) and preprend the decoder #
$(XOR_BASIC): $(HELPERS)/$(XOR_BASIC).py $(BIN).xxd
	@echo " "
	@python $(HELPERS)/$(XOR_BASIC).py "`cat $(BIN).xxd`" $(ARCH) $(NO)

# Python script to xor a shellcode (with a rotating random word) and preprend the decoder #
$(XOR): $(HELPERS)/$(XOR).py $(BIN).xxd
	@echo " "
	@python $(HELPERS)/$(XOR).py "`cat $(BIN).xxd`" $(ARCH) $(NO)

# Python script to write the shellcode using alphanumeric chars only #
$(ALPHA): $(HELPERS)/$(ALPHA).py $(BIN).xxd
	@echo " "
	@python $(HELPERS)/$(ALPHA).py "`cat $(BIN).xxd`" $(ARCH)


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
	@rm -f $(HELPERS)/*.pyc

._raw_.s:
	@echo ".text\n.globl _start\n_start:\n\t.ascii \"$(SC)\"" > $@

%:
	@echo "No rule to make target '$@'"
	@false
