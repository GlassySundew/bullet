#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
BUILD_TYPE="${BUILD_TYPE:-Release}"
JOBS="${JOBS:-2}"

if [[ -z "${BUILD_DIR:-}" ]]; then
    BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/hl-bullet-build.XXXXXX")"
else
    rm -rf "$BUILD_DIR"
fi

echo "Using build dir: $BUILD_DIR"
cmake -S "$SCRIPT_DIR" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE="$BUILD_TYPE"
cmake --build "$BUILD_DIR" -j"$JOBS"

echo "Built $SCRIPT_DIR/../../bullet.hdll"
