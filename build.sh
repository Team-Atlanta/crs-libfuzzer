#!/bin/sh

set -eu

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

# Build runner image
echo "Building runner image..."
docker build \
    -f runner-internal.Dockerfile \
    -t internal-runner \
    .

# Save runner image to /out/images/runner.tar
echo "Saving runner image to /out/images/runner.tar..."
mkdir -p /out/images
docker save internal-runner -o /out/images/runner.tar
echo "Runner image saved successfully"
