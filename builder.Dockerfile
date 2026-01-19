FROM cruizba/ubuntu-dind

ARG parent_image
ENV PARENT_IMAGE=${parent_image}

ENV TZ=US \
    DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /app /src/project
WORKDIR /app
RUN apt-get update -y && apt-get install -y git python3 && rm -rf /var/lib/apt/lists*
RUN git clone --depth=1 https://github.com/google/oss-fuzz.git
COPY builder-internal.Dockerfile build.sh runner-internal.Dockerfile run_fuzzer_wrapper.sh compiler_wrapper.sh /app/
WORKDIR /src/project

CMD ["/app/build.sh"]
