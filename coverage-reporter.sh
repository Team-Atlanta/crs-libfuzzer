#!/bin/bash
# Coverage reporter service - periodically runs random corpus seeds through
# coverage-instrumented binaries and generates llvm-cov reports
set -eu

COVERAGE_DIR="/artifacts/coverage"
CORPUS_DIR="/artifacts/corpus"
REPORT_DIR="/artifacts/coverage-reports"
INTERVAL=30

# Use llvm tools from the coverage build (same LLVM version)
LLVM_PROFDATA="${COVERAGE_DIR}/llvm-profdata"
LLVM_COV="${COVERAGE_DIR}/llvm-cov"

# Fallback to system tools if not available
if [ ! -x "$LLVM_PROFDATA" ]; then
    LLVM_PROFDATA="llvm-profdata"
fi
if [ ! -x "$LLVM_COV" ]; then
    LLVM_COV="llvm-cov"
fi

echo "[coverage-reporter] Started (interval: ${INTERVAL}s)"

mkdir -p "$REPORT_DIR"

# Wait for corpus directory to have files
while [ ! -d "$CORPUS_DIR" ] || [ -z "$(ls -A "$CORPUS_DIR" 2>/dev/null)" ]; do
    echo "[coverage-reporter] Waiting for corpus seeds..."
    sleep 5
done

# Find coverage binaries (exclude llvm-symbolizer and other tools)
get_harnesses() {
    find "$COVERAGE_DIR" -maxdepth 1 -type f -executable ! -name "llvm-*" ! -name "*.so" ! -name "*.a" 2>/dev/null
}

iteration=0
while true; do
    iteration=$((iteration + 1))

    # Pick a random seed from corpus
    seed=$(find "$CORPUS_DIR" -type f 2>/dev/null | shuf -n 1)
    if [ -z "$seed" ]; then
        sleep $INTERVAL
        continue
    fi

    # Pick a random harness
    harness=$(get_harnesses | shuf -n 1)
    if [ -z "$harness" ]; then
        sleep $INTERVAL
        continue
    fi

    harness_name=$(basename "$harness")
    seed_name=$(basename "$seed")
    profraw_file="/tmp/coverage_${iteration}.profraw"
    profdata_file="/tmp/coverage_${iteration}.profdata"
    report_file="$REPORT_DIR/report_${iteration}_${harness_name}.txt"

    # Run the harness with the seed to generate coverage data
    export LLVM_PROFILE_FILE="$profraw_file"

    if timeout 5 "$harness" "$seed" >/dev/null 2>&1; then
        if [ -f "$profraw_file" ]; then
            # Convert raw profile to indexed profile
            if "$LLVM_PROFDATA" merge -sparse "$profraw_file" -o "$profdata_file" 2>/dev/null; then
                # Generate coverage report
                if "$LLVM_COV" report "$harness" -instr-profile="$profdata_file" > "$report_file" 2>/dev/null; then
                    summary=$("$LLVM_COV" report "$harness" -instr-profile="$profdata_file" 2>/dev/null | tail -1)
                    echo "[coverage-reporter] #${iteration} ${harness_name} (${seed_name}): ${summary}"
                fi
            fi
        fi
    fi

    # Cleanup temp files
    rm -f "$profraw_file" "$profdata_file"

    sleep $INTERVAL
done
