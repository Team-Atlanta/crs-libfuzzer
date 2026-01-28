#!/bin/sh
# Builder script for default (ASan) build - runs at container start
set -eu

echo "[builder-default] Cleaning /out and /work..."
rm -rf /out/* /work/*

echo "[builder-default] Running compile..."
cd /src
compile

echo "[builder-default] Copying binaries to /artifacts/default/..."
mkdir -p /artifacts/default
cp -r /out/* /artifacts/default/ 2>/dev/null || true

echo "[builder-default] Done."
