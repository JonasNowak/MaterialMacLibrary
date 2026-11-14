#!/bin/sh
# Run the MaterialMacLibrary tests with Swift Testing.
#
# On macOS with only the CommandLineTools (CLT) installed, Testing.framework is
# not on the default search path, so we point the compiler and linker at the
# CLT copies explicitly. When Testing.framework is absent (e.g. an Xcode or
# GitHub CI toolchain, where Testing ships inside the toolchain itself), fall
# back to a plain `swift test`.
set -eu
cd "$(dirname "$0")/.."

SCRATCH=${MATERIALMACLIB_BUILD_DIR:-$HOME/Library/Caches/MaterialMacLibrary/build}

if [ -z "${SDKROOT:-}" ]; then
    if [ -d "/Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk" ]; then
        SDKROOT="/Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk"
    else
        SDKROOT=$(xcrun --show-sdk-path 2>/dev/null || true)
    fi
    export SDKROOT
fi

CLT=/Library/Developer/CommandLineTools
FW=$CLT/Library/Developer/Frameworks
LIB=$CLT/Library/Developer/usr/lib

xattr -cr "$SCRATCH" 2>/dev/null || true
xattr -cr Sources Tests scripts 2>/dev/null || true

if [ ! -d "$FW/Testing.framework" ]; then
    exec swift test --scratch-path "$SCRATCH" --disable-xctest --enable-swift-testing "$@"
fi

swift test --scratch-path "$SCRATCH" \
    --disable-xctest --enable-swift-testing \
    -Xswiftc -F"$FW" \
    -Xswiftc -plugin-path -Xswiftc "$CLT/usr/lib/swift/host/plugins" \
    -Xswiftc -plugin-path -Xswiftc "$CLT/usr/lib/swift/host/plugins/testing" \
    -Xlinker -F"$FW" \
    -Xlinker -rpath -Xlinker "$FW" \
    -Xlinker -rpath -Xlinker "$LIB" \
    "$@"
