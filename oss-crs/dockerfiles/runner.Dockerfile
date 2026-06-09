ARG base_runner_image=gcr.io/oss-fuzz-base/base-runner:latest
FROM ${base_runner_image}
RUN apt-get update && apt-get install -y --no-install-recommends inotify-tools \
    && rm -rf /var/lib/apt/lists/*

# Install libCRS
COPY --from=libcrs . /libCRS
RUN /libCRS/install.sh

COPY ./run_fuzzer_wrapper.sh /usr/local/bin/run_fuzzer_wrapper.sh
ENTRYPOINT ["/usr/local/bin/run_fuzzer_wrapper.sh"]
