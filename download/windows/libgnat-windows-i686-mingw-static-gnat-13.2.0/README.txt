Windows 32-bit (i686) MinGW GNAT runtime — STATIC
Source: MSYS2 mingw-w64-i686-gcc-ada 13.2.0-6
Object format: pe-i386 (verified)

For Qt 5 + MinGW 32-bit linking libsim.a:

  LIBS += -Lpath/to/this/dir -lsim -lgnat -lgnarl

Prefer static:
  link libgnat.a + libgnarl.a (no need to ship libgnat-13.dll)

If the linker still complains about missing Ada symbols, your
libsim.a was likely built with a much older GNAT (e.g. 4.7) and
needs that era's Windows RTS instead of GNAT 13.

Also confirm libsim.a is pe-i386:
  objdump -f libsim.a | more
