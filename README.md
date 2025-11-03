# Manual setup
```bash
export PROJECT_IMAGE=gcr.io/oss-fuzz/json-c:latest
docker image save -o project-image.tar $PROJECT_IMAGE
docker build --build-arg parent_image=$PROJECT_IMAGE -t test-dind -f builder.Dockerfile .
docker run --privileged --rm -v $(pwd)/project-image.tar:/project-image.tar -it test-dind
```
