# Using libgnat with a Windows Qt C/C++ project

## Critical facts

1. **Do not use the Linux `libgnat.so` / ELF `libgnat.a`.** Windows needs PE DLLs and MinGW archives (`.dll`, `.a`, `.dll.a`).
2. There is **no `libgnat.so` on Windows.** The shared runtime is `libgnat-N.dll` (also copied here as `libgnat.dll`).
3. **Qt kit must be MinGW**, not MSVC. GNAT object code / `libgnat` is a MinGW/GCC ABI. MSVC Qt kits will not link these cleanly.
4. **Arch must match** your `sim` library: 64-bit sim → use the x86_64 kit; 32-bit sim → use the i686 kit.
5. **GNAT version should match** whatever built `sim`. A 4.7-era `sim.lib`/`.a` often will **not** link against GNAT 16. Prefer the vendor’s Windows RTS, or an old GNAT GPL Windows install (2012/2013) close to GCC 4.7.

## What to grab

**Qt 5 + MinGW 32-bit + want static** (your case):

- `libgnat-windows-i686-mingw-static-gnat-13.2.0.tar.gz`
- or flat files in `ready-windows-i686-static/` (`libgnat.a`, `libgnarl.a`)

```pro
LIBS += -L$$PWD/third_party/libgnat -lsim -lgnat -lgnarl
```

64-bit Qt MinGW:

- `libgnat-windows-x86_64-mingw-gnat-16.2.0.tar.gz`
- or `ready-windows/`

Older 32-bit DLL-only kit (no static `.a`):

- `libgnat-windows-i686-mingw-gnat-8.2.0.tar.gz`

## qmake (`.pro`)

```pro
# Point at the extracted Windows kit
GNAT_DIR = $$PWD/third_party/libgnat

INCLUDEPATH += $$PWD/third_party/sim/include

LIBS += -L$$PWD/third_party/sim -lsim
LIBS += -L$$GNAT_DIR -lgnat -lgnarl

# If linking the DLLs via import libs instead of static .a:
# LIBS += -L$$GNAT_DIR -lgnat.dll -lgnarl.dll

win32 {
    # Ship DLLs next to the .exe for dynamic RTS
    CONFIG(debug, debug|release) {
        DESTDIR_WIN = $$OUT_PWD/debug
    } else {
        DESTDIR_WIN = $$OUT_PWD/release
    }
    QMAKE_POST_LINK += $$quote(cmd /c copy /y $$shell_path($$GNAT_DIR/libgnat-16.dll) $$shell_path($$DESTDIR_WIN) $$escape_expand(\\n\\t))
    QMAKE_POST_LINK += $$quote(cmd /c copy /y $$shell_path($$GNAT_DIR/libgnarl-16.dll) $$shell_path($$DESTDIR_WIN))
}
```

## CMake

```cmake
set(GNAT_DIR "${CMAKE_SOURCE_DIR}/third_party/libgnat")
set(SIM_DIR  "${CMAKE_SOURCE_DIR}/third_party/sim")

target_include_directories(app PRIVATE "${SIM_DIR}/include")
target_link_directories(app PRIVATE "${SIM_DIR}" "${GNAT_DIR}")
target_link_libraries(app PRIVATE sim gnat gnarl)

# Runtime DLLs beside the exe (when not fully static)
add_custom_command(TARGET app POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${GNAT_DIR}/libgnat-16.dll"
    "${GNAT_DIR}/libgnarl-16.dll"
    $<TARGET_FILE_DIR:app>)
```

## Static vs shared

| Goal | Link these | Deploy |
|------|------------|--------|
| Static RTS into exe | `libgnat.a` + `libgnarl.a` | No gnat DLL (still may need other MinGW DLLs) |
| Shared RTS | `libgnat.dll.a` / `-lgnat` + DLLs | Copy `libgnat-16.dll` + `libgnarl-16.dll` next to exe |

## If link still fails

On the Windows machine that has `sim`:

```bat
objdump -f sim.a | more
nm sim.a | findstr gnat
```

Check:

- COFF/PE vs ELF (must be Windows objects)
- i386 vs x86-64
- undefined `__gnat_*` names — those come from the matching Windows `libgnat`
