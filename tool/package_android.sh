#!/usr/bin/env bash
# Builds the Android jniLibs bundle consumed by the BinDays app's Gradle build.
#
# Unlike the desktop/iOS jobs (which re-publish upstream's official binaries),
# the Android libcurl-impersonate.so is BUILT FROM SOURCE here. Upstream's
# official Android binaries are linked with a 4 KB max-page-size and so are not
# 16 KB page-size compatible, which Google Play now requires for Android 15+.
#
# We replicate upstream's exact Android build -- same source tag, same NDK r26d
# toolchain, same CMake configuration -- and add only
# `-Wl,-z,max-page-size=16384` to the libcurl shared-library link so the result
# is 16 KB-aligned. Each ABI's .so is paired with the matching libc++_shared.so
# from the NDK, and both are verified to be 16 KB-aligned before packaging.
#
# Usage: package_android.sh <version> <out_dir>
# Requires: git, tar, make, cmake, ninja, go, autoconf, automake, libtool,
#   gperf, a host C/C++ toolchain, and the Android NDK at
#   $ANDROID_NDK_LATEST_HOME (NDK r26d, to match upstream's proven toolchain).
set -euo pipefail

VER="${1:?version required}"
OUT="${2:?out dir required}"
NDK="${ANDROID_NDK_LATEST_HOME:?ANDROID_NDK_LATEST_HOME not set}"
API=21  # Matches upstream's Android API level.

# The prebuilt toolchain dir is host-specific (linux-x86_64, darwin-x86_64, ...);
# there is exactly one, so detect it rather than hardcoding the host.
PREBUILT="$(ls -d "$NDK"/toolchains/llvm/prebuilt/*/ | head -n1)"
PREBUILT="${PREBUILT%/}"
SYSROOT="$PREBUILT/sysroot/usr/lib"
READELF="$PREBUILT/bin/llvm-readelf"

# Google Play requires every shared library to be 16 KB page-size compatible:
# each PT_LOAD segment must have an alignment of at least 16384 (0x4000) so the
# loader can map it on a 16 KB boundary. This guards against a build that
# silently regresses (e.g. the link flag below failing to apply).
assert_16kb_aligned() {
  local so="$1" align
  # Every PT_LOAD segment's alignment ($NF is the Align column, a hex value like
  # 0x1000 / 0x4000) must be at least 16384.
  "$READELF" --program-headers "$so" | awk '$1=="LOAD"{print $NF}' \
  | while read -r align; do
      if [ "$((align))" -lt "$((0x4000))" ]; then
        echo "ERROR: $so has a PT_LOAD segment aligned to $align (< 0x4000)." >&2
        echo "       It is not 16 KB page-size compatible and cannot be shipped." >&2
        exit 1
      fi
    done
}

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
STAGE="$WORK/jniLibs"

# Fetch the exact curl-impersonate source for the pinned version.
SRC="$WORK/curl-impersonate"
git clone --depth 1 --branch "v$VER" \
  https://github.com/lexiforest/curl-impersonate.git "$SRC"

# Inject the 16 KB page-size linker flag into the curl subproject's configure.
# The superbuild does not forward CMAKE_SHARED_LINKER_FLAGS to the curl
# ExternalProject, so add it directly ahead of a curl-only configure arg. The
# post-build alignment check fails loudly if this ever stops applying.
sed -i \
  's#-DCURL_USE_OPENSSL=ON#-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-z,max-page-size=16384\n      -DCURL_USE_OPENSSL=ON#' \
  "$SRC/CMakeLists.txt"
grep -q "max-page-size=16384" "$SRC/CMakeLists.txt" \
  || { echo "ERROR: failed to inject 16 KB linker flag into curl build." >&2; exit 1; }

# Android ABI : upstream toolchain triple (indexed array, so this works on the
# Bash 3.2 that ships with macOS -- `declare -A` is unsupported there).
ABIS=(
  "arm64-v8a:aarch64-linux-android"
  "x86_64:x86_64-linux-android"
)

for pair in "${ABIS[@]}"; do
  abi="${pair%%:*}"
  triple="${pair##*:}"
  echo "==> building $abi ($triple)"
  mkdir -p "$STAGE/$abi"

  install_dir="$WORK/install-$abi"
  mkdir -p "$install_dir"

  # Android toolchain env (mirrors upstream's build.yml).
  export AR="$PREBUILT/bin/llvm-ar"
  export CC="$PREBUILT/bin/${triple}${API}-clang"
  export AS="$CC"
  export CXX="$PREBUILT/bin/${triple}${API}-clang++"
  export RANLIB="$PREBUILT/bin/llvm-ranlib"
  export STRIP="$PREBUILT/bin/llvm-strip"
  export ANDROID_NDK_HOME="$NDK"
  export CFLAGS="-fPIC"
  export CXXFLAGS="-fPIC"

  cmake_args="-G Ninja -DCMAKE_INSTALL_PREFIX=$install_dir"
  cmake_args="$cmake_args -DCMAKE_SYSTEM_NAME=Android"
  cmake_args="$cmake_args -DCMAKE_ANDROID_NDK=$NDK"
  cmake_args="$cmake_args -DCMAKE_ANDROID_ARCH_ABI=$abi -DCMAKE_SYSTEM_VERSION=$API"

  make -C "$SRC" configure     BUILD_DIR="build-$abi" CMAKE_CONFIGURE_ARGS="$cmake_args"
  make -C "$SRC" build         BUILD_DIR="build-$abi" CMAKE_CONFIGURE_ARGS="$cmake_args"
  make -C "$SRC" install-strip BUILD_DIR="build-$abi" CMAKE_CONFIGURE_ARGS="$cmake_args"

  # Copy the freshly built .so (resolving any versioned soname symlink) and pair
  # it with the NDK's libc++_shared.so, then verify both are 16 KB-aligned.
  cp "$(readlink -f "$install_dir/lib/libcurl-impersonate.so")" \
     "$STAGE/$abi/libcurl-impersonate.so"
  cp "$SYSROOT/$triple/libc++_shared.so" "$STAGE/$abi/"
  assert_16kb_aligned "$STAGE/$abi/libcurl-impersonate.so"
  assert_16kb_aligned "$STAGE/$abi/libc++_shared.so"
done

mkdir -p "$OUT"
tar -czf "$OUT/android-jniLibs-v$VER.tar.gz" -C "$WORK" jniLibs
echo "==> wrote $OUT/android-jniLibs-v$VER.tar.gz"
