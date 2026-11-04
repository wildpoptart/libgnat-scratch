#!/usr/bin/env bash
# Build a real libgnat from GCC 4.7.4 sources (Ada runtime).
#
# Why this exists:
#   libgnat.a / libgnat.so are NOT standalone products you download from
#   random sites. They are the GNAT Ada runtime, produced when GCC is
#   built with --enable-languages=ada (or shipped in a distro's gnat /
#   libgnat-N package matching that compiler).
#
# Hard requirement (chicken-and-egg):
#   Building Ada in GCC needs a working Ada compiler already installed
#   (gnatmake, gnatbind, etc.), preferably close in version to 4.7.
#   A modern GNAT often fails to bootstrap ancient Ada sources.
#
# Practical bootstrap options on a modern host:
#   1) Use a VM/container of an old distro that still has gnat-4.6/4.7
#      (Ubuntu 12.04 / Debian wheezy era) and build there.
#   2) Install an AdaCore community or distro GNAT that can compile 4.7,
#      then use THAT as the bootstrap compiler for gcc-4.7.4.
#   3) Prefer extracting libgnat from matching old packages (see
#      scripts/fetch_notes.md) over a full compiler rebuild when you
#      only need the runtime for linking a prebuilt libsim.a.
#
# After a successful install, libraries typically land at:
#   $PREFIX/lib/gcc/<triplet>/4.7.4/adalib/libgnat.a
#   $PREFIX/lib/gcc/<triplet>/4.7.4/adalib/libgnat.so*
#   (and often also libgnarl for tasking)

set -euo pipefail

PREFIX="${PREFIX:-$HOME/opt/gcc-4.7.4-gnat}"
SRC_DIR="${SRC_DIR:-$HOME/src/gcc-4.7.4}"
BUILD_DIR="${BUILD_DIR:-$HOME/src/gcc-4.7.4-build}"
JOBS="${JOBS:-$(nproc 2>/dev/null || echo 2)}"
MIRROR="${MIRROR:-https://ftp.gnu.org/gnu/gcc/gcc-4.7.4}"

need() { command -v "$1" >/dev/null || { echo "missing tool: $1" >&2; exit 1; }; }

echo "==> Checking bootstrap Ada toolchain"
need gcc
need g++
need make
need wget
if ! command -v gnatmake >/dev/null; then
  cat >&2 <<'EOF'
No gnatmake found. You cannot build GCC Ada / libgnat without a bootstrap GNAT.

Install a GNAT close to 4.7 first (best: old Ubuntu/Debian VM), then re-run.
EOF
  exit 1
fi
gnatls -v | head -20 || true

echo "==> Fetching GCC 4.7.4 (if needed)"
mkdir -p "$(dirname "$SRC_DIR")"
if [[ ! -d "$SRC_DIR" ]]; then
  wget -c "$MIRROR/gcc-4.7.4.tar.bz2" -O /tmp/gcc-4.7.4.tar.bz2
  tar -xjf /tmp/gcc-4.7.4.tar.bz2 -C "$(dirname "$SRC_DIR")"
fi

echo "==> Configuring out-of-tree build (Ada + C)"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
# --disable-multilib avoids needing 32-bit libc headers on x86_64.
# --disable-bootstrap speeds a runtime-focused build; drop if you want a
# full 3-stage bootstrap for a production compiler.
"$SRC_DIR/configure" \
  --prefix="$PREFIX" \
  --enable-languages=c,ada \
  --disable-multilib \
  --disable-bootstrap \
  --disable-libsanitizer \
  --disable-libquadmath \
  --disable-libgomp

echo "==> Building (this takes a long time)"
make -j"$JOBS"
make install

echo "==> Looking for libgnat under $PREFIX"
find "$PREFIX" -name 'libgnat.a' -o -name 'libgnat.so*' | sort

cat <<EOF

Done (if find printed paths).

Point your C link at the adalib directory, e.g.:

  gcc test/test_sim.c -Iinclude -L/path/to/libsim \\
      -L$PREFIX/lib/gcc/\$(gcc -dumpmachine)/4.7.4/adalib \\
      -lsim -lgnat -lgnarl -lpthread -ldl -lm

Match architecture (32 vs 64) and exception model to whatever built libsim.a.
Mismatch = mysterious undefined refs or runtime crashes, not a clean fix.
EOF
