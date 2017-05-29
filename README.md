# Shellcode Factory tool
A tool to print and test shellcodes from assembly code. 

It supports both Gas and Intel syntax (_.s_ and _.asm_ extensions respectively), as well as x86 and x64 architectures.


## Usage:

	make targets [parameters]

 
### targets:

+ `assembly`			- will compile the assembly code from shellcode.s

+ `debug`			- debugs the assembly binary

+ `print` / `xxd` / `p`		- will print the shellcode in hex

+ `set`				- will call `nano shellcode.s`, to set the source assembly code

+ `put`				- will call `nano tester.c`, to put in it hex-encoded shellcode

+ `test`			- will compile _tester.c_ and run it, thus testing the shellcode

+ `auto` / `a`			- will do all of the above in one single step:

   compiling _shellcode.s_ into hex bytes,  
   loading those hex bytes into an auto-generated tester program (_auto.c_)  
   compiling and running that very program

+  `debug_sc`	 - debugs _auto_ i.e. the shellcode when called from a smashed stack

+  `xor`	 - xors the shellcode with a random byte, and prepends to it an appropriate decoder
(the decoder is 20-ish bytes long). It will try to avoid generating null bytes.

+  `clean` / `c`		- removes any non-source file at `.`

 
### parameters:

+ `ARCH=XX`  (default=32)		XX-bit binaries (32 / 64)

+ `S=filename`  (default=_shellcode.s_)	Source assembly filename.

+ `SC="\x31\xc0..."`  (ignored by default) Input shellcode (overrides `S` parameter).

+ `NO="[0x00, ...]"` (default=[0x00]) List of 'forbidden' chars, i.e., chars to avoid when xor-ing


### Examples:

+ `make print S=foo.s LANG=C` will print/hexdump the shellcode from _foo.s_ with C syntax

+ `make S=foo.s set p a ARCH=64` will let you edit _foo.s_ and will then hexdump it and attempt to run it (x64)

+ `make print SC="\x31\xc0\x40\xcd\x80"` will parse input shellcode into assembly instructions

+ `make c p sc_debug SC="\x31\xc0\x40\xcd\x80"` will clean (recommended) then print and debug input shellcode

+ `make print S=foo.asm | grep 00` is a useful trick to check for forbidden bytes (byte 00 for instance)

## Requires: 

1. `gcc` (`as` frontend) and `nasm` for GAS and INTEL syntax respectively (extensions _.s_ and _.asm_)

2. `gdb` (I also recommend enhancing it with `peda`: https://github.com/longld/peda)

3. `python` (tested with 2.7.12)

4. `cut`

5. `objdump` (optional: you can set `OBJDUMP` to `DISABLED` in the _Makefile_)

6. `nano` (optional: `set` and `put` targets only, and you can replace the `EDITOR=...` line in the _Makefile_ by your own editor)
