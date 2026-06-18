#!/usr/bin/env bash
# Builds the Android jniLibs bundle consumed by the BinDays app's Gradle build.
#
# Downloads the official libcurl-impersonate shared objects for the two ABIs the
# app ships (arm64-v8a, x86_64), pairs each with the matching libc++_shared.so
# from the Android NDK (the .so links against it), and tars the result into a
# ready-to-extract jniLibs tree.
#
# Usage: package_android.sh <version> <out_dir>
# Requires: curl, tar, and the Android NDK at $ANDROID_NDK_LATEST_HOME.
set -euo pipefail

VER="${1:?version required}"
OUT="${2:?out dir required}"
BASE="https://github.com/lexiforest/curl-impersonate/releases/download/v$VER"
NDK="${ANDROID_NDK_LATEST_HOME:?ANDROID_NDK_LATEST_HOME not set}"
# The prebuilt toolchain dir is host-specific (linux-x86_64, darwin-x86_64, ...);
# there is exactly one, so detect it rather than hardcoding the host.
PREBUILT="$(ls -d "$NDK"/toolchains/llvm/prebuilt/*/ | head -n1)"
SYSROOT="${PREBUILT%/}/sysroot/usr/lib"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
STAGE="$WORK/jniLibs"

# Android ABI : upstream release triple (indexed array, so this works on the
# Bash 3.2 that ships with macOS — `declare -A` is unsupported there).
ABIS=(
  "arm64-v8a:aarch64-linux-android"
  "x86_64:x86_64-linux-android"
)

for pair in "${ABIS[@]}"; do
  abi="${pair%%:*}"
  triple="${pair##*:}"
  echo "==> $abi ($triple)"
  mkdir -p "$WORK/$triple" "$STAGE/$abi"
  curl -fsSL "$BASE/libcurl-impersonate-v$VER.$triple.tar.gz" -o "$WORK/$triple.tgz"
  tar -xzf "$WORK/$triple.tgz" -C "$WORK/$triple"
  cp "$WORK/$triple/libcurl-impersonate.so" "$STAGE/$abi/"
  cp "$SYSROOT/$triple/libc++_shared.so" "$STAGE/$abi/"
done

mkdir -p "$OUT"
tar -czf "$OUT/android-jniLibs-v$VER.tar.gz" -C "$WORK" jniLibs
echo "==> wrote $OUT/android-jniLibs-v$VER.tar.gz"
