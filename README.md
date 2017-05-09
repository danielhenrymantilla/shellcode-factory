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
 
### parameters:

+ `ARCH=XX`  (default=32)		XX-bit binaries (32 / 64)

+ `S=filename`  (default=_shellcode.s_)	Source assembly filename.

### Examples:
+ `make print S=foo.s` will print the shellcode from _foo.s_

+ `make ARCH=64 auto` will test the x64 shellcode starting at main

## Requires: 
1. `gcc` (`as` frontend) and `nasm` for GAS and INTEL syntax respectively (extensions _.s_ and _.asm_)

2. `gdb` (it could actually be replaced by `objdump` in this script, but it is still a *really* recommended tool to debug a shellcode)

3. `python`

4. `cut`

5. `objdump` (optional: you can comment out the objdump lines in the _Makefile_)

6. `nano` (optional: `set` and `put` targets only, and you can replace the `EDITOR=...` line in the _Makefile_ by your own editor)
