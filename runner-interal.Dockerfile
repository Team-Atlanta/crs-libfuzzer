FROM gcr.io/oss-fuzz-base/base-runner
COPY ./run_fuzzer_wrapper.sh /usr/local/bin/run_fuzzer_wrapper.sh
ENTRYPOINT ["/usr/local/bin/run_fuzzer_wrapper.sh"]
