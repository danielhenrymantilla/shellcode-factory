Usage:

	make targets [parameters]
 
targets:

  shellcode	- will compile the assembly code from shellcode.s

  print/xxd/p	- will dump the contents of 'shellcode' in hex (first NN bytes)

  set		- will call 'nano shellcode.s', to set the source assembly code

  put		- will call 'nano tester.c', to put in it hex-encoded shellcode

  test		- will compile 'tester.c' and run it, thus testing the shellcode

  auto/a	- will do all of the above in one single step:
 compiling 'shellcode.s' into hex bytes,
 loading those hex bytes into an auto-generated tester program ('auto.c')
 compiling and running that very program
 
parameters:

  NN=XX    (default=80)		Maximum length of the shellcode (XX bytes)

  ARCH=XX  (default=32)		XX-bit binaries (32 / 64)

  E=XX     (default=_start)	Entry point of the assembly code (e.g. main)

For instance, 'make print NN=50' will print 50 hex-bytes of (32-bit) shellcode
	 and, 'make auto  NN=120 ARCH=64' will test 120 bytes of x64 shellcode

Requires: objdump, gdb, gcc, python
