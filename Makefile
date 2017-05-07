## DEFINES ##
# Assembly source file
SHELLCODE=shellcode

# Entry point name: '_start' or 'main'
E=_start

# Architecture: x86 (32) or x64 (64).
ARCH=32

# Length of the shellcode
NN=80

# Name of the given C file to test the shellcode with (no .c extension).
TESTER=tester

# Name of the automatically-generated C file and binary (no .c extension).
AUTO=auto

## COMMANDS ##
.PHONY: all test p print hexdump xxd help put clean a

all: help

help:
	@echo "Usage:\n\tmake targets [parameters]"
	@echo " "
	@echo "targets:"
	@echo "  $(SHELLCODE)\t- will compile the assembly code from $(SHELLCODE).s"
	@echo "  print/xxd/p\t- will dump the contents of '$(SHELLCODE)' in hex (first NN bytes)"
	@echo "  set\t\t- will call 'nano $(SHELLCODE).s', to set the source assembly code"
	@echo "  put\t\t- will call 'nano $(TESTER).c', to put in it hex-encoded shellcode"
	@echo "  test\t\t- will compile '$(TESTER).c' and run it, thus testing the shellcode"
	@echo "  $(AUTO)/a\t\t- will do all of the above in one single step:"
	@echo "   > compiling '$(SHELLCODE).s' into hex bytes,"
	@echo "   > loading those hex bytes into an auto-generated tester program ('$(AUTO).c')"
	@echo "   > compiling and running that very program"
	@echo " "
	@echo "parameters:"
	@echo "  NN=XX    (default=$(NN))\t\tMaximum length of the shellcode (XX bytes)"
	@echo "  ARCH=XX  (default=$(ARCH))\t\tXX-bit binaries (32 / 64)"
	@echo "  E=XX     (default=$(E))\tEntry point of the assembly code (e.g. main)"
	@echo "\nFor instance, 'make print NN=50' will print 50 hex-bytes of (32-bit) shellcode"
	@echo "\t and, 'make auto  NN=120 ARCH=64' will test 120 bytes of x64 shellcode"


set: $(SHELLCODE).s
	nano $<

put: $(TESTER).c
	nano $<

test: $(TESTER)
	./$<

$(TESTER): $(TESTER).c
	$(CC) -m$(ARCH) -o $(TESTER) $(TESTER).c -fno-stack-protector -z execstack

$(SHELLCODE): $(SHELLCODE).s
ifneq ($(E), main)
	$(CC) -m$(ARCH) -nostdlib -o $@ $<
else
	$(CC) -m$(ARCH) -o $@ $<
endif

gdb_cmd:
	@echo "set print address on\nb $(E)\nr\nset logging file /tmp/gdb-log \nset logging overwrite on\nset logging redirect off\nset logging on\nx/$(NN)bx $(E)\nset logging off" > gdb_cmd

a: $(AUTO)
$(AUTO): $(SHELLCODE) gdb_cmd
	@objdump -d $(SHELLCODE)
	@gdb -n $< -batch -x gdb_cmd
	@python shc_cleaner.py "`cat /tmp/gdb-log | cut -d ':' -f 2`" > $(AUTO).c
	@echo 'int main() { int* ret; ret = (int *)&ret + 2; *ret = (int)shellcode; return 0; }' >> $(AUTO).c
	@rm -f gdb_cmd
	@$(CC) -m$(ARCH) -z execstack -fno-stack-protector -o $(AUTO) $(AUTO).c
	@echo "\nC program compiled successfully.\nRunning it:"
	@./$(AUTO)
	@echo "\nThe source file of this program is '$(AUTO).c'\n"

p: print
print: hexdump
xxd: hexdump
hexdump: $(SHELLCODE) gdb_cmd
	@objdump -d $(SHELLCODE)
	@echo " "
	@gdb -n $< -batch -x gdb_cmd > /dev/null
	@cat /tmp/gdb-log
	@echo " "
	@python shc_cleaner.py "`cat /tmp/gdb-log | cut -d ':' -f 2`"
	@echo " "
	@rm -f gdb_cmd
	@rm -f /tmp/gdb-log

clean:
	@rm -f $(SHELLCODE) $(TESTER)
	@rm -f $(AUTO)*
	@rm -f *.o
	@rm -f *~
	@rm -f gdb_cmd
	@rm -f /tmp/gdb-log
	@ls
