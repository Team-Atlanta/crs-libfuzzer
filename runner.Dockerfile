FROM cruizba/ubuntu-dind

RUN mkdir -p /app
WORKDIR /app
COPY runner-internal.Dockerfile /app/
COPY run.sh run_fuzzer_wrapper.sh /app/

CMD ["./run.sh"]
