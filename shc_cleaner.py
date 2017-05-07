import sys
s = sys.argv[1]
# print s

op = "char shellcode[] = \n \""
antislash = True
for c in s:
	if (c == '0' and antislash):
		op += "\\"
		antislash = False
	else:
		if (c == " " or c == '\t' or c == '\n'):
			antislash = True
		else:
			op += c
print op + "\";"

