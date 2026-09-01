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

# Remove obsolete EasySD artifacts that may remain from builds made before
# this branch received its own EasyCF product names.
rm -f EasySD_MB.bin EasySD_EL.bin EasySD_MB.lst EasySD_EL.lst \
      EasySD_MB_BIN.tap EasySD_EL.tap EasySD.sna
rm -f EasyCF_EL.bin EasyCF_EL.lst EasyCF_EL.tap

echo
echo "========================================"
echo "  Building EasyCF for MB03+"
echo "========================================"

rm -f EasyCF_MB.bin EasyCF_MB.lst
sjasmplus --lst=EasyCF_MB.lst --raw=EasyCF_MB.bin easyhdd.a80 || die "MB03+ BUILD FAILED"
[[ -s EasyCF_MB.bin ]] || die "MB03+ build did not create EasyCF_MB.bin"

if (( BIN_ONLY == 0 )); then
    echo
    echo "========================================"
    echo "  Building TAP files"
    echo "========================================"

    command -v python3 >/dev/null 2>&1 || die "python3 not found in PATH"
    [[ -f make_bin_taps.py ]] || die "make_bin_taps.py not found. BIN file was built successfully."
    python3 make_bin_taps.py || die "SIMPLE BIN TAP BUILD FAILED"

    [[ -s EasyCF_MB_BIN.tap ]] || die "EasyCF_MB_BIN.tap was not created"
fi

echo
echo "========================================"
echo "  BUILD OK"
echo "========================================"
echo "  EasyCF_MB.bin      - MB03+"
echo "  EasyCF_MB.lst"

if (( BIN_ONLY == 0 )); then
    echo "  EasyCF_MB_BIN.tap  - simple MB03+ TAP"
fi

echo "========================================"
