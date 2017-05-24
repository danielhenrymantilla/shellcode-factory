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
.PHONY: all help usage p print hexdump xxd help put clean a $(AUTO)\
	$(ASSEMBLY) $(DEBUG) $(DEBUG)_sc sc_$(DEBUG) $(BIN).o

# Default rule is usage #
all: usage

help: usage # an alias #

usage:
	@cat README.md

set: $(SOURCE)
	$(EDITOR) $<

put: $(TESTER).c
	$(EDITOR) $<

test: $(TESTER)
	./$<

$(TESTER): $(TESTER).c
	$(CC) -m$(ARCH) -g $(VULNFLAGS) -o $@ $<


# Compile the assembly as an object file (to extracting its hex data) #
$(BIN).o: $(SOURCE)
ifneq ($(EXT), .asm)
	$(CC) -m$(ARCH) -nostdlib -o $@ -c $<
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
endif
	@gdb -n -batch -ex "info file" $< | grep .text | cut -d "i" -f 1 > /tmp/_infofile_
	@echo "\nTotal: `gdb -n -batch -ex "p \`cat /tmp/_infofile_\`" | cut -d "-" -f 2 > /tmp/_len_ && cat /tmp/_len_` bytes."
	@gdb -n -batch -ex "x/`cat /tmp/_len_ && rm -f /tmp/_len_`bx `cat /tmp/_infofile_ | cut -d "-" -f 1 && rm -f /tmp/_infofile_`" $< | cut -d ":" -f 2 > $@

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
# We use escaped-characters syntax for python copy-paste compatibility
	@echo "char shellcode[] =\n \"`cat $<`\";" >> $@
	@echo '\nint main() {\n  WORD* ret;\n  ret = (WORD *) &ret + 2; /* Saved IP */\n  *ret = (WORD) shellcode;\n  return 0;\n}' >> $(AUTO).c

$(AUTO): $(AUTO).c
	$(CC) -g -m$(ARCH) $(VULNFLAGS) -o $@ $<
	@echo "\nC program compiled successfully.\nRunning it:"
	@./$(AUTO)
	@echo "\nThe source file of this program is '$(AUTO).c'\n"

a: $(AUTO) # an alias #

hexdump: $(BIN).xxd
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

clean:
	@rm -f $(ASSEMBLY) $(TESTER)
	@rm -f $(AUTO)*
	@rm -f ._raw_.*
	@rm -f /tmp/_len_
	@rm -f /tmp/_infofile_
	@rm -f *.o
	@rm -f *~
	@rm -f *.hex
	@rm -f *.xxd
	@ls

._raw_.s:
	@echo ".text\n.globl _start\n_start:\n\t.ascii \"$(SC)\"" > $@

%:
	@echo "No rule to make target '$@'"
	@false
