#!/bin/sh
# Builder script for coverage build - runs at container start
set -eu

# Override sanitizer for coverage build
export SANITIZER=coverage

echo "[builder-coverage] Cleaning /out and /work..."
rm -rf /out/* /work/*

echo "[builder-coverage] Running compile with SANITIZER=coverage..."
cd /src
compile

echo "[builder-coverage] Copying binaries to /artifacts/coverage/..."
mkdir -p /artifacts/coverage
cp -r /out/* /artifacts/coverage/ 2>/dev/null || true

echo "[builder-coverage] Copying llvm coverage tools..."
cp /usr/local/bin/llvm-profdata /artifacts/coverage/ 2>/dev/null || \
    cp /usr/bin/llvm-profdata /artifacts/coverage/ 2>/dev/null || true
cp /usr/local/bin/llvm-cov /artifacts/coverage/ 2>/dev/null || \
    cp /usr/bin/llvm-cov /artifacts/coverage/ 2>/dev/null || true

echo "[builder-coverage] Done."
