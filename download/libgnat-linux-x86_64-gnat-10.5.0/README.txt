GNAT Ada runtime for Linux x86_64
Source: Ubuntu 22.04 packages
  gnat-10 / libgnat-10  version 10.5.0-1ubuntu1~22.04.3

Use this only if your Ada objects were built with GNAT 10.
Do NOT expect this to satisfy a GCC 4.7-era libsim.a.

Files:
  libgnat.a / libgnat.so
  libgnarl.a / libgnarl.so

Link example:
  gcc your.c -L. -lsim -lgnat -lgnarl -lpthread -ldl -lm
