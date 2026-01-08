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
CORPUS_OUT="/artifacts/corpus"
POV_OUT="/artifacts/povs"

# Seed sharing configuration
SEED_SHARE_DIR="${SEED_SHARE_DIR:-/seed_share_dir}"
VERBOSE="${VERBOSE:-}"

mkdir -p "$CORPUS_OUT" "$POV_OUT"

# Seed corpus if exists
SEED_CORPUS="/out/${HARNESS_NAME}_seed_corpus"
if [ -d "$SEED_CORPUS" ]; then
    cp -r "$SEED_CORPUS"/* "$CORPUS_OUT"/ 2>/dev/null || true
fi

log() {
    [ -n "$VERBOSE" ] && echo "[watchdog] $*" >&2
}

# Seed watchdog: monitors SEED_SHARE_DIR using inotifywait and copies new seeds to corpus
seed_watchdog() {
    # Wait for directory to exist
    while [ ! -d "$SEED_SHARE_DIR" ]; do
        log "waiting for $SEED_SHARE_DIR to exist..."
        sleep 1
    done
    log "watching $SEED_SHARE_DIR"

    # Initial sync of existing files
    for seed in "$SEED_SHARE_DIR"/*; do
        if [ -f "$seed" ]; then
            log "initial sync: $(basename "$seed")"
            cp "$seed" "$CORPUS_OUT/" 2>/dev/null || true
        fi
    done

    # Watch for new files using inotifywait
    inotifywait -m -q -e create -e moved_to --format '%f' "$SEED_SHARE_DIR" | \
    while read -r filename; do
        seed="$SEED_SHARE_DIR/$filename"
        if [ -f "$seed" ]; then
            log "new seed: $filename"
            cp "$seed" "$CORPUS_OUT/" 2>/dev/null || true
        fi
    done
}

# Cleanup handler
cleanup() {
    [ -n "${WATCHDOG_PID:-}" ] && kill "$WATCHDOG_PID" 2>/dev/null || true
}

# Count CPUs from range string (e.g., "0-7" or "0,2,4-6")
count_cpus() {
    count=0
    for range in $(echo "$1" | tr ',' ' '); do
        case "$range" in
            *-*) count=$((count + ${range#*-} - ${range%-*} + 1)) ;;
            *)   count=$((count + 1)) ;;
        esac
    done
    echo "$count"
}

FORK_JOBS="${FORK_JOBS:-$(count_cpus "${CPUSET_CPUS:-0}")}"

# Start seed watchdog in background
seed_watchdog &
WATCHDOG_PID=$!
trap cleanup EXIT INT TERM

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
    -reload=1 \
    "$@" > /dev/null 2>&1 || true
