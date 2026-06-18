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
SYSROOT="$NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
STAGE="$WORK/jniLibs"

# Android ABI -> upstream release triple.
declare -A ABIS=(
  [arm64-v8a]=aarch64-linux-android
  [x86_64]=x86_64-linux-android
)

for abi in "${!ABIS[@]}"; do
  triple="${ABIS[$abi]}"
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
