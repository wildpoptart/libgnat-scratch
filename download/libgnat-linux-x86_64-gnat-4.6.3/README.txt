GNAT Ada runtime for Linux x86_64
Source: Ubuntu precise-era packages
  gnat-4.6 / libgnat-4.6  version 4.6.3-1ubuntu4
Closest commonly available public runtime to the GCC 4.7.x Ada era.
There was no widely shipped standalone libgnat-4.7 package.

Files:
  libgnat.a   static runtime
  libgnat.so  shared runtime (SONAME was libgnat-4.6.so.1)
  libgnarl.a / libgnarl.so  tasking runtime (link if Ada uses tasks)

Link example:
  gcc your.c -L. -lsim -lgnat -lgnarl -lpthread -ldl -lm

If your libsim.a was built with a different GNAT (exact 4.7.4 vendor
build, 32-bit, different exception model), these may not link or may
crash. Prefer the vendor RTS when possible.
