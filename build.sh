#!/bin/bash

set -eu

cd /app

# Start Docker daemon
start-docker.sh

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
volume_args=()
if [ -n "${SOURCE_WORKDIR+x}" ]; then
    volume_args=(-v "/src/project:$SOURCE_WORKDIR")
    echo "Using volume mount ${volume_args[@]}"
else
    echo "No custom source code provided"
fi

docker run --rm -v /out:/out "${volume_args[@]}" -e 'FUZZING_LANGUAGE=c++' internal-builder

# Build runner image
echo "Building runner image..."
docker build \
    -f runner-internal.Dockerfile \
    -t internal-runner \
    .
