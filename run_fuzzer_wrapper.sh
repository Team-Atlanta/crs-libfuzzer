#!/bin/sh

set -eu

# Mount points (oss-crs convention):
#   /out        - Built fuzzers
#   /work       - Working directory
#   /artifacts  - Output artifacts (HOST_ARTIFACT_DIR)

HARNESS_NAME="${1:-$HARNESS_NAME}"
shift || true
FUZZ_TIME="${FUZZ_TIME:-3600}"

# Output directories (oss-crs structure)
CORPUS_OUT="/artifacts/corpus/${HARNESS_NAME}"
POV_OUT="/artifacts/povs/${HARNESS_NAME}"

mkdir -p "$CORPUS_OUT" "$POV_OUT"

# Seed corpus if exists
SEED_CORPUS="/out/${HARNESS_NAME}_seed_corpus"
if [ -d "$SEED_CORPUS" ]; then
    cp -r "$SEED_CORPUS"/* "$CORPUS_OUT"/ 2>/dev/null || true
fi

FORK_JOBS="${FORK_JOBS:-$(getconf _NPROCESSORS_ONLN)}"

# Run libfuzzer in fork mode with crash tolerance
"/out/${HARNESS_NAME}" \
    "$CORPUS_OUT" \
    -artifact_prefix="${POV_OUT}/" \
    -max_total_time="$FUZZ_TIME" \
    -fork="$FORK_JOBS" \
    -ignore_crashes=1 \
    -ignore_timeouts=1 \
    -ignore_ooms=1 \
    -detect_leaks=0 \
    -close_fd_mask=3 \
    "$@" > /dev/null 2>&1 || true
