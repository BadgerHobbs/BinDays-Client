#!/usr/bin/env bash
# Builds a *dynamic* libcurl-impersonate.xcframework for the BinDays app.
#
# The official ios-xcframework asset is a *static* archive whose curl_* symbols
# get dead-stripped, so they can't be resolved via dart:ffi
# DynamicLibrary.process(). Instead we take the official dynamic .dylib slices
# (which the per-arch iOS assets do ship) and wrap them into a dynamic
# framework, then combine the device and simulator slices into an xcframework.
#
# Usage: package_ios.sh <version> <out_dir>
# Requires: macOS with Xcode (lipo, install_name_tool, xcodebuild), curl, tar.
set -euo pipefail

VER="${1:?version required}"
OUT="${2:?out dir required}"
BASE="https://github.com/lexiforest/curl-impersonate/releases/download/v$VER"

FW="libcurl-impersonate"
ID="@rpath/$FW.framework/$FW"
WORK="$(mktemp -d)"

# Fetch and extract one per-arch iOS asset; echoes the path to its .dylib.
fetch_dylib() { # <triple> <dest-subdir>
  local triple="$1" dir="$WORK/$2"
  mkdir -p "$dir"
  curl -fsSL "$BASE/libcurl-impersonate-v$VER.$triple.tar.gz" -o "$dir/a.tgz"
  tar -xzf "$dir/a.tgz" -C "$dir"
  # `.dylib` is a symlink to the versioned file; -L copies the real binary.
  echo "$dir/$FW.dylib"
}

# Wraps a Mach-O dylib into a .framework with the rpath-relative install name.
make_framework() { # <dylib> <framework-dir>
  local bin="$1" fwdir="$2"
  mkdir -p "$fwdir"
  cp -L "$bin" "$fwdir/$FW"
  install_name_tool -id "$ID" "$fwdir/$FW"
  cat > "$fwdir/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleExecutable</key><string>$FW</string>
  <key>CFBundleIdentifier</key><string>app.bindays.curlimpersonate</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleName</key><string>$FW</string>
  <key>CFBundlePackageType</key><string>FMWK</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleShortVersionString</key><string>$VER</string>
  <key>MinimumOSVersion</key><string>13.0</string>
</dict></plist>
PLIST
}

dev_dylib="$(fetch_dylib arm64-apple-ios dev)"
sim_arm_dylib="$(fetch_dylib arm64-apple-ios-simulator sim-arm64)"
sim_x64_dylib="$(fetch_dylib x86_64-apple-ios-simulator sim-x64)"

# Device slice (arm64).
make_framework "$dev_dylib" "$WORK/fw-dev/$FW.framework"

# Simulator slice (fat arm64 + x86_64).
lipo -create "$sim_arm_dylib" "$sim_x64_dylib" -output "$WORK/sim-fat.dylib"
make_framework "$WORK/sim-fat.dylib" "$WORK/fw-sim/$FW.framework"

mkdir -p "$OUT"
rm -rf "$WORK/$FW.xcframework"
xcodebuild -create-xcframework \
  -framework "$WORK/fw-dev/$FW.framework" \
  -framework "$WORK/fw-sim/$FW.framework" \
  -output "$WORK/$FW.xcframework"

tar -czf "$OUT/libcurl-impersonate-ios-xcframework-v$VER.tar.gz" -C "$WORK" "$FW.xcframework"
echo "==> wrote $OUT/libcurl-impersonate-ios-xcframework-v$VER.tar.gz"
