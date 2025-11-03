#!/bin/sh

set -eu

while ! docker info > /dev/null 2>&1; do
    echo "Waiting for Docker to be ready..."
    sleep 1
done

# Load the project image from tarball
docker load -i /out/

# Build the internal image using the loaded image as parent
echo "Building internal image..."
docker build \
    --build-arg parent_image="$PARENT_IMAGE" \
    -f builder-internal.Dockerfile \
    -t internal-builder \
    .

# Run the container
echo "Running container..."
docker run --rm -v /out:/out -e 'FUZZING_LANGUAGE=c++' internal-builder
