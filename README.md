# libgnattest — why `libsim.a` wants `libgnat`

Example C project shaped like a vendor Ada sim library:

| Piece | Role |
|-------|------|
| `include/sim_api.h` | C API header |
| `src/main.c` | application |
| `test/test_sim.c` | tests calling the API |
| `lib/libsim.a` | prebuilt library (here: stand-in Ada objects) |
| `lib/libgnat.a` / `lib/libgnat.so` | GNAT Ada **runtime** (normally from GNAT/GCC) |

## The actual problem

`libsim.a` was built with **GNAT** (Ada). Ada object code always depends on
the GNAT runtime (`libgnat`, often also `libgnarl` for tasking). Those files
are **not** a separate open-source tarball you Google for; they ship with
the Ada compiler (or a matching distro package).

If the archive was built with **GCC/GNAT 4.7.4**, you need that era’s
runtime (or the vendor’s copy), not a random modern `libgnat`.

## Reproduce here

```bash
make fail-link   # undefined refs — missing -lgnat
make libs demo run
```

`vendor/` only fakes the Ada/GNAT symbols so this demo builds on a machine
with plain GCC. On the real machine, drop the vendor-built `libsim.a` and
a **matching** `libgnat` into `lib/`.

## How to get a real libgnat

See `scripts/fetch_notes.md` and `scripts/build_libgnat_from_gcc474.sh`.

Short version:

1. Prefer the SDK/runtime that came with `libsim.a`.
2. Else extract from old `libgnat-*` / `gnat-*` packages of the same ABI.
3. Else build GCC 4.7.4 with `--enable-languages=c,ada` (needs a bootstrap GNAT).
