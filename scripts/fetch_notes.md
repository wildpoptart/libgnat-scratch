# Where libgnat actually comes from

You will not find a trustworthy standalone `libgnat.a` / `libgnat.so` “for
download” the way you find random C libraries. Those files are the **GNAT
Ada runtime**, versioned with the Ada compiler that produced your
`libsim.a`.

## Preferred order of approaches

### 1. Get the matching runtime from whoever shipped `libsim.a`

Ask for the **same GNAT/GCC tree** used to build the archive (or a
sysroot / SDK zip that includes `adalib/`). That is the only ABI-safe
answer without reverse-engineering.

### 2. Install an old distro package (same major as the Ada objects)

On Debian/Ubuntu of that era, packages look like:

- `libgnat-4.6` / `gnat-4.6` (precise-era Ubuntu)
- later: `libgnat-4.9`, `libgnat-6`, … (version in the SONAME)

Archives (examples):

- Ubuntu gnat-4.6 pool: http://www.archive.canonical.com/pool/public/g/gnat-4.6/
- Debian archive gnat pool: https://snapshot.debian.org/package/gnat/

Extract without installing system-wide:

```bash
mkdir -p /tmp/gnatpkg && cd /tmp/gnatpkg
# download the matching .deb for your arch, then:
dpkg-deb -x libgnat-4.6_*.deb .
dpkg-deb -x gnat-4.6_*.deb .   # often has static libgnat.a under gcc/.../adalib
find . -name 'libgnat*'
```

Copy `libgnat.a` / `libgnat.so*` next to `libsim.a` and link with `-Llib -lsim -lgnat`.

**GCC 4.7.4 specifically:** many distros skipped a public `libgnat-4.7`
package and stayed on 4.6 then jumped to 4.9. If `libsim.a` truly needs
4.7.4’s RTS, prefer building that GCC with Ada (see
`build_libgnat_from_gcc474.sh`) or use the vendor’s own RTS.

### 3. Build GCC 4.7.4 with Ada enabled

```bash
./scripts/build_libgnat_from_gcc474.sh
```

After install, look under:

`$PREFIX/lib/gcc/<triplet>/4.7.4/adalib/`

You usually also need **`libgnarl`** if the Ada code uses tasking, plus
`-lpthread -ldl -lm` on Linux.

### 4. Last resort: newer libgnat

Linking a 4.7-era `libsim.a` against a modern `libgnat` often fails
(missing symbols, wrong layouts). Only try this if you control both
sides or can rebuild `libsim.a` from Ada sources with the new GNAT.

## How to confirm your archive needs GNAT

```bash
nm -C lib/libsim.a | grep -E 'gnat|ada|__gnat' | head
readelf -d your_binary | grep NEEDED   # after dynamic link
```

Undefined symbols named `__gnat_*`, `ada__*`, or similar mean you need
the Ada runtime, not a missing C library from “the Internet.”

## Typical successful link line

```bash
gcc -Iinclude test/test_sim.c -o test_sim \
  -Llib -Wl,-rpath,'$ORIGIN/../lib' \
  -lsim -lgnat -lgnarl -lpthread -ldl -lm
```

Static-only (no `.so` at runtime):

```bash
gcc -Iinclude test/test_sim.c -o test_sim \
  -Llib -lsim -Wl,-Bstatic -lgnat -lgnarl -Wl,-Bdynamic \
  -lpthread -ldl -lm
```
