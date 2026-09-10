#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

BIN_ONLY=0
if [[ "${1:-}" == "--bin-only" ]]; then
    BIN_ONLY=1
elif [[ $# -ne 0 ]]; then
    echo "Usage: $0 [--bin-only]" >&2
    exit 2
fi

die() {
    echo
    echo "*** $* ***" >&2
    exit 1
}

command -v sjasmplus >/dev/null 2>&1 || die "sjasmplus not found in PATH"
[[ -f easyhdd.a80 ]] || die "easyhdd.a80 not found in $SCRIPT_DIR"

# Remove obsolete EasySD artifacts that may remain from older cf-port builds.
rm -f EasySD_MB.bin EasySD_EL.bin EasySD_MB.lst EasySD_EL.lst \
      EasySD_MB_BIN.tap EasySD_EL.tap EasySD.sna

echo
echo "========================================"
echo "  Building EasyCF for MB03+"
echo "========================================"
rm -f EasyCF_MB.bin EasyCF_MB.lst
sjasmplus --lst=EasyCF_MB.lst --raw=EasyCF_MB.bin easyhdd.a80 || die "MB03+ BUILD FAILED"
[[ -s EasyCF_MB.bin ]] || die "MB03+ build did not create EasyCF_MB.bin"

echo
echo "========================================"
echo "  Building EasyCF for eLeMeNt"
echo "========================================"
rm -f EasyCF_EL.bin EasyCF_EL.lst
sjasmplus --lst=EasyCF_EL.lst --define ELEMENT --raw=EasyCF_EL.bin easyhdd.a80 || die "eLeMeNt BUILD FAILED"
[[ -s EasyCF_EL.bin ]] || die "eLeMeNt build did not create EasyCF_EL.bin"

if (( BIN_ONLY == 0 )); then
    echo
    echo "========================================"
    echo "  Building TAP files"
    echo "========================================"

    command -v python3 >/dev/null 2>&1 || die "python3 not found in PATH"
    [[ -f make_bin_taps.py ]] || die "make_bin_taps.py not found"
    [[ -f make_el_tap.py ]] || die "make_el_tap.py not found"

    python3 make_bin_taps.py || die "SIMPLE BIN TAP BUILD FAILED"
    python3 make_el_tap.py || die "FULL eLeMeNt TAP BUILD FAILED"

    [[ -s EasyCF_MB_BIN.tap ]] || die "EasyCF_MB_BIN.tap was not created"
    [[ -s EasyCF_EL.tap ]] || die "EasyCF_EL.tap was not created"
fi

echo
echo "========================================"
echo "  BUILD OK"
echo "========================================"
echo "  EasyCF_MB.bin      - MB03+"
echo "  EasyCF_EL.bin      - eLeMeNt"
echo "  EasyCF_MB.lst"
echo "  EasyCF_EL.lst"

if (( BIN_ONLY == 0 )); then
    echo "  EasyCF_MB_BIN.tap  - simple MB03+ TAP"
    echo "  EasyCF_EL.tap      - full eLeMeNt startup TAP"
fi

echo "========================================"
