#!/bin/sh

set -eu

start-docker.sh

while ! docker info > /dev/null 2>&1; do
    echo "Waiting for Docker to be ready..."
    sleep 1
done

# Load the runner image from tarball
echo "Loading runner image from /out/images/runner.tar..."
docker load -i /out/images/runner.tar

# Run the runner container
echo "Running fuzzer..."
docker run --rm \
    -v /out:/out \
    -e CPUSET_CPUS="${CPUSET_CPUS}" \
    -e MEMORY_LIMIT="${MEMORY_LIMIT}" \
    -e RUN_FUZZER_MODE="${RUN_FUZZER_MODE}" \
    -e HELPER="${HELPER}" \
    -e FUZZING_ENGINE="${FUZZING_ENGINE}" \
    -e SANITIZER="${SANITIZER}" \
    internal-runner $@
