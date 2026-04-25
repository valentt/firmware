#!/usr/bin/env bash
#
# Build meshtasticd natively on macOS (Apple Silicon or Intel) without Docker.
#
# This wraps the standard `pio run -e native-macos` invocation and ensures
# the Homebrew prerequisites are installed. Use this for the headless dev
# loop — `meshtasticd -s` runs in SimRadio mode and accepts TCP connections
# on the standard meshtastic port.
#
# Real LoRa hardware: drive a CH341/SX1262 USB bridge by pointing the YAML
# config at the right device path. macOS includes a CH34x driver so the
# board enumerates as `/dev/tty.usbserial-*` (recent macOS) or
# `/dev/tty.wchusbserial*` (older).
#
# This env currently overrides `platform` and `platform_packages` to point at
# local clones of meshtastic/platform-native and meshtastic/framework-portduino
# (with the macOS patches). Once the upstream PRs land, swap the symlinks for
# commit pins.

set -e

if ! command -v brew >/dev/null 2>&1; then
    echo "error: Homebrew is required. Install from https://brew.sh and re-run." >&2
    exit 1
fi

REQUIRED_BREWS=(
    platformio
    yaml-cpp
    libuv
    openssl@3
    libusb
    argp-standalone
    pkg-config
)

missing=()
for pkg in "${REQUIRED_BREWS[@]}"; do
    if ! brew list --formula "$pkg" >/dev/null 2>&1; then
        missing+=("$pkg")
    fi
done

if [ ${#missing[@]} -gt 0 ]; then
    echo "Installing missing Homebrew packages: ${missing[*]}"
    brew install "${missing[@]}"
fi

PIO_ENV=${1:-native-macos}
pio run -e "$PIO_ENV"

OUTDIR=release
mkdir -p "$OUTDIR"
os_name=$(uname -s | tr '[:upper:]' '[:lower:]')
cp ".pio/build/$PIO_ENV/meshtasticd" "$OUTDIR/meshtasticd_${os_name}_$(uname -m)"

echo
echo "Built: $OUTDIR/meshtasticd_${os_name}_$(uname -m)"
echo "Try it: ./$OUTDIR/meshtasticd_${os_name}_$(uname -m) -s"
