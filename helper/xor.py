numbers = "".join(str(i) for i in range(0,10))
lowercase = "".join(chr(n) for n in range(ord('a'), ord('z') + 1))
uppercase = "".join(chr(n) for n in range(ord('A'), ord('Z') + 1))
forbidden = ""
valid = (numbers + lowercase + uppercase).strip(forbidden)

l = {}
for x in valid.replace("0", "\xff"):
	for y in valid:
		for z in valid:
			n = ord(x) ^ ord(y) ^ ord(z)
			if not (n in l):
				l[n] = (x, y, z)

def display():
	for n in range(len(l)):
		print hex(n) + " = " + " ^ ".join("0x" + x.encode("hex") for x in l[n])

if __name__ == "__main__":
	display()
