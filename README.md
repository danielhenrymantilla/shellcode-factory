# Shellcode Factory tool

## Usage:

	`make targets [parameters]`
 
### targets:

+ `shellcode`			- will compile the assembly code from shellcode.s

+ `print` / `xxd` / `p`		- will dump the contents of _shellcode_ in hex (first NN bytes)

+ `set`				- will call `nano shellcode.s`, to set the source assembly code

+ `put`				- will call `nano tester.c`, to put in it hex-encoded shellcode

+ `test`			- will compile _tester.c_ and run it, thus testing the shellcode

+ `auto` / `a`			- will do all of the above in one single step:

   compiling _shellcode.s_ into hex bytes,  
   loading those hex bytes into an auto-generated tester program (_auto.c_)  
   compiling and running that very program
 
### parameters:

+ `NN=XX`    (default=80)		Maximum length of the shellcode (XX bytes)

+ `ARCH=XX`  (default=32)		XX-bit binaries (32 / 64)

+ `E=XX`     (default=_\_start_)	Entry point of the assembly code (e.g. _main_)

### Examples:
+ `make print NN=50` will print 50 hex-bytes of (32-bit) shellcode

+ `make auto  NN=120 ARCH=64` will test 120 bytes of x64 shellcode

## Requires: 
1. `gcc` 

2. `gdb`

3. `python`

4. `objdump` (optional: you can comment out the objdump lines in the _Makefile_)

5. `nano` (optional: `set` and `put` targets only, and you can replace the `EDITOR=...` line in the _Makefile_ by your own editor)
