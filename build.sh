#!/bin/sh

set -eu

while ! docker info > /dev/null 2>&1; do
    echo "Waiting for Docker to be ready..."
    sleep 1
done

echo "Using parent image: $PARENT_IMAGE"

# Load the project image from tarball
echo "Loading project image from /project-image.tar..."
docker load -i /project-image.tar

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
