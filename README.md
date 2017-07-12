# Shellcode Factory tool
A tool to print and test shellcodes from assembly code. 

It supports both Gas and Intel syntax (_.s_ and _.asm_ extensions respectively), as well as x86 and x64 architectures.


## Usage:

	make targets [parameters]

 
### targets:

+ `build` / `assembly`		- will compile the assembly code from shellcode.s

+ `debug`			- debugs the assembly binary

+ `print` / `xxd` / `p`		- will print the shellcode in hex

+ `x` / `auto` / `a`		- will run the shellcode using a smashed stack

+ `sc_debug`			- will debug the shellcode called from a smashed stack

+ `set`				- will let you edit the source assembly code

+ `neg`				- will negate the shellcode, and prepend to it a 12-bytes-long decoder. It assumes the shellcode is reached right after a _ret_ instruction

+ `xor_byte`			- will xor the shellcode with a random byte, and prepend to it an appropriate decoder
(the decoder is 21-26 bytes long). It will try to avoid the bytes from the _NO_ parameter.

+ `xor`				- will xor the shellcode with a random rotating word, and prepends to it an appropriate decoder
(the decoder is 27-34 bytes long). It will try to avoid the bytes from the _NO_ parameter.

+  `alphanumeric`		- will transform the shellcode into one using alphanumeric chars only
(it needs to be reached right after a _ret_ instruction for it to work)

+  `clean` / `c`		- removes generated files

 
### parameters:

+ `ARCH=XX`		(default=32)			XX-bit binaries (32 / 64)

+ `S=filename`		(default=_shellcode.s_)		Source assembly filename.

+ `SC="\x31\xc0..."`	(ignored by default)		Raw Input shellcode (overrides `S` parameter).

+ `NO="[0x...]"` (default="[0x00, 0x20, 0x9, 0xa]")	List of chars to avoid when xor-ing

+ `PAUSE=NO`						Disables the pause-before-execution security

+ `LANG=C`						Changes the formatting of the `print` command to use a C-style array of bytes


### Examples:

+ `make print x S=foo.s LANG=C` will print the shellcode from _foo.s_ with C syntax and execute it

+ `make S=foo.s set c p a ARCH=64` will let you edit _foo.s_ and will then hexdump it and attempt to run it (x64)

+ `make c print SC="\x31\xc0\x40\xcd\x80"` will parse input shellcode into assembly instructions

+ `make c p sc_debug SC="\x31\xc0\x40\xcd\x80"` will clean (recommended) then print and debug input shellcode

+ `make p S=foo.asm | grep -e x00 -e x20` is a useful trick to check for forbidden bytes (bytes 0x00 and 0x20 for instance)

+ `make p xor S=foo.asm NO="[0x00, 0x20]"` xors the shellcode to avoid forbidden bytes

+ `make p alphanumeric S=foo.s ` generates an alphanumeric version of the shellcode


## Requires: 

1. `gcc` (`as` frontend) and `nasm` for GAS and INTEL syntax respectively (extensions _.s_ and _.asm_)

2. `gdb` (I also recommend enhancing it with `peda`: https://github.com/longld/peda)

3. `python` (tested with 2.7.12)

4. `cut`

5. `objdump` (optional: you can set `OBJDUMP` to `DISABLED` in the _Makefile_)

6. `nano` (optional: `set` and `put` targets only, and you can replace the `EDITOR=...` line in the _Makefile_ by your own editor)

7. `pandoc` & `lynx` (optional) : print a nicer help/usage message

8. _GNU_ `make` of course
